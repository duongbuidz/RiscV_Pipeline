module RegisterFile (
    input             clk, rst,
    input      [4:0]  addA, addB, addD,
    input      [31:0] WB_out,
    input             RegWrite,
    output     [31:0] dataA, dataB
);
    reg [31:0] regfile [0:31];
    integer i;

wire [31:0] x0;
wire [31:0] x1;
wire [31:0] x2;
wire [31:0] x3;
wire [31:0] x4;
wire [31:0] x5;
wire [31:0] x6;
wire [31:0] x7;
wire [31:0] x8;
wire [31:0] x9;
wire [31:0] x10;
wire [31:0] x11;
wire [31:0] x12;
wire [31:0] x13;
wire [31:0] x14;
wire [31:0] x15;
wire [31:0] x16;
wire [31:0] x17;
wire [31:0] x18;
wire [31:0] x19;
wire [31:0] x20;
wire [31:0] x21;
wire [31:0] x22;
wire [31:0] x23;
wire [31:0] x24;
wire [31:0] x25;
wire [31:0] x26;
wire [31:0] x27;
wire [31:0] x28;
wire [31:0] x29;
wire [31:0] x30;
wire [31:0] x31;
    
always @(posedge rst) begin
    for (i = 0; i < 32; i = i + 1)
        regfile[i] <= 32'b0;
end

always @(negedge clk) begin
    if (RegWrite && (addD != 5'b0)) // x0 không được ghi
        regfile[addD] <= WB_out;
end
 
    // Combinational read, x0 luôn = 0
    assign dataA = (addA == 5'b0) ? 32'b0 : regfile[addA];
    assign dataB = (addB == 5'b0) ? 32'b0 : regfile[addB];

assign x0 = regfile[0];
assign x1 = regfile[1];
assign x2 = regfile[2];
assign x3 = regfile[3];
assign x4 = regfile[4];
assign x5 = regfile[5];
assign x6 = regfile[6];
assign x7 = regfile[7];
assign x8 = regfile[8];
assign x9 = regfile[9];
assign x10 = regfile[10];
assign x11 = regfile[11];
assign x12 = regfile[12];
assign x13 = regfile[13];
assign x14 = regfile[14];
assign x15 = regfile[15];
assign x16 = regfile[16];
assign x17 = regfile[17];
assign x18 = regfile[18];
assign x19 = regfile[19];
assign x20 = regfile[20];
assign x21 = regfile[21];
assign x22 = regfile[22];
assign x23 = regfile[23];
assign x24 = regfile[24];
assign x25 = regfile[25];
assign x26 = regfile[26];
assign x27 = regfile[27];
assign x28 = regfile[28];
assign x29 = regfile[29];
assign x30 = regfile[30];
assign x31 = regfile[31];
    
endmodule
