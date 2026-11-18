module imem (
    input [31:0] addr,
    output [31:0] instr
);
   
    reg [31:0] memory [0:63];

    initial begin
        memory[0] = 32'h00500093; 
        memory[1] = 32'h00A00113; 
        memory[2] = 32'h002081B3; 
    end

   
    assign instr = memory[addr[7:2]];
endmodule
