module PC (
    input             clk, rst,
    input             stall,        // FIX: thêm port này
    input      [31:0] next_PC,
    output reg [31:0] PC_Out
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            PC_Out <= 32'b0;
        else if (!stall)            // FIX: giữ PC khi stall
            PC_Out <= next_PC & 32'hFFFFFFFC;
    end
endmodule
