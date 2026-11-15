module imem (
    input [31:0] addr,
    output [31:0] instr
);
    // 64 இன்ஸ்ட்ரக்ஷன்ஸ் சேமிக்கிற மெமரி (ROM)
    reg [31:0] memory [0:63];

    // ஆரம்பத்துல 3 சாம்பிள் RISC-V இன்ஸ்ட்ரக்ஷன்ஸை உள்ள போடுறோம்
    initial begin
        memory[0] = 32'h00500093; // addi x1, x0, 5  (x1-ல 5 போடு)
        memory[1] = 32'h00A00113; // addi x2, x0, 10 (x2-ல 10 போடு)
        memory[2] = 32'h002081B3; // add  x3, x1, x2 (x3 = x1 + x2)
    end

    // அட்ரஸ் 4-ஆல பெருகுறதால கடைசி 2 பிட்டை விட்டுட்டு (addr[7:2]) படிக்கிறோம்
    assign instr = memory[addr[7:2]];
endmodule
