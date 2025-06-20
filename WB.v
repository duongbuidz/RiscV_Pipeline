module WB(
    input [31:0] alu_out,      
    input [31:0] read_data,    
    input ResultSrc,           
    output [31:0] WB_out      
);

MUX muxWB(
    .input0(alu_out),
    .input1(read_data),
    .select(ResultSrc),
    .out(WB_out)
);

endmodule