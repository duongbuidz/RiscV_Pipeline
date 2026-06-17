module ALUControl (
    input [1:0] ALUOp,
    input [2:0] funct3,
    input [6:0] funct7,
    input [6:0] op,
    output reg [3:0] ALUControl
);
    wire RtypeSub = funct7[5] & op[5];

    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0000; // ADD (load/store/JAL/JALR)
            2'b01: ALUControl = 4'b0000; // ADD (branch – dùng forwarded rs1/rs2)
            2'b11: ALUControl = 4'b1111;
            default: begin
                case (funct3)
                    3'b000: ALUControl = RtypeSub ? 4'b0001 : 4'b0000;
                    3'b001: ALUControl = 4'b0101;
                    3'b010: ALUControl = 4'b1000;
                    3'b011: ALUControl = 4'b1001;
                    3'b100: ALUControl = 4'b0100;
                    3'b101: ALUControl = funct7[5] ? 4'b0111 : 4'b0110;
                    3'b110: ALUControl = 4'b0011;
                    3'b111: ALUControl = 4'b0010;
                    default: ALUControl = 4'b0000;
                endcase
            end
        endcase
    end
endmodule
