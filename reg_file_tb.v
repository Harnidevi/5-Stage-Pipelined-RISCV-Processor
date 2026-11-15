`timescale 1ns / 1ps

module reg_file_tb;
    reg clk;
    reg reg_write;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] write_data;
    wire [31:0] read_data1, read_data2;

    reg_file uut (
        .clk(clk), .reg_write(reg_write),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .write_data(write_data),
        .read_data1(read_data1), .read_data2(read_data2)
    );

   
    always #5 clk = ~clk;

    initial begin
        $dumpfile("reg_wave.vcd");
        $dumpvars(0, reg_file_tb);

        clk = 0; reg_write = 0; rs1 = 0; rs2 = 0; rd = 0; write_data = 0;
        #10;

        reg_write = 1; rd = 5'd5; write_data = 32'd100; #10;

        
        rd = 5'd10; write_data = 32'd250; #10;

       
        rd = 5'd0; write_data = 32'd999; #10;

        reg_write = 0; rs1 = 5'd5; rs2 = 5'd10; #10;

        
        rs1 = 5'd0; #10;

        $finish;
    end
endmodule
