`timescale 1ns / 1ps

module pc_tb;
    reg clk;
    reg reset;
    wire [31:0] pc_current;
    wire [31:0] pc_next;

    // ஒவ்வொரு தடவையும் அட்ரஸ் 4-ஆக கூடும் (0 -> 4 -> 8 -> 12)
    assign pc_next = pc_current + 32'd4;

    pc uut (
        .clk(clk), .reset(reset),
        .pc_next(pc_next), .pc_current(pc_current)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("pc_wave.vcd");
        $dumpvars(0, pc_tb);

        clk = 0; reset = 1; #10; // முதல்ல 0-க்கு ரீசெட் பண்றோம்
        reset = 0; #40;          // 40ns ஓட விடுறோம் (0, 4, 8, 12, 16 போகும்)

        $finish;
    end
endmodule
