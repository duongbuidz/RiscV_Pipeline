module IMEM (
    input      [31:0] PC_Out,
    output     [31:0] instruction
);
    reg [31:0] imem [0:255];    // 256 words = 1KB
 
    initial begin
        $readmemh("program.hex", imem);   // FIX: load từ file
    end
 
    assign instruction = imem[PC_Out[9:2]]; // word-addressed, combinational
endmodule
