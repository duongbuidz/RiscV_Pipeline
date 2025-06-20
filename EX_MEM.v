module EX_MEM (
    input clk, rst,
    input [31:0] PC_in, alu_out_in, dataB_in,
    input [4:0] addD_in,
    input [2:0] funct3_in,
    input RegWrite_in, MemWrite_in, MemRead_in,
    input [1:0] ResultSrc_in,
    output reg [31:0] PC_out, alu_out_out, dataB_out,
    output reg [4:0] addD_out,
    output reg [2:0] funct3_out,
    output reg RegWrite_out, MemWrite_out, MemRead_out,
    output reg [1:0] ResultSrc_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC_out <= 0; 
            alu_out_out <= 0; 
            dataB_out <= 0; 
            addD_out <= 0; 
            funct3_out <= 0;
            RegWrite_out <= 0; 
            MemWrite_out <= 0; MemRead_out <= 0; 
            ResultSrc_out <= 0;
        end else begin
            PC_out <= PC_in; 
            alu_out_out <= alu_out_in; 
            dataB_out <= dataB_in;
            addD_out <= addD_in; 
            funct3_out <= funct3_in; 
            RegWrite_out <= RegWrite_in;
            MemWrite_out <= MemWrite_in; 
            MemRead_out <= MemRead_in; 
            ResultSrc_out <= ResultSrc_in;
        end
    end
endmodule