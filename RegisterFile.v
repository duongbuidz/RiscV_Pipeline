module RegisterFile (
    input clk,
    input rst,
    input [4:0] addA, addB, addD,
    input [31:0] WB_out,
    input RegWrite,
    output [31:0] dataA, dataB, dataD
);

    reg [31:0] regfile[0:31];
    integer t;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all
            regfile[0] <= 32'h00000000;  
            regfile[1] <= 32'h00000003;
            regfile[2] <= 32'h00000002;
            regfile[3] <= 32'h0000000C;
            regfile[4] <= 32'h00000014;
            regfile[5] <= 32'h00000003;
            regfile[6] <= 32'h0000002C;
            regfile[7] <= 32'h00000004;
            regfile[8] <= 32'h00000002;
            regfile[9] <= 32'h00000001;
            regfile[10] <= 32'h00000017;
            regfile[11] <= 32'h00000004;
            regfile[12] <= 32'h0000005A;
            regfile[13] <= 32'h0000000A;
            regfile[14] <= 32'h00000014;
            regfile[15] <= 32'h0000001E;
            regfile[16] <= 32'h00000028;
            regfile[17] <= 32'h00000032;
            regfile[18] <= 32'h0000003C;
            regfile[19] <= 32'h00000046;
            regfile[20] <= 32'h00000050;
            regfile[21] <= 32'h00000050;
            regfile[22] <= 32'h0000005A;
            regfile[23] <= 32'h00000046;
            regfile[24] <= 32'h0000003C;
            regfile[25] <= 32'h00000041;
            regfile[26] <= 32'h00000004;
            regfile[27] <= 32'h00000020;
            regfile[28] <= 32'h0000000C;
            regfile[29] <= 32'h00000022;
            regfile[30] <= 32'h00000005;
            regfile[31] <= 32'h0000000A;
        end
        else begin
            
            regfile[0] <= 32'h00000000;

            // k ghi de x0
            if (RegWrite && (addD != 0)) begin
                regfile[addD] <= WB_out;
            end
        end
    end 
    
    assign dataA = (addA == 0) ? 32'h0 : regfile[addA]; // Ð?c t? h?p
    assign dataB = (addB == 0) ? 32'h0 : regfile[addB]; // Ð?c t? h?p
    assign dataD = regfile[addD];

endmodule
