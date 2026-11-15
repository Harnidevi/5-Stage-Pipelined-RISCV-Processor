module control_unit (
    input [6:0] opcode,
    input [2:0] funct3,
    input funct7_5,
    output reg reg_write,
    output reg alu_src,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg branch,
    output reg [2:0] alu_control
);
    always @(*) begin
        // ஆரம்பத்துல எல்லா சிக்னலையும் 0 ஆக்குறோம்
        reg_write = 0; alu_src = 0; mem_read = 0;
        mem_write = 0; mem_to_reg = 0; branch = 0;
        alu_control = 3'b000;

        case (opcode)
            // R-Type (ADD, SUB, AND, OR)
            7'b0110011: begin
                reg_write = 1;
                case (funct3)
                    3'b000: alu_control = (funct7_5) ? 3'b001 : 3'b000; // SUB or ADD
                    3'b111: alu_control = 3'b010; // AND
                    3'b110: alu_control = 3'b011; // OR
                    default: alu_control = 3'b000;
                endcase
            end

            // I-Type (ADDI)
            7'b0010011: begin
                reg_write = 1;
                alu_src = 1;
                alu_control = 3'b000; // ADD
            end

            // Load Word (LW)
            7'b0000011: begin
                reg_write = 1;
                alu_src = 1;
                mem_read = 1;
                mem_to_reg = 1;
                alu_control = 3'b000; // ADD address
            end

            // Store Word (SW)
            7'b0100011: begin
                alu_src = 1;
                mem_write = 1;
                alu_control = 3'b000; // ADD address
            end

            // Branch (BEQ)
            7'b1100011: begin
                branch = 1;
                alu_control = 3'b001; // SUB to compare
            end
        endcase
    end
endmodule
