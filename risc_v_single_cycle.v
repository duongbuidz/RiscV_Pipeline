module risc_v_single_cycle (
    input clk, rst,
    output uart_tx
);

// --- Wires IF stage ---
wire [31:0] PC_Out, next_PC, PC_plus4, instruction;

// --- Wires IF/ID ---
wire [31:0] PC_ID, instruction_ID;

// --- Wires ID stage ---
wire [31:0] dataA_ID, dataB_ID, imm_ext_ID;
wire [4:0] addA_ID, addB_ID, addD_ID;
wire [2:0] funct3_ID, ImmSrc_ID;
wire [6:0] funct7_ID;
wire RegWrite_ID, ALUSrc_ID, ALUSrc_pc_ID;
wire MemWrite_ID, MemRead_ID, Branch_ID, Jump_ID;
wire [1:0] ResultSrc_ID, ALUOp_ID;
wire branch_taken_ID;

// --- Wires ID/EX ---
wire [31:0] PC_EX, dataA_EX, dataB_EX, imm_ext_EX;
wire [4:0] addA_EX, addB_EX, addD_EX;
wire [2:0] funct3_EX;
wire [6:0] funct7_EX;        // FIX: funct7 pipeline qua ID/EX
wire [6:0] op_EX;            // FIX: op pipeline qua ID/EX
wire RegWrite_EX, ALUSrc_EX, ALUSrc_pc_EX;
wire MemWrite_EX, MemRead_EX, Branch_EX, Jump_EX;
wire [1:0] ResultSrc_EX, ALUOp_EX;
wire [31:0] instruction_EX;

// --- Wires EX stage ---
wire [3:0] ALUControl_EX;
wire [31:0] alu_out_EX, dataB_forwarded_EX;
wire [31:0] alu_A, alu_B, forwardA_data, forwardB_data;
wire [1:0] forwardA, forwardB;

// --- Wires EX/MEM ---
wire [31:0] PC_MEM, alu_out_MEM, dataB_MEM;
wire [4:0] addD_MEM;
wire [2:0] funct3_MEM;
wire RegWrite_MEM, MemWrite_MEM, MemRead_MEM;
wire [1:0] ResultSrc_MEM;

// --- Wires MEM stage ---
wire [31:0] read_data_MEM, PC_plus4_MEM;

// --- Wires MEM/WB ---
wire [31:0] PC_plus4_WB, alu_out_WB, read_data_WB, WB_out_WB;
wire [4:0] addD_WB;
wire RegWrite_WB;
wire [1:0] ResultSrc_WB;

// --- Wire WB stage---
reg [31:0] WB_reg;

// --- HAZARD SIGNAL ---
wire stall, flush_ID, flush_EX;
// counter
reg [31:0] cycle_instr;
reg [31:0] cycle_counter;
reg [31:0] nop_counter;
// FIX: thêm Stall Signal để giữ nguyên PC khi Stall
pc pc (
    .clk(clk), .rst(rst),
    .stall(stall),
    .next_PC(next_PC),
    .PC_Out(PC_Out)
);

PCAdder pc_adder (
    .PC_in(PC_Out),
    .PC_plus4(PC_plus4)
);

// FIX: IMEM dùng $readmemh thay vì gán cứng
IMEM imem (
    .PC_Out(PC_Out),
    .instruction(instruction)
);

