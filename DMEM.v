module DMEM (
    input clk, rst, MemRead, MemWrite,
    input [2:0] funct3, // T? instruction[14:12]
    input [31:0] address, write_data,
    output reg [31:0] read_data
);
    reg [7:0] dmem [0:1023]; // 256 word = 1024 byte
    integer k;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (k = 0; k < 1024; k = k + 1)
                dmem[k] = 8'b0;
        end else if (MemWrite) begin
            case (funct3)
                3'b000: dmem[address] = write_data[7:0]; // SB
                3'b001: {dmem[address+1], dmem[address]} = write_data[15:0]; // SH
                3'b010: {dmem[address+3], dmem[address+2], dmem[address+1], dmem[address]} = write_data; // SW
            endcase
        end
    end
    always @(*) begin
        if (MemRead) begin
            case (funct3)
                3'b000: read_data = {{24{dmem[address][7]}}, dmem[address]}; // LB
                3'b001: read_data = {{16{dmem[address+1][7]}}, dmem[address+1], dmem[address]}; // LH
                3'b010: read_data = {dmem[address+3], dmem[address+2], dmem[address+1], dmem[address]}; // LW
                3'b100: read_data = {24'b0, dmem[address]}; // LBU
                3'b101: read_data = {16'b0, dmem[address+1], dmem[address]}; // LHU
                default: read_data = 32'b0;
            endcase
        end else
            read_data = 32'b0;
    end
endmodule