module ImmGen (
    input [31:0] instruction,
    input [2:0]   imm_sel,
    output reg [31:0] imm_ext
);
	   // wire [6:0] opcode;
    // assign opcode = instruction[6:0];

    always @(*) begin
        case (imm_sel)
            3'b001: // I-type  JALR LOAD 
                imm_ext = {{20{instruction[31]}}, instruction[31:20]};

            3'b010: // S-type 
                imm_ext = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

            3'b011: // B-type 
                imm_ext = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            3'b100: // U-type  
                imm_ext = {instruction[31:12], 12'b0};

            3'b101: // J-type
                imm_ext = {{11{instruction[31]}}, instruction[31],
                            instruction[19:12], instruction[20],
                            instruction[30:21], 1'b0};

            default:
                imm_ext = 32'b0;
        endcase
    end

endmodule
