module RegisterFile (
    input             clk, rst,
    input      [4:0]  addA, addB, addD,
    input      [31:0] WB_out,
    input             RegWrite,
    output     [31:0] dataA, dataB
);
    reg [31:0] regfile [0:31];
    integer i;
 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regfile[i] <= 32'b0;    // FIX: reset sạch, không hardcode
        end else begin
            if (RegWrite && (addD != 5'b0))  // FIX: bỏ else ghi regfile[0]
                regfile[addD] <= WB_out;
        end
    end
 
    // Combinational read, x0 luôn = 0
    assign dataA = (addA == 5'b0) ? 32'b0 : regfile[addA];
    assign dataB = (addB == 5'b0) ? 32'b0 : regfile[addB];
endmodule
