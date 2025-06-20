module MEM_WB (
    input clk, rst,
    input [31:0] PC_plus4_in, alu_out_in, read_data_in,
    input [4:0] addD_in,
    input RegWrite_in,
    input [1:0] ResultSrc_in,
    output reg [31:0] PC_plus4_out, alu_out_out, read_data_out,
    output reg [4:0] addD_out,
    output reg RegWrite_out,
    output reg [1:0] ResultSrc_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC_plus4_out <= 0; 
            alu_out_out <= 0; 
            read_data_out <= 0; 
            addD_out <= 0;
            RegWrite_out <= 0; 
            ResultSrc_out <= 0;
        end else begin
            PC_plus4_out <= PC_plus4_in; 
            alu_out_out <= alu_out_in; 
            read_data_out <= read_data_in;
            addD_out <= addD_in; 
            RegWrite_out <= RegWrite_in; 
            ResultSrc_out <= ResultSrc_in;
        end
    end
endmodule