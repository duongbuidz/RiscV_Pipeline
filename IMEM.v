module IMEM (
    input      [31:0] PC_Out,
    output     [31:0] instruction
);
    reg [31:0] imem [0:4095];    // 256 words = 1KB
 
    initial begin
        $readmemh("program.hex", imem);   // flex with file hex name
    end
 
    assign instruction = imem[PC_Out[13:2]]; // word-addressed, combinational
endmodule
