module riscv_single (
    input clk,
    input reset,
    output [31:0] pc_out,
    output [31:0] alu_result_out
);
    // உள்ளே இருக்கிற பாகங்களை இணைக்கிற வயர்கள் (Wires)
    wire [31:0] pc_current, pc_next, pc_plus_4, pc_branch;
    wire [31:0] instr, imm_out;
    wire [31:0] read_data1, read_data2, alu_b, alu_result, mem_read_data, write_back_data;
    wire reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, zero_flag, pc_src;
    wire [2:0] alu_control;

    // 1. Program Counter (PC)
    assign pc_plus_4 = pc_current + 32'd4;
    assign pc_branch = pc_current + imm_out;
    assign zero_flag = (alu_result == 32'b0);
    assign pc_src    = branch & zero_flag;
    assign pc_next   = (pc_src) ? pc_branch : pc_plus_4;

    pc PC_UNIT (
        .clk(clk), .reset(reset),
        .pc_next(pc_next), .pc_current(pc_current)
    );

    // 2. Instruction Memory
    imem IMEM_UNIT (
        .addr(pc_current), .instr(instr)
    );

    // 3. Control Unit
    control_unit CTRL_UNIT (
        .opcode(instr[6:0]), .funct3(instr[14:12]), .funct7_5(instr),
        .reg_write(reg_write), .alu_src(alu_src), .mem_read(mem_read),
        .mem_write(mem_write), .mem_to_reg(mem_to_reg), .branch(branch),
        .alu_control(alu_control)
    );

    // 4. Register File
    reg_file REG_UNIT (
        .clk(clk), .reg_write(reg_write),
        .rs1(instr[19:15]), .rs2(instr[24:20]), .rd(instr[11:7]),
        .write_data(write_back_data),
        .read_data1(read_data1), .read_data2(read_data2)
    );

    // 5. Immediate Generator
    imm_gen IMM_UNIT (
        .instr(instr), .imm_out(imm_out)
    );

    // 6. ALU
    assign alu_b = (alu_src) ? imm_out : read_data2;

    alu ALU_UNIT (
        .a(read_data1), .b(alu_b),
        .alu_control(alu_control), .result(alu_result)
    );

    // 7. Data Memory & Writeback
    dmem DMEM_UNIT (
        .clk(clk), .mem_write(mem_write), .mem_read(mem_read),
        .addr(alu_result), .write_data(read_data2), .read_data(mem_read_data)
    );

    assign write_back_data = (mem_to_reg) ? mem_read_data : alu_result;

    // அவுட்புட் பார்க்க வெளியே அனுப்புறோம்
    assign pc_out = pc_current;
    assign alu_result_out = alu_result;
endmodule
