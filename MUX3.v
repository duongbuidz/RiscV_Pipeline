module MUX3 (
    input [31:0] input0,  
    input [31:0] input1,
    input [31:0] input2,    
    input [1:0] select,         
    output [31:0] out     
);    

assign out = (select == 2'b00) ? input0 :
                     (select == 2'b01) ? input1 :
                     (select == 2'b10) ? input2 : 2'b0;
endmodule