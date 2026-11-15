`timescale 1ns / 1ps

module control_unit_tb;
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg funct7_5;
    wire reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch;
    wire [2:0] alu_control;

    control_unit uut (
        .opcode(opcode), .funct3(funct3), .funct7_5(funct7_5),
        .reg_write(reg_write), .alu_src(alu_src), .mem_read(mem_read),
        .mem_write(mem_write), .mem_to_reg(mem_to_reg), .branch(branch),
        .alu_control(alu_control)
    );

    initial begin
        $dumpfile("ctrl_wave.vcd");
        $dumpvars(0, control_unit_tb);

        // டெஸ்ட் 1: ADD இன்ஸ்ட்ரக்ஷன் (reg_write=1, alu_control=000)
        opcode = 7'b0110011; funct3 = 3'b000; funct7_5 = 0; #10;

        // டெஸ்ட் 2: SUB இன்ஸ்ட்ரக்ஷன் (reg_write=1, alu_control=001)
        opcode = 7'b0110011; funct3 = 3'b000; funct7_5 = 1; #10;

        // டெஸ்ட் 3: LW - Load Word (mem_read=1, mem_to_reg=1)
        opcode = 7'b0000011; funct3 = 3'b010; funct7_5 = 0; #10;

        // டெஸ்ட் 4: BEQ - Branch (branch=1, alu_control=001)
        opcode = 7'b1100011; funct3 = 3'b000; funct7_5 = 0; #10;

        $finish;
    end
endmodule
