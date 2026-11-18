module forwarding_unit (
    input [4:0] rs1_ex,
    input [4:0] rs2_ex,
    input [4:0] rd_mem,
    input reg_write_mem,
    input [4:0] rd_wb,
    input reg_write_wb,
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);
    always @(*) begin
       
        if (reg_write_mem && (rd_mem != 0) && (rd_mem == rs1_ex))
            forward_a = 2'b10; 
        else if (reg_write_wb && (rd_wb != 0) && (rd_wb == rs1_ex))
            forward_a = 2'b01;
            forward_a = 2'b00;

        if (reg_write_mem && (rd_mem != 0) && (rd_mem == rs2_ex))
            forward_b = 2'b10;
        else if (reg_write_wb && (rd_wb != 0) && (rd_wb == rs2_ex))
            forward_b = 2'b01;
        else
            forward_b = 2'b00;
    end
endmodule

module hazard_detection_unit (
    input mem_read_ex,
    input [4:0] rd_ex,
    input [4:0] rs1_id,
    input [4:0] rs2_id,
    output reg stall
);
    always @(*) begin
        if (mem_read_ex && ((rd_ex == rs1_id) || (rd_ex == rs2_id)))
            stall = 1'b1; 
        else
            stall = 1'b0;
    end
endmodule
