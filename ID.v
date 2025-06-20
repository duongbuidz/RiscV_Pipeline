module ID(
    input clk,
    input rst,
    input [31:0] instruction,  
    input [31:0] WB_out,            
    
    output RegWrite,    
    output ALUSrc,
    output MemWrite,
    output MemRead,
    output ResultSrc,
    output Branch,
    output [1:0] ALUOp,
    output [2:0]imm_sel,
    
    output [31:0] dataA,       
    output [31:0] dataB,   
    output [31:0] dataD,    
    output [31:0] imm_ext,  
    output [4:0] rs1, rs2,   
    output [4:0] rd            
);

    // Control Unit
    ControlUnit ControlUnit (
        .op(instruction[6:0]),
        .RegWrite(RegWrite),        
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .ALUOp(ALUOp),
        .imm_sel(imm_sel)
    );

    // Register File
    RegisterFile reg_unit(
        .clk(clk),
        .rst(rst),
        .addA(instruction[19:15]), // rs1
        .addB(instruction[24:20]), // rs2
        .addD(instruction[11:7]),  // rd
        .WB_out(WB_out),
        .RegWrite(RegWrite),
        .dataA(dataA),
        .dataB(dataB),
        .dataD(dataD)
    );

    // Immediate Generator
    ImmGen ImmGen(
        .instruction(instruction),  
        .imm_sel(imm_sel),     
        .imm_ext(imm_ext)
    );
    assign rd = instruction[11:7];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];

endmodule