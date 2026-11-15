module riscv_pipelined (
    input clk,
    input reset,
    output [31:0] pc_out,
    output [31:0] alu_result_ex_out,
    output [1:0] forward_a_out,
    output [1:0] forward_b_out,
    output stall_out
);
    // --- STAGE 1: IF (Instruction Fetch) ---
    reg [31:0] pc_if;
    wire [31:0] instr_if, pc_next_if;
    wire stall;

    assign pc_next_if = pc_if + 32'd4;
    always @(posedge clk or posedge reset) begin
        if (reset) pc_if <= 32'b0;
        else if (!stall) pc_if <= pc_next_if;
    end
    imem IMEM_STAGE (.addr(pc_if), .instr(instr_if));

    // IF/ID Pipeline Register
    reg [31:0] pc_id, instr_id;
    always @(posedge clk or posedge reset) begin
        if (reset) begin pc_id <= 0; instr_id <= 0; end
        else if (!stall) begin pc_id <= pc_if; instr_id <= instr_if; end
    end

    // --- STAGE 2: ID (Instruction Decode) ---
    wire reg_write_id, alu_src_id, mem_read_id, mem_write_id, mem_to_reg_id, branch_id;
    wire [2:0] alu_control_id;
    wire [31:0] read_data1_id, read_data2_id, imm_id;
    reg reg_write_wb;
    reg [4:0] rd_wb;
    wire [31:0] write_back_data_wb;

    control_unit CTRL_STAGE (
        .opcode(instr_id[6:0]), .funct3(instr_id[14:12]), .funct7_5(instr_id),
        .reg_write(reg_write_id), .alu_src(alu_src_id), .mem_read(mem_read_id),
        .mem_write(mem_write_id), .mem_to_reg(mem_to_reg_id), .branch(branch_id),
        .alu_control(alu_control_id)
    );

    reg_file REG_STAGE (
        .clk(clk), .reg_write(reg_write_wb),
        .rs1(instr_id[19:15]), .rs2(instr_id[24:20]), .rd(rd_wb),
        .write_data(write_back_data_wb),
        .read_data1(read_data1_id), .read_data2(read_data2_id)
    );

    imm_gen IMM_STAGE (.instr(instr_id), .imm_out(imm_id));

    // ID/EX Pipeline Register
    reg reg_write_ex, alu_src_ex, mem_read_ex, mem_write_ex, mem_to_reg_ex;
    reg [2:0] alu_control_ex;
    reg [31:0] read_data1_ex, read_data2_ex, imm_ex;
    reg [4:0] rs1_ex, rs2_ex, rd_ex;

    hazard_detection_unit HDU (
        .mem_read_ex(mem_read_ex), .rd_ex(rd_ex),
        .rs1_id(instr_id[19:15]), .rs2_id(instr_id[24:20]),
        .stall(stall)
    );

    always @(posedge clk or posedge reset) begin
        if (reset || stall) begin
            reg_write_ex <= 0; alu_src_ex <= 0; mem_read_ex <= 0;
            mem_write_ex <= 0; mem_to_reg_ex <= 0; alu_control_ex <= 0;
            read_data1_ex <= 0; read_data2_ex <= 0; imm_ex <= 0;
            rs1_ex <= 0; rs2_ex <= 0; rd_ex <= 0;
        end else begin
            reg_write_ex <= reg_write_id; alu_src_ex <= alu_src_id;
            mem_read_ex <= mem_read_id; mem_write_ex <= mem_write_id;
            mem_to_reg_ex <= mem_to_reg_id; alu_control_ex <= alu_control_id;
            read_data1_ex <= read_data1_id; read_data2_ex <= read_data2_id;
            imm_ex <= imm_id; rs1_ex <= instr_id[19:15];
            rs2_ex <= instr_id[24:20]; rd_ex <= instr_id[11:7];
        end
    end

    // --- STAGE 3: EX (Execute + Forwarding) ---
    wire [1:0] forward_a, forward_b;
    reg reg_write_mem, mem_read_mem, mem_write_mem, mem_to_reg_mem;
    reg [31:0] alu_result_mem, write_data_mem;
    reg [4:0] rd_mem;

    forwarding_unit FWD_UNIT (
        .rs1_ex(rs1_ex), .rs2_ex(rs2_ex),
        .rd_mem(rd_mem), .reg_write_mem(reg_write_mem),
        .rd_wb(rd_wb), .reg_write_wb(reg_write_wb),
        .forward_a(forward_a), .forward_b(forward_b)
    );

    reg [31:0] alu_in_a, forwarded_b;
    always @(*) begin
        case (forward_a)
            2'b00: alu_in_a = read_data1_ex;
            2'b10: alu_in_a = alu_result_mem;
            2'b01: alu_in_a = write_back_data_wb;
            default: alu_in_a = read_data1_ex;
        endcase
        case (forward_b)
            2'b00: forwarded_b = read_data2_ex;
            2'b10: forwarded_b = alu_result_mem;
            2'b01: forwarded_b = write_back_data_wb;
            default: forwarded_b = read_data2_ex;
        endcase
    end

    wire [31:0] alu_in_b = (alu_src_ex) ? imm_ex : forwarded_b;
    wire [31:0] alu_result_ex;

    alu ALU_STAGE (
        .a(alu_in_a), .b(alu_in_b),
        .alu_control(alu_control_ex), .result(alu_result_ex)
    );

    // EX/MEM Pipeline Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_write_mem <= 0; mem_read_mem <= 0; mem_write_mem <= 0;
            mem_to_reg_mem <= 0; alu_result_mem <= 0; write_data_mem <= 0; rd_mem <= 0;
        end else begin
            reg_write_mem <= reg_write_ex; mem_read_mem <= mem_read_ex;
            mem_write_mem <= mem_write_ex; mem_to_reg_mem <= mem_to_reg_ex;
            alu_result_mem <= alu_result_ex; write_data_mem <= forwarded_b;
            rd_mem <= rd_ex;
        end
    end

    // --- STAGE 4: MEM (Memory Access) ---
    wire [31:0] mem_read_data_mem;
    dmem DMEM_STAGE (
        .clk(clk), .mem_write(mem_write_mem), .mem_read(mem_read_mem),
        .addr(alu_result_mem), .write_data(write_data_mem),
        .read_data(mem_read_data_mem)
    );

    // MEM/WB Pipeline Register
    reg mem_to_reg_wb;
    reg [31:0] alu_result_wb, mem_read_data_wb;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_write_wb <= 0; mem_to_reg_wb <= 0;
            alu_result_wb <= 0; mem_read_data_wb <= 0; rd_wb <= 0;
        end else begin
            reg_write_wb <= reg_write_mem; mem_to_reg_wb <= mem_to_reg_mem;
            alu_result_wb <= alu_result_mem; mem_read_data_wb <= mem_read_data_mem;
            rd_wb <= rd_mem;
        end
    end

    // --- STAGE 5: WB (Writeback) ---
    assign write_back_data_wb = (mem_to_reg_wb) ? mem_read_data_wb : alu_result_wb;

    // Debug Outputs
    assign pc_out = pc_if;
    assign alu_result_ex_out = alu_result_ex;
    assign forward_a_out = forward_a;
    assign forward_b_out = forward_b;
    assign stall_out = stall;
endmodule
