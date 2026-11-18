

module mem_tb;
    reg clk, mem_write, mem_read;
    reg [31:0] addr, write_data;
    wire [31:0] instr, read_data;

    imem uut_imem (.addr(addr), .instr(instr));
    dmem uut_dmem (
        .clk(clk), .mem_write(mem_write), .mem_read(mem_read),
        .addr(addr), .write_data(write_data), .read_data(read_data)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("mem_wave.vcd");
        $dumpvars(0, mem_tb);

        clk = 0; mem_write = 0; mem_read = 0; addr = 0; write_data = 0; #10;

        addr = 32'd0; #10;
        addr = 32'd4; #10;
        addr = 32'd8; #10;

        addr = 32'd16; write_data = 32'd555; mem_write = 1; #10;

        mem_write = 0; mem_read = 1; #10;

        $finish;
    end
endmodule
