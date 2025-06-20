module NextPCSel(
    input [31:0] PC_plus4,
    input [31:0] PC_branch, // T? ALU (PC + imm ho?c rs1 + imm)
    input Branch, Jump, // Thêm Jump
    input branch_taken,
    output [31:0] next_PC
);
    assign next_PC = (Branch && branch_taken) || Jump ? PC_branch : PC_plus4;
endmodule