module ForwardingUnit (
    input [4:0] rs1_EX, rs2_EX, rd_MEM, rd_WB,
    input RegWrite_EX, RegWrite_MEM, RegWrite_WB,
    output reg [1:0] forwardA, forwardB
);
    always @(*) begin
        // Forward A
        if (RegWrite_MEM && (rd_MEM != 0) && (rd_MEM == rs1_EX))
            forwardA = 2'b01; // From EX/MEM (alu_out_MEM)
        else if (RegWrite_WB && (rd_WB != 0) && (rd_WB == rs1_EX))
            forwardA = 2'b00; // From MEM/WB (WB_out_WB)
        else
            forwardA = 2'b10; // From ID/EX (dataA_EX)
        // Forward B
        if (RegWrite_MEM && (rd_MEM != 0) && (rd_MEM == rs2_EX))
            forwardB = 2'b01; // From EX/MEM
        else if (RegWrite_WB && (rd_WB != 0) && (rd_WB == rs2_EX))
            forwardB = 2'b00; // From MEM/WB
        else
            forwardB = 2'b10; // From ID/EX
    end
endmodule