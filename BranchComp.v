module BranchComp(
    input [6:0] op,            // opcode t? instruction
    input [2:0] funct3,        // funct3 t? instruction
    input [31:0] rs1_data,     // giá tr? t? thanh ghi rs1
    input [31:0] rs2_data,     // giá tr? t? thanh ghi rs2
    output reg branch_taken    // =1 n?u branch du?c th?c hi?n
);
    always @(*) begin
        // M?c d?nh không branch
        branch_taken = 1'b0;
        
        // Ch? ki?m tra khi là l?nh branch (opcode = 1100011)
        if (op == 7'b1100011) begin
            case (funct3)
                3'b000: branch_taken = (rs1_data == rs2_data);   // BEQ
                3'b001: branch_taken = (rs1_data != rs2_data);   // BNE
                3'b100: branch_taken = ($signed(rs1_data) < $signed(rs2_data)); // BLT
                3'b101: branch_taken = ($signed(rs1_data) >= $signed(rs2_data)); // BGE
                3'b110: branch_taken = (rs1_data < rs2_data);    // BLTU (unsigned)
                3'b111: branch_taken = (rs1_data >= rs2_data);   // BGEU (unsigned)
                default: branch_taken = 1'b0; // Cho các tru?ng h?p funct3 khác
            endcase
        end
    end
endmodule 