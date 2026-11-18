

module imm_gen_tb;
    reg [31:0] instr;
    wire [31:0] imm_out;

    imm_gen uut (
        .instr(instr), .imm_out(imm_out)
    );

    initial begin
        $dumpfile("imm_wave.vcd");
        $dumpvars(0, imm_gen_tb);

     
        instr = 32'h00500093; #10;

 
        instr = 32'h00A00113; #10;

  
        instr = 32'hFFB00193; #10;

        $finish;
    end
endmodule
