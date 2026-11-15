`timescale 1ns / 1ps

module riscv_single_tb;
    reg clk, reset;
    wire [31:0] pc_out, alu_result_out;

    riscv_single uut (
        .clk(clk), .reset(reset),
        .pc_out(pc_out), .alu_result_out(alu_result_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("single_cpu_wave.vcd");
        $dumpvars(0, riscv_single_tb);

        clk = 0; reset = 1; #10; // CPU ரீசெட்
        reset = 0; #40;          // 4 கிளாக் சைக்கிள் ஓட விடுறோம்

        $finish;
    end
endmodule
