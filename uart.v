module uart (
  input clk,rst_n,  
  input [31:0] write_data,
  input [31:0] addr, input mem_write,
  input mem_read,
  input [31:0] cycle_counter,
  input [31:0] cycle_instr,
  output reg [31:0] read_data,
  output uart_tx
);

parameter UART_TX_DATA = 32'h10000000;
parameter UART_TX_STATUS = 32'h10000004;
parameter UART_CYCLE_COUNTER = 32'h10000008;
parameter UART_INST_COUNTER = 32'h1000000C;

wire tx_ready;
reg [7:0] tx_data;
reg tx_send;
reg mem_write_d;
  
uart tx tx core (
  .clk,
  .rst n,
  .data_in(tx_data),
  .send(tx_send),
  .tx(uart_tx),
  .ready(tx_ready)
);

always @(posedge clk or negedge rst_n) begin
if(~rst_n) begin
tx data <= 0;
tx send <= 0;
end else begin
tx send <= 1'b0;
mem write d<= mem write;
if(mem_write && !mem_write_d && addr == UART_TX_DATA && tx_ready) begin
tx_data = write_data[7:0];
tx send <= 1'bl;
end
end
end

always @(*) begin
  read data = 32'h0;
  if(mem_read) begin
    if(addr == UART TX STATUS)
      read_data = {31'b0, tx_ready);
    else if(addr == UART CYCLE COUNTER)
      read_data = cycle_counter;
    else if(addr == UART_INST_COUNTER)
end
read_data = cycle_instr;
end
endmodule
