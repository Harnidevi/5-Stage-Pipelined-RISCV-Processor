module dmem (
    input clk,
    input mem_write,
    input mem_read,
    input [31:0] addr,
    input [31:0] write_data,
    output [31:0] read_data
);

    reg [31:0] ram [0:63];
    integer i;

    initial begin
        for (i = 0; i < 64; i = i + 1)
            ram[i] = 32'b0;
    end

   
    assign read_data = (mem_read) ? ram[addr[7:2]] : 32'b0;

 
    always @(posedge clk) begin
        if (mem_write) begin
            ram[addr[7:2]] <= write_data;
        end
    end
endmodule
