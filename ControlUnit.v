module ControlUnit (
    input [6:0] op,
    output RegWrite, ALUSrc, ALUSrc_pc, MemWrite, MemRead, Branch, Jump,
    output [1:0] ALUOp,
    output [1:0] ResultSrc,
    output reg [2:0] imm_sel
);
    assign RegWrite = (op == 7'b0000011 || op == 7'b0110011 || op == 7'b0010011 || op == 7'b0110111 || op == 7'b0110111 || op == 7'b1100111 || op == 7'b0010111) ? 1'b1 : 1'b0; // Thêm JAL, JALR
    assign ALUSrc = (op == 7'b0000011 || op == 7'b0010011 || op == 7'b0110011 || op == 7'b0110111 || op == 7'b0110111 || op == 7'b1100011 || op == 7'b0110111 || op == 7'b0010111) ? 1'b1 : 1'b0; // Thêm JAL, JALR, branch, lui, auipc
    assign MemWrite = (op == 7'b0100011) ? 1'b1 : 1'b0;
    assign MemRead = (op == 7'b0000011) ? 1'b1 : 1'b0;
    assign ResultSrc = (op == 7'b0000011) ? 2'b01 : 
                       (op == 7'b1101111 || op == 7'b1100111) ? 2'b10 : 2'b00; // JAL/JALR: PC_plus4, ALU result
    assign Branch = (op == 7'b1100011) ? 1'b1 : 1'b0;
    assign Jump = (op == 7'b1101111 || op == 7'b1100111) ? 1'b1 : 1'b0; // JAL, JALR

    assign ALUOp = (op == 7'b0110011 || op == 7'b0010011) ? 2'b10 :
                   (op == 7'b1100011) ? 2'b01 :
                   (op == 7'b0110111) ? 2'b11 :
                   (op == 7'b1101111 || op == 7'b1100111 || op == 7'b0010111) ? 2'b00 : 2'b00; // JAL, JALR dùng ADD

    assign ALUSrc_pc = (op == 7'b1100011 || op == 7'b1101111 || op == 7'b0010111) ? 1 : 0;

    always @(*) begin
        case(op)
            7'b0010011, // I-type
            7'b0000011, // LOAD
            7'b1100111: // JALRs
                imm_sel = 3'b001;

            7'b0100011: // S-type
                imm_sel = 3'b010;

            7'b1100011: // B-type
                imm_sel = 3'b011;

            7'b0110111, // U-type
            7'b0010111:
                imm_sel = 3'b100;

            7'b1101111: // J-type
                imm_sel = 3'b101;

            default:
                imm_sel = 3'b000;
        endcase
    end
endmodule
