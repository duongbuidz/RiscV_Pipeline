module DMEM (
    input clk, rst, MemRead, MemWrite,
    input [2:0] funct3, // T? instruction[14:12]
    input [31:0] address, write_data,
    output reg [31:0] read_data
);
    reg [7:0] dmem [0:1023]; // 256 word = 1024 byte
    integer k;

wire [7:0] x0;
wire [7:0] x1;
wire [7:0] x2;
wire [7:0] x3;
wire [7:0] x4;
wire [7:0] x5;
wire [7:0] x6;
wire [7:0] x7;
wire [7:0] x8;
wire [7:0] x9;
wire [7:0] x10;
wire [7:0] x11;
wire [7:0] x12;
wire [7:0] x13;
wire [7:0] x14;
wire [7:0] x15;
wire [7:0] x16;
wire [7:0] x17;
wire [7:0] x18;
wire [7:0] x19;
wire [7:0] x20;
wire [7:0] x21;
wire [7:0] x22;
wire [7:0] x23;
wire [7:0] x24;
wire [7:0] x25;
wire [7:0] x26;
wire [7:0] x27;
wire [7:0] x28;
wire [7:0] x29;
wire [7:0] x30;
wire [7:0] x31;


wire miss_aligned_word;
wire miss_aligned_half;

assign miss_aligned_word = (funct3 == 3'b010) && (address[1:0] != 2'b00);
assign miss_aligned_half = (funct3 == 3'b001) && (address[0] != 1'b0);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (integer k = 0; k < 1024; k = k + 1)
            dmem[k] <= 8'b0;
    end else if (MemWrite && !miss_aligned_word && !miss_aligned_half) begin
        case (funct3)
            // word - align
            3'b000: dmem[address] <= write_data[7:0]; // SB (Store Byte)
            3'b001: {dmem[address+1], dmem[address]} <= write_data[15:0]; // SH (Store Half-word)
            3'b010: {dmem[address+3], dmem[address+2], dmem[address+1], dmem[address]} <= write_data; // SW (Store Word)
        endcase
    end
end

always @(*) begin
    if (MemRead && !miss_aligned_word && !miss_aligned_half) begin
        case (funct3)
            3'b000: read_data = {{24{dmem[address][7]}}, dmem[address]}; // LB (Load Byte - signed)
            3'b001: read_data = {{16{dmem[address+1][7]}}, dmem[address+1], dmem[address]}; // LH (Load Half-word - signed)
            3'b010: read_data = {dmem[address+3], dmem[address+2], dmem[address+1], dmem[address]}; // LW (Load Word)
            3'b100: read_data = {24'b0, dmem[address]}; // LBU (Load Byte Unsigned)
            3'b101: read_data = {16'b0, dmem[address+1], dmem[address]}; // LHU (Load Half-word Unsigned)
            default: read_data = 32'b0;
        endcase
    end else begin
        read_data = 32'b0;
    end
end


assign x0 = dmem[0];
assign x1 = dmem[1];
assign x2 = dmem[2];
assign x3 = dmem[3];
assign x4 = dmem[4];
assign x5 = dmem[5];
assign x6 = dmem[6];
assign x7 = dmem[7];
assign x8 = dmem[8];
assign x9 = dmem[9];
assign x10 = dmem[10];
assign x11 = dmem[11];
assign x12 = dmem[12];
assign x13 = dmem[13];
assign x14 = dmem[14];
assign x15 = dmem[15];
assign x16 = dmem[16];
assign x17 = dmem[17];
assign x18 = dmem[18];
assign x19 = dmem[19];
assign x20 = dmem[20];
assign x21 = dmem[21];
assign x22 = dmem[22];
assign x23 = dmem[23];
assign x24 = dmem[24];
assign x25 = dmem[25];
assign x26 = dmem[26];
assign x27 = dmem[27];
assign x28 = dmem[28];
assign x29 = dmem[29];
assign x30 = dmem[30];
assign x31 = dmem[31];
    
endmodule
