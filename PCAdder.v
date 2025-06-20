module PCAdder(
    input [31:0] PC_in,
    output [31:0] PC_plus4
);
    assign PC_plus4 = PC_in + 32'd4;
endmodule
