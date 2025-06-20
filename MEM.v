module MEM(
    input clk,
    input rst,
    input [31:0] alu_out,        // Ðia chi bo nho ALU
    input [31:0] dataB,          // DataB cho store)
    input [31:0] instruction,   
    
    // Control unit
    input MemRead,               
    input MemWrite,              
   
    output [31:0] read_data,     
    output [31:0] mem_result     
);
    
    DMEM dmem(
        .clk(clk),
        .rst(rst),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(alu_out),
        .write_data(dataB),
        .read_data(read_data)
    );
    assign mem_result = MemRead ? read_data : alu_out;

endmodule