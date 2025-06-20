module IF(
    input clk,              
    input rst,             
    input branch_taken,          
    input [31:0] imm_ext,  
    output [31:0] instruction,
    output [31:0] PC_Out,   
    output [31:0] PC_plus4 
);
	wire [31:0] next_PC;
    wire [31:0] PC_branch;
    PC PC(.clk(clk),
		  .rst(rst),
		  .next_PC(next_PC),
		  .PC_Out(PC_Out));
    PCAdder PCAdder(.PC_in(PC_Out),
				    .PC_plus4(PC_plus4));
	BranchAdder BranchAdder(.PC_in(PC_Out),
				            .imm_ext(imm_ext),
				            .PC_branch(PC_branch));
    NextPCSel NextPCSel(.PC_plus4(PC_plus4), 
						.PC_branch(PC_branch), 
						.branch_taken(branch_taken),
					    .next_PC(next_PC));
    IMEM IMEM(.clk(clk),
			  .rst(rst),
			  .PC_Out(PC_Out), 
			  .instruction(instruction));
	
endmodule 