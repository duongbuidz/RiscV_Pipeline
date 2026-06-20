module uart tx (
  input clk, rst,
  input [7:0] data_in,
  input send,
  output reg tx,
  output reg ready
);

parameter CLK FREQ = 50 000 000;
parameter BAUD_RATE = 115200;
localparam DIVISOR = CLK FREQ / BAUD RATE; // 434

// States

localparam S_IDLE = 2'd0;
localparam S_START = 2'dl;
localparam S_DATA = 2'd2;
localparam S_STOP = 2'd3;

reg [1:0] state;
reg [15:0] counter;
reg [2:0] bit_idx;
reg [7:0] data_reg;

always @(posedge clk or posedge rst) begin
  if (rst) begin
    state <= S IDLE;
    tx <<= 1'bl;
    ready <<= 1'bl;
    counter = 0;
    bit idx = 0;
    data_reg <= 0;
  end else begin
    case (state)
    //IDLE: waiting for command to be sent
      S_IDLE: begin
        tx <= 1'bl;
        ready <= 1'bl;
        if (send) begin
          data_reg <= data_in;
          ready <= 1'b0;
          counter <= 0;
          state <= S_START;
          
// START BIT (tx=0, extend DIVISOR cycle)          
      S_START: begin
        tx <= 1'b0;
        if (counter == DIVISOR 1) begin
          counter <= 0;
          bit idx <= 0;
          state <= S_DATA;
        end else
          counter = counter + 1;
        end
      // DATA BITS: do before, d7 after 
      S_DATA: begin
        tx <= data_reg[bit_idx];
        if (counter == DIVISOR - 1) begin
          counter <= 0;
        if (bit idx == 7)
          state <= S_STOP;
        else
          bit_idx <= bit_idx + 1;
        end else
          counter = counter + 1;
        end
      // STOP BIT (tx=1, extend DIVISOR cycle)
      S_STOP: begin
        tx <= 1'b1;
        if (counter == DIVISOR 1) begin
          counter <= 0;
          state <= S IDLE; // ready=1 in the next cycle (S IDLE)
        end else
          counter = counter + 1;
        end
    endcase
  end
end
      
endmodule
