module ForwardingUnit (
    input  [4:0] rs1_EX, rs2_EX,
    input  [4:0] rd_MEM, rd_WB,
    input        RegWrite_MEM, RegWrite_WB,   // FIX: bỏ RegWrite_EX
    output reg [1:0] forwardA, forwardB
);
    always @(*) begin
        // --- Forward A ---
        // EX/MEM ưu tiên hơn MEM/WB
        if (RegWrite_MEM && (rd_MEM != 5'd0) && (rd_MEM == rs1_EX))
            forwardA = 2'b10;   // FIX: input2 = alu_out_MEM
        else if (RegWrite_WB && (rd_WB != 5'd0) && (rd_WB == rs1_EX))
            forwardA = 2'b01;   // FIX: input1 = WB_out_WB
        else
            forwardA = 2'b00;   // FIX: input0 = dataA_EX (no forward)
 
        // --- Forward B ---
        if (RegWrite_MEM && (rd_MEM != 5'd0) && (rd_MEM == rs2_EX))
            forwardB = 2'b10;
        else if (RegWrite_WB && (rd_WB != 5'd0) && (rd_WB == rs2_EX))
            forwardB = 2'b01;
        else
            forwardB = 2'b00;
    end
endmodule
