module pc_tb;
    reg clk;
    reg reset;
    wire [31:0] pc_current;
    wire [31:0] pc_next;

    assign pc_next = pc_current + 32'd4;

    pc uut (
        .clk(clk), .reset(reset),
        .pc_next(pc_next), .pc_current(pc_current)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("pc_wave.vcd");
        $dumpvars(0, pc_tb);

        clk = 0; reset = 1; #10; 
        reset = 0; #40;         

        $finish;
    end
endmodule
