module IMEM (
	input clk,
	input rst,
    input [31:0] PC_Out,
    output [31:0] instruction
);
    reg [31:0] imem [0:255];
    integer k;
    always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (k = 0; k < 256; k = k + 1) begin 
            imem[k] = 32'b0;  
        end
    end 
    else begin
        
		imem[0] = 32'b0000000000000000000000000000000 ;       // nop
        imem[1] = 32'b0100000_00011_01000_000_00101_0110011;     // sub x5, x8, x3
        imem[2] = 32'b000000000010_10101_000_10110_0010011;    // addi x22, x21, 2
        imem[3]= 32'b000000001111_00010_010_01000_0000011;    // lw x8, 15(x2)
		imem[4]= 32'b0000000_01110_00110_010_01100_0100011;     // sw x14, 12(x6), x6 = 44   
		imem[5]= 32'b0_000000_01001_01001_000_0110_0_1100011; // beq x9, x9, 12, (PC + 12 if x9 = x9 
		end
end 
assign instruction = imem[PC_Out[31:2]];
endmodule 