module IF_ID (
    input clk, rst, stall, flush,
    input [31:0] instruction_in, PC_in,
    output reg [31:0] instruction_out, PC_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            instruction_out <= 32'b0;
            PC_out <= 32'b0;
        end
        else if (!stall) begin // Ch? c?p nh?t khi không stall
            if (flush) begin
                instruction_out <= 32'b0; // Flush: d?t NOP
                PC_out <= 32'b0;
            end
            else begin
                instruction_out <= instruction_in;
                PC_out <= PC_in;
            end
        end
    end
endmodule