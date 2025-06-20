module HazardDetectionUnit (
    input [4:0] rs1_ID, rs2_ID, rd_EX,
    input MemRead_EX, branch_taken_ID, Branch_ID, Jump_ID,
    output reg stall, flush_ID, flush_EX
);
    always @(*) begin
        // Load-use hazard
        if (MemRead_EX && ((rd_EX == rs1_ID) || (rd_EX == rs2_ID)) && (rd_EX != 0)) begin
            stall = 1'b1;
            flush_ID = 1'b0;
            flush_EX = 1'b1;
        end
        // Control hazard (branch/jump taken)
        else if ((Branch_ID && branch_taken_ID) || Jump_ID) begin
            stall = 1'b0;
            flush_ID = 1'b1;
            flush_EX = 1'b1;
        end
        else begin
            stall = 1'b0;
            flush_ID = 1'b0;
            flush_EX = 1'b0;
        end
    end
endmodule
