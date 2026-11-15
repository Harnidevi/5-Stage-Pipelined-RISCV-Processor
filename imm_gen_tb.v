`timescale 1ns / 1ps

module imm_gen_tb;
    reg [31:0] instr;
    wire [31:0] imm_out;

    imm_gen uut (
        .instr(instr), .imm_out(imm_out)
    );

    initial begin
        $dumpfile("imm_wave.vcd");
        $dumpvars(0, imm_gen_tb);

        // டெஸ்ட் 1: addi x1, x0, 5  (பதில் 5 வரணும்)
        instr = 32'h00500093; #10;

        // டெஸ்ட் 2: addi x2, x0, 10 (பதில் 10 / 0x0A வரணும்)
        instr = 32'h00A00113; #10;

        // டெஸ்ட் 3: addi x3, x0, -5 (மைனஸ் நம்பர்: பதில் FFFFFFFB வரணும்)
        instr = 32'hFFB00193; #10;

        $finish;
    end
endmodule
