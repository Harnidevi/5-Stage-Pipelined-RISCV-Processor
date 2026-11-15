module imm_gen (
    input [31:0] instr,
    output reg [31:0] imm_out
);
    // இன்ஸ்ட்ரக்ஷனோட கடைசி 7 பிட் தான் Opcode
    wire [6:0] opcode = instr[6:0];

    always @(*) begin
        case (opcode)
            // I-Type (ADDI, LW): பிட் [31:20]-ல இருக்கிற 12-பிட் நம்பரை எடுக்குறோம்
            7'b0010011, 7'b0000011: 
                imm_out = {{20{instr[31]}}, instr[31:20]};

            // S-Type (SW - Store Word): பிரிஞ்சு இருக்கிற 12 பிட்டை ஒண்ணா சேர்க்குறோம்
            7'b0100011: 
                imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-Type (BEQ - Branch): ஜம்ப் பண்ற அட்ரஸ் நம்பரை எடுக்குறோம்
            7'b1100011: 
                imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

            default: 
                imm_out = 32'b0;
        endcase
    end
endmodule
