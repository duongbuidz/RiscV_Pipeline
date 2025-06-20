module PC (
    input clk, 
    input rst,
    input [31:0] next_PC,
    output reg [31:0] PC_Out
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            PC_Out <= 32'b0;
        else
            PC_Out <= next_PC & 32'hFFFFFFFC;
    end
endmodule
