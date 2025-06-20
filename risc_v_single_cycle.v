module risc_v_single_cycle (
    input clk, rst
);

// --- Wires cho pipeline ---
wire [31:0] PC_Out, next_PC, PC_plus4, instruction;
wire [31:0] PC_IF, instruction_IF; 
wire [31:0] PC_ID, PC_plus4_ID, instruction_ID; 
wire [31:0] dataA_ID, dataB_ID, imm_ext_ID;
wire [4:0] addA_ID, addB_ID, addD_ID;
wire [2:0] funct3_ID;
wire RegWrite_ID, ALUSrc_ID, ALUSrc_pc_ID, MemWrite_ID, MemRead_ID, Branch_ID, Jump_ID;
wire [1:0] ResultSrc_ID, ALUOp_ID;
wire [2:0] ImmSrc_ID;
wire branch_taken_ID;
wire [31:0] PC_EX, PC_plus4_EX, dataA_EX, dataB_EX, imm_ext_EX;
wire [4:0] addA_EX, addB_EX, addD_EX;
wire [2:0] funct3_EX;
wire RegWrite_EX, ALUSrc_EX, ALUSrc_pc_EX, MemWrite_EX, MemRead_EX, Branch_EX, Jump_EX;
wire [1:0] ResultSrc_EX, ALUOp_EX;
wire [3:0] ALUControl_EX;
wire [31:0] alu_out_EX, dataB_forwarded_EX;
wire [31:0] PC_MEM, PC_plus4_MEM, alu_out_MEM, dataB_MEM;
wire [4:0] addD_MEM;
wire [2:0] funct3_MEM;
wire RegWrite_MEM, MemWrite_MEM, MemRead_MEM;
wire [1:0] ResultSrc_MEM;
wire [31:0] read_data_MEM;
wire [31:0] PC_plus4_WB, alu_out_WB, read_data_WB, WB_out_WB;
wire [4:0] addD_WB;
wire RegWrite_WB;
wire [1:0] ResultSrc_WB;

// --- Hazard và Control signals ---
wire stall, flush_ID, flush_EX;
wire [1:0] forwardA, forwardB;

// --- IF Stage ---
PC pc(.clk(clk), .rst(rst), .next_PC(next_PC), .PC_Out(PC_Out));
PCAdder pc_adder(.PC_in(PC_Out), .PC_plus4(PC_plus4));
IMEM imem(.clk(clk), .rst(rst), .PC_Out(PC_Out), .instruction(instruction));
assign PC_IF = (stall) ? PC_Out : PC_plus4; // Stall gi? PC
NextPCSel next_pc_sel(.PC_plus4(PC_plus4), .PC_branch(alu_out_EX), .Branch(Branch_EX),
                      .Jump(Jump_EX), .branch_taken(branch_taken_ID), .next_PC(next_PC));

// --- IF/ID Pipeline Register ---
IF_ID if_id(.clk(clk), .rst(rst), .stall(stall), .flush(flush_ID),
            .instruction_in(instruction), .PC_in(PC_Out), .instruction_out(instruction_ID), .PC_out(PC_ID));

// --- ID Stage ---
ControlUnit control_unit(.op(instruction_ID[6:0]), .RegWrite(RegWrite_ID), .ALUSrc(ALUSrc_ID),
                        .ALUSrc_pc(ALUSrc_pc_ID), .MemWrite(MemWrite_ID), .MemRead(MemRead_ID),
                        .ResultSrc(ResultSrc_ID), .Branch(Branch_ID), .Jump(Jump_ID),
                        .ALUOp(ALUOp_ID), .imm_sel(ImmSrc_ID));
RegisterFile reg_file(.clk(clk), .rst(rst), .addA(instruction_ID[19:15]), .addB(instruction_ID[24:20]),
                      .addD(instruction_ID[11:7]), .WB_out(WB_out_WB), .RegWrite(RegWrite_WB),
                      .dataA(dataA_ID), .dataB(dataB_ID));
ImmGen imm_gen(.instruction(instruction_ID), .imm_sel(ImmSrc_ID), .imm_ext(imm_ext_ID));
BranchComp branch_comp(.op(instruction_ID[6:0]), .funct3(instruction_ID[14:12]),
                       .rs1_data(dataA_ID), .rs2_data(dataB_ID), .branch_taken(branch_taken_ID));
assign addA_ID = instruction_ID[19:15];
assign addB_ID = instruction_ID[24:20];
assign addD_ID = instruction_ID[11:7];
assign funct3_ID = instruction_ID[14:12];

// --- ID/EX Pipeline Register ---
ID_EX id_ex(.clk(clk), .rst(rst), .flush(flush_EX),
            .PC_in(PC_ID), .dataA_in(dataA_ID), .dataB_in(dataB_ID),
            .imm_ext_in(imm_ext_ID), .addA_in(addA_ID), .addB_in(addB_ID), .addD_in(addD_ID),
            .funct3_in(funct3_ID), .RegWrite_in(RegWrite_ID), .ALUSrc_in(ALUSrc_ID),
            .ALUSrc_pc_in(ALUSrc_pc_ID), .MemWrite_in(MemWrite_ID), .MemRead_in(MemRead_ID),
            .ResultSrc_in(ResultSrc_ID), .Branch_in(Branch_ID), .Jump_in(Jump_ID), .ALUOp_in(ALUOp_ID),
            .PC_out(PC_EX), .dataA_out(dataA_EX), .dataB_out(dataB_EX),
            .imm_ext_out(imm_ext_EX), .addA_out(addA_EX), .addB_out(addB_EX), .addD_out(addD_EX),
            .funct3_out(funct3_EX), .RegWrite_out(RegWrite_EX), .ALUSrc_out(ALUSrc_EX),
            .ALUSrc_pc_out(ALUSrc_pc_EX), .MemWrite_out(MemWrite_EX), .MemRead_out(MemRead_EX),
            .ResultSrc_out(ResultSrc_EX), .Branch_out(Branch_EX), .Jump_out(Jump_EX), .ALUOp_out(ALUOp_EX));

// --- EX Stage ---
ALUControl alu_control(.ALUOp(ALUOp_EX), .funct3(funct3_EX), .funct7(instruction_ID[31:25]),
                       .op(instruction_ID[6:0]), .ALUControl(ALUControl_EX));
wire [31:0] alu_A, alu_B, forwardA_data, forwardB_data;
MUX3 mux_forwardA(.input0(dataA_EX), .input1(WB_out_WB), .input2(alu_out_MEM),
                  .select(forwardA), .out(forwardA_data));
MUX3 mux_forwardB(.input0(dataB_EX), .input1(WB_out_WB), .input2(alu_out_MEM),
                  .select(forwardB), .out(forwardB_data));
MUX2 mux_alu1(.input0(forwardA_data), .input1(PC_EX), .select(ALUSrc_pc_EX), .out(alu_A));
MUX2 mux_alu2(.input0(forwardB_data), .input1(imm_ext_EX), .select(ALUSrc_EX), .out(alu_B));
ALU alu(.A(alu_A), .B(alu_B), .ALUControl(ALUControl_EX), .alu_out(alu_out_EX));
assign dataB_forwarded_EX = forwardB_data;

// --- Forwarding Unit ---
ForwardingUnit forwarding_unit(.rs1_EX(addA_EX), .rs2_EX(addB_EX), .rd_MEM(addD_MEM),
                               .rd_WB(addD_WB), .RegWrite_MEM(RegWrite_MEM), .RegWrite_WB(RegWrite_WB),
                               .forwardA(forwardA), .forwardB(forwardB));

// --- EX/MEM Pipeline Register ---
EX_MEM ex_mem(.clk(clk), .rst(rst),
              .PC_in(PC_EX), .alu_out_in(alu_out_EX), .dataB_in(dataB_forwarded_EX),
              .addD_in(addD_EX), .funct3_in(funct3_EX), .RegWrite_in(RegWrite_EX),
              .MemWrite_in(MemWrite_EX), .MemRead_in(MemRead_EX), .ResultSrc_in(ResultSrc_EX),
              .PC_out(PC_MEM), .alu_out_out(alu_out_MEM),
              .dataB_out(dataB_MEM), .addD_out(addD_MEM), .funct3_out(funct3_MEM),
              .RegWrite_out(RegWrite_MEM), .MemWrite_out(MemWrite_MEM), .MemRead_out(MemRead_MEM),
              .ResultSrc_out(ResultSrc_MEM));

// --- MEM Stage ---
DMEM dmem(.clk(clk), .rst(rst), .MemRead(MemRead_MEM), .MemWrite(MemWrite_MEM),
          .funct3(funct3_MEM), .address(alu_out_MEM), .write_data(dataB_MEM), .read_data(read_data_MEM));
PCAdder pc_adder2(.PC_in(PC_MEM), .PC_plus4(PC_plus4_MEM));

// --- MEM/WB Pipeline Register ---
MEM_WB mem_wb(.clk(clk), .rst(rst),
              .PC_plus4_in(PC_plus4_MEM), .alu_out_in(alu_out_MEM), .read_data_in(read_data_MEM),
              .addD_in(addD_MEM), .RegWrite_in(RegWrite_MEM), .ResultSrc_in(ResultSrc_MEM),
              .PC_plus4_out(PC_plus4_WB), .alu_out_out(alu_out_WB), .read_data_out(read_data_WB),
              .addD_out(addD_WB), .RegWrite_out(RegWrite_WB), .ResultSrc_out(ResultSrc_WB));

// --- WB Stage ---
MUX3 mux_wb(.input0(alu_out_WB), .input1(read_data_WB), .input2(PC_plus4_WB),
            .select(ResultSrc_WB), .out(WB_out_WB));

// --- Hazard Detection Unit ---
HazardDetectionUnit hazard_detection(.rs1_ID(addA_ID), .rs2_ID(addB_ID), .rd_EX(addD_EX),
                                    .MemRead_EX(MemRead_EX), .branch_taken_ID(branch_taken_ID),
                                    .Branch_ID(Branch_ID), .Jump_ID(Jump_ID),
                                    .stall(stall), .flush_ID(flush_ID), .flush_EX(flush_EX));

endmodule