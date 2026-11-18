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
    
        reg_write = 0; alu_src = 0; mem_read = 0;
        mem_write = 0; mem_to_reg = 0; branch = 0;
        alu_control = 3'b000;

        case (opcode)
            
            7'b0110011: begin
                reg_write = 1;
                case (funct3)
                    3'b000: alu_control = (funct7_5) ? 3'b001 : 3'b000; 
                    3'b111: alu_control = 3'b010; 
                    3'b110: alu_control = 3'b011; 
                    default: alu_control = 3'b000;
                endcase
            end

            
            7'b0010011: begin
                reg_write = 1;
                alu_src = 1;
                alu_control = 3'b000; 
            end

        
            7'b0000011: begin
                reg_write = 1;
                alu_src = 1;
                mem_read = 1;
                mem_to_reg = 1;
                alu_control = 3'b000; 
            end

            
            7'b0100011: begin
                alu_src = 1;
                mem_write = 1;
                alu_control = 3'b000;
            end

            
            7'b1100011: begin
                branch = 1;
                alu_control = 3'b001; 
            end
        endcase
    end
endmodule