wire [31:0] jalr_target;
assign jalr_target = (forwardA_data + imm_ext_EX) & 32'hFFFFFFFC; // tinh rieng cho jalr
wire [31:0] branch_target = (op_EX == 7'b1100111) ? jalr_target : (PC_EX + imm_ext_EX); // branch sang EX -> lay PC_EX
// NextPCSel: branch target = alu_out_EX (PC_EX + imm đã tính trong EX)
// NextPCSel: jalr

NextPCSel next_pc_sel (
    .PC_plus4(PC_plus4),
    .PC_branch(branch_target),
    // .PC_jalr(jalr_target),
    .Branch(Branch_EX),      // branch o EX
    .Jump(Jump_EX),          // jump o EX
    .branch_taken(branch_taken_EX),  // branch o EX
    .next_PC(next_PC)
);
    
// --------------------------------------------------------------------------
// IF/ID Pipeline Register
// --------------------------------------------------------------------------
IF_ID if_id (
    .clk(clk), .rst(rst),
    .stall(stall), .flush(flush_ID),
    .instruction_in(instruction), .PC_in(PC_Out),
    .instruction_out(instruction_ID), .PC_out(PC_ID)
);

// --------------------------------------------------------------------------
// ID Stage
// --------------------------------------------------------------------------
ControlUnit control_unit (
    .op(instruction_ID[6:0]),
    .RegWrite(RegWrite_ID), .ALUSrc(ALUSrc_ID), .ALUSrc_pc(ALUSrc_pc_ID),
    .MemWrite(MemWrite_ID), .MemRead(MemRead_ID),
    .ResultSrc(ResultSrc_ID), .Branch(Branch_ID), .Jump(Jump_ID),
    .ALUOp(ALUOp_ID), .imm_sel(ImmSrc_ID)
);

RegisterFile reg_file (
    .clk(clk), .rst(rst),
    .addA(instruction_ID[19:15]),
    .addB(instruction_ID[24:20]),
    .addD(addD_WB),
    .WB_out(WB_out_WB),
    // .WB_out(WB_reg),
    .RegWrite(RegWrite_WB),
    .dataA(dataA_ID),
    .dataB(dataB_ID)
);

ImmGen imm_gen (
    .instruction(instruction_ID),
    .imm_sel(ImmSrc_ID),
    .imm_ext(imm_ext_ID)
);

BranchComp branch_comp (
    .op(instruction_EX[6:0]),
    .funct3(instruction_EX[14:12]),
    .rs1_data(forwardA_data),        // fwd fix load use data
    .rs2_data(forwardB_data),        // fwd fix load use data
    .branch_taken(branch_taken_EX)   // branch EX
);

assign addA_ID    = instruction_ID[19:15];
assign addB_ID    = instruction_ID[24:20];
assign addD_ID    = instruction_ID[11:7];
assign funct3_ID  = instruction_ID[14:12];
assign funct7_ID  = instruction_ID[31:25]; // FIX: lấy funct7 ở ID để pipeline

ID_EX id_ex (
    .clk(clk), .rst(rst), .flush(flush_EX),
    .PC_in(PC_ID),
    .dataA_in(dataA_ID), .dataB_in(dataB_ID), .imm_ext_in(imm_ext_ID),
    .addA_in(addA_ID), .addB_in(addB_ID), .addD_in(addD_ID),
    .funct3_in(funct3_ID), .funct7_in(funct7_ID), .op_in(instruction_ID[6:0]),
    .RegWrite_in(RegWrite_ID), .ALUSrc_in(ALUSrc_ID), .ALUSrc_pc_in(ALUSrc_pc_ID),
    .MemWrite_in(MemWrite_ID), .MemRead_in(MemRead_ID),
    .ResultSrc_in(ResultSrc_ID), .Branch_in(Branch_ID), .Jump_in(Jump_ID),
    .ALUOp_in(ALUOp_ID),
    .instruction_in (instruction_ID),
    // outputs
    .instruction_out(instruction_EX),
    .PC_out(PC_EX),
    .dataA_out(dataA_EX), .dataB_out(dataB_EX), .imm_ext_out(imm_ext_EX),
    .addA_out(addA_EX), .addB_out(addB_EX), .addD_out(addD_EX),
    .funct3_out(funct3_EX), .funct7_out(funct7_EX), .op_out(op_EX),
    .RegWrite_out(RegWrite_EX), .ALUSrc_out(ALUSrc_EX), .ALUSrc_pc_out(ALUSrc_pc_EX),
    .MemWrite_out(MemWrite_EX), .MemRead_out(MemRead_EX),
    .ResultSrc_out(ResultSrc_EX), .Branch_out(Branch_EX), .Jump_out(Jump_EX),
    .ALUOp_out(ALUOp_EX)
);

// --------------------------------------------------------------------------
// EX Stage
// FIX: ALUControl dùng funct7_EX và op_EX (đã pipeline), không dùng instruction_ID
// --------------------------------------------------------------------------
ALUControl alu_control (
    .ALUOp(ALUOp_EX),
    .funct3(funct3_EX),
    .funct7(funct7_EX),     // FIX: dùng EX stage value
    .op(op_EX),             // FIX: dùng EX stage value
    .ALUControl(ALUControl_EX)
);

// FIX: ForwardingUnit encoding khớp với MUX3
// MUX3: input0=dataA_EX, input1=WB_out_WB, input2=alu_out_MEM
// ForwardingUnit: 2'b00=no forward, 2'b01=MEM/WB, 2'b10=EX/MEM
MUX3 mux_forwardA (
    .input0(dataA_EX),     // 2'b00: không forward
    .input1(WB_out_WB),    // 2'b01: forward từ MEM/WB
    .input2(alu_out_MEM),  // 2'b10: forward từ EX/MEM
    .select(forwardA), .out(forwardA_data)
);

MUX3 mux_forwardB (
    .input0(dataB_EX),     // 2'b00: không forward
    .input1(WB_out_WB),    // 2'b01: forward từ MEM/WB
    .input2(alu_out_MEM),  // 2'b10: forward từ EX/MEM
    .select(forwardB), .out(forwardB_data)
);

MUX2 mux_alu1 (
    .input0(forwardA_data), .input1(PC_EX),
    .select(ALUSrc_pc_EX), .out(alu_A)
);
    
MUX2 mux_alu2 (
    .input0(forwardB_data), .input1(imm_ext_EX),
    .select(ALUSrc_EX), .out(alu_B)
);

ALU alu (
    .A(alu_A), .B(alu_B),
    .ALUControl(ALUControl_EX),
    .alu_out(alu_out_EX)
);

assign dataB_forwarded_EX = forwardB_data;

// --------------------------------------------------------------------------
// Forwarding Unit
// FIX: encoding sửa lại - 2'b00=no fwd, 2'b01=WB, 2'b10=MEM
// FIX: bỏ RegWrite_EX (không cần, không kết nối ở top)
// --------------------------------------------------------------------------
ForwardingUnit forwarding_unit (
    .rs1_EX(addA_EX), 
    .rs2_EX(addB_EX),
    .rd_MEM(addD_MEM), 
    .rd_WB(addD_WB),
    .RegWrite_MEM(RegWrite_MEM), 
    .RegWrite_WB(RegWrite_WB),
    .forwardA(forwardA), 
    .forwardB(forwardB)
);

// --------------------------------------------------------------------------
// EX/MEM Pipeline Register
// --------------------------------------------------------------------------
EX_MEM ex_mem (
    .clk(clk), .rst(rst),
    .PC_in(PC_EX), .alu_out_in(alu_out_EX), 
    .dataB_in(dataB_forwarded_EX),
    .addD_in(addD_EX), 
    .funct3_in(funct3_EX),
    .RegWrite_in(RegWrite_EX), 
    .MemWrite_in(MemWrite_EX), 
    .MemRead_in(MemRead_EX),
    .ResultSrc_in(ResultSrc_EX),
    .PC_out(PC_MEM), 
    .alu_out_out(alu_out_MEM), 
    .dataB_out(dataB_MEM),
    .addD_out(addD_MEM), 
    .funct3_out(funct3_MEM),
    .RegWrite_out(RegWrite_MEM), 
    .MemWrite_out(MemWrite_MEM), 
    .MemRead_out(MemRead_MEM),
    .ResultSrc_out(ResultSrc_MEM)
);

// --------------------------------------------------------------------------
// MEM Stage
// --------------------------------------------------------------------------

wire [31:0] uart_read_data;
wire uart_region = (alu_out_MEM >= 32'h10000000 && alu_out_MEM <= 32'h1000001F);
    
uart uart_periph (
    .clk,
    .rst,
    .addr(alu_out_MEM),
    .write_data(dataB_MEM),
    .mem_write(MemWrite_MEM && uart_region), 
    .mem_read(MemRead_MEM && uart_region), 
    .read_data(uart_read_data),
    .cycle_counter(cycle_counter),
    .uart_tx
);

DMEM dmem (
    .clk(clk), .rst(rst),
    .MemRead(MemRead_MEM && !uart_region), 
    .MemWrite(MemWrite_MEM && !uart_region), 
    .funct3(funct3_MEM),
    .address(alu_out_MEM), 
    .write_data(dataB_MEM), 
    .read_data(read_data_MEM)
);
    
PCAdder pc_adder2 (
    .PC_in(PC_MEM),
    .PC_plus4(PC_plus4_MEM)
);
//
// MEM/WB Pipeline Register
//
MEM_WB mem_wb (
    .clk(clk), .rst(rst), 
    .PC_plus4_in(PC_plus4_MEM), 
    .alu_out_in(alu_out_MEM),
    .read_data_in(uart_region ? uart_read_data : read_data_MEM),
    .addD_in(addD_MEM), 
    .RegWrite_in(RegWrite_MEM), 
    .ResultSrc_in(ResultSrc_MEM),
    .PC_plus4_out(PC_plus4_WB), 
    .alu_out_out(alu_out_WB), 
    .read_data_out(read_data_WB), 
    .addD_out(addD_WB),
    .RegWrite_out(RegWrite_WB),
    .ResultSrc_out(ResultSrc_WB)
);

// --------------------------------------------------------------------------
// WB Stage
// --------------------------------------------------------------------------
MUX3 mux_wb (
    .input0(alu_out_WB),      // 2'b00: ALU result
    .input1(read_data_WB),    // 2'b01: Load data
    .input2(PC_plus4_WB),     // 2'b10: JAL/JALR return addr
    .select(ResultSrc_WB),
    .out(WB_out_WB)
);

// --------------------------------------------------------------------------
// Hazard Detection Unit
// --------------------------------------------------------------------------
HazardDetectionUnit hazard_detection (
    .rs1_ID(addA_ID), .rs2_ID(addB_ID), .rd_EX(addD_EX),
    .MemRead_EX(MemRead_EX),
    .branch_taken_EX(branch_taken_EX), .Branch_EX(Branch_EX), .Jump_EX(Jump_EX),
    .stall(stall), .flush_ID(flush_ID), .flush_EX(flush_EX)
);



reg [2:0] inst_type_EX, inst_type_MEM, inst_type_WB;
wire commit;

assign commit = (inst_type_WB != 3'd7);//

always @(posedge clk) begin
    // ID → EX
    if (flush ID)
        inst_type_EX = 3'd7;
    else if (!stall)
        inst_type_EX <= inst_type_ID;
    // EX → MEM
    if (flush EX)
        inst_type_MEM <= 3'd7;
    else
        inst_type_MEM <= inst_type_EX;
    // MEM → WB
        inst_type_WB <= inst_type_MEM;
end

//

reg [31:0] cnt_alu;
reg [31:0] cnt_load;
reg [31:0] cnt_store;
reg [31:0] cnt_branch;
reg [31:0] cnt_jump;
reg [31:0] cnt_u;

always @(posedge clk or negedge rst_n) begin
if (~rst_n) begin
    cnt alu = 0;
    cnt load = 0;
    cnt store = 0;
    cnt_branch <= 0;
    cnt_jump <= 0;
    cnt u = 0;
end
else
    if(Branch_EX) cnt_branch <= cnt_branch + 1;
    if(Jump_EX) cnt_jump <= cnt_jump + 1;
    if (commit) begin
        case (inst_type_WB)
            3'd0: cnt alu <<= cnt alu + 1;
            3'd1: cnt load <<= cnt load + 1;
            3'd2: cnt store <= cnt_store + 1;
// 3'd3: cnt_branch <= cnt_branch + 1;
// 3'd4: cnt_jump <= cnt_jump + 1;
            3'd5: cnt u <<= cnt u + 1;
        endcase
    end
end
assign cycle instr = cnt_u + cnt_alu + cnt_jump + cnt_load + cnt_branch + cnt_store;

    
always @(posedge clk or posedge rst) begin
    if(rst) begin
        cycle_counter <= 0;
        nop_counter = 0;
    end
    else begin
        if(instruction_EX == 32'h00000013) nop_counter <= nop_counter + 1;
            if(nop_counter < 4) begin
                cycle_counter < cycle_counter + 1;
            end
        end
    end
    
endmodule
