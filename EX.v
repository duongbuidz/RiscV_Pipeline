module EX(
    // Inputs from ID stage
    input [31:0] dataA,          // Data from register rs1
    input [31:0] dataB,          // Data from register rs2
    input [31:0] imm_ext,        // Sign-extended immediate
    input [31:0] PC,             // Program Counter (for AUIPC)
    input [31:0] instruction,    // Full instruction
    
    // Control signals from ID stage
    input [1:0] ALUOp,
    input ALUSrc,
    input Branch,
    
    // Outputs
    output [31:0] alu_result,    // ALU computation result
    output [31:0] mem_write_data,// DataB to memory (for store)
    output branch_taken,         // Branch decision
    output [31:0] pc_target      // Calculated PC target for jumps/branches
);

    // Internal signals
    wire [3:0] alu_control;
    wire [31:0] alu_operand_b;
    
    // ALU Control Unit
    ALUControl ALU_Control(
        .ALUOp(ALUOp),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .op(instruction[6:0]),
        .ALUControl(alu_control)
    );
    
    // ALU input selection mux
    MUX alu_input_mux(
        .input0(dataB),
        .input1(imm_ext),
        .select(ALUSrc),
        .out(alu_operand_b)
    );
    
    // Main ALU
    ALU main_ALU(
        .A(dataA),
        .B(alu_operand_b),
        .ALUControl(alu_control),
        .alu_out(alu_result)
    );
    
    // Branch Comparator
    BranchComp branch_comparator(
        .op(instruction[6:0]),
        .funct3(instruction[14:12]),
        .rs1_data(dataA),
        .rs2_data(dataB),
        .branch_taken(branch_taken)
    );
    
    // Calculate PC target (for jumps/branches)
    assign pc_target = PC + imm_ext;
    
    // Data to memory (for store instructions)
    assign mem_write_data = dataB;

endmodule