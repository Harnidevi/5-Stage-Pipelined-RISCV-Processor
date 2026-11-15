`timescale 1ns / 1ps

module alu_tb;
    reg [31:0] a, b;
    reg [2:0] alu_control;
    wire [31:0] result;

    alu uut (
        .a(a), .b(b), .alu_control(alu_control), .result(result)
    );

    initial begin
        $dumpfile("alu_wave.vcd");
        $dumpvars(0, alu_tb);

        a = 32'd10; b = 32'd20; alu_control = 3'b000; #10;
        a = 32'd50; b = 32'd15; alu_control = 3'b001; #10;
        a = 32'd12; b = 32'd10; alu_control = 3'b010; #10;

        $finish;
    end
endmodule

