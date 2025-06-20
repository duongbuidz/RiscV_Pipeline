module ID_EX (
    input clk, rst, flush,
    input [31:0] PC_in, dataA_in, dataB_in, imm_ext_in,
    input [4:0] addA_in, addB_in, addD_in,
    input [2:0] funct3_in,
    input RegWrite_in, ALUSrc_in, ALUSrc_pc_in, MemWrite_in, MemRead_in, Branch_in, Jump_in,
    input [1:0] ResultSrc_in, ALUOp_in,
    output reg [31:0] PC_out, dataA_out, dataB_out, imm_ext_out,
    output reg [4:0] addA_out, addB_out, addD_out,
    output reg [2:0] funct3_out,
    output reg RegWrite_out, ALUSrc_out, ALUSrc_pc_out, MemWrite_out, MemRead_out, Branch_out, Jump_out,
    output reg [1:0] ResultSrc_out, ALUOp_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC_out <= 0; dataA_out <= 0; dataB_out <= 0; imm_ext_out <= 0;
            addA_out <= 0; addB_out <= 0; addD_out <= 0; funct3_out <= 0;
            RegWrite_out <= 0; ALUSrc_out <= 0; ALUSrc_pc_out <= 0; MemWrite_out <= 0; MemRead_out <= 0;
            ResultSrc_out <= 1; Branch_out <= 0; Jump_out <= 0; ALUOp_out <= 0; end
        else 
        if (flush) begin
        PC_out <= 0; dataA_out <= 0; dataB_out <= 0; imm_ext_out <= 0;
            addA_out <= 0; addB_out <= 0; addD_out <= 0; funct3_out <= 0;
            RegWrite_out <= 0; ALUSrc_out <= 0; ALUSrc_pc_out <= 0; MemWrite_out <= 0; MemRead_out <= 0;
            ResultSrc_out <= 1; Branch_out <= 0; Jump_out <= 0; ALUOp_out <= 0;
        end
        else begin
            PC_out <= PC_in;
            dataA_out <= dataA_in; 
            dataB_out <= dataB_in;
            imm_ext_out <= imm_ext_in; 
            addA_out <= addA_in; 
            addB_out <= addB_in; 
            addD_out <= addD_in;
            funct3_out <= funct3_in; 
            RegWrite_out <= RegWrite_in; 
            ALUSrc_out <= ALUSrc_in;
            ALUSrc_pc_out <= ALUSrc_pc_in; 
            MemWrite_out <= MemWrite_in; 
            MemRead_out <= MemRead_in;
            ResultSrc_out <= ResultSrc_in; 
            Branch_out <= Branch_in; 
            Jump_out <= Jump_in; 
            ALUOp_out <= ALUOp_in;
        end
    end
endmodule
