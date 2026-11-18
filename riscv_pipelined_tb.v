module riscv_pipelined_tb;
    reg clk, reset;
    wire [31:0] pc_out, alu_result_ex_out;
    wire [1:0] forward_a_out, forward_b_out;
    wire stall_out;

    riscv_pipelined uut (
        .clk(clk), .reset(reset),
        .pc_out(pc_out), .alu_result_ex_out(alu_result_ex_out),
        .forward_a_out(forward_a_out), .forward_b_out(forward_b_out),
        .stall_out(stall_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("pipelined_cpu_wave.vcd");
        $dumpvars(0, riscv_pipelined_tb);

        clk = 0; reset = 1; #10;
        reset = 0; #80; 

        $finish;
    end
endmodule
