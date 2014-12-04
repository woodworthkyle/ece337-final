// $Id: $
// File name:   flex_counter.sv
// Created:     9/18/2014
// Author:      Cody Allen
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Designing a flexiable and scalable counter with controlled rollover

module flex_counter
#( parameter NUM_CNT_BITS = 4
)
(
  input wire clk, n_rst, clear, count_enable,
  input wire [NUM_CNT_BITS-1:0] rollover_val,
  output reg [NUM_CNT_BITS-1:0] count_out,
  output reg rollover_flag
);
  reg [NUM_CNT_BITS-1:0] next_count;
  reg next_flag;
  
  // STATE REGISTER
  always_ff @ (posedge clk, negedge n_rst) begin
    if (n_rst == 1'b0) begin
      count_out <= '0;
      rollover_flag <= 1'b0;
    end
    else if (clear == 1'b1) begin
      count_out <= '0;
      rollover_flag <= 1'b0;
    end
    else if (count_enable == 1'b1) begin
      count_out <= next_count;
      rollover_flag <= next_flag;
    end
    else begin
      count_out <= count_out;
    end
  end // state register
  
  // NEXT STATE LOGIC
  always_comb begin
    next_count =((count_out == rollover_val) ? 1'b1 : (count_out + 1));
    next_flag = (((count_out + 1) == rollover_val) ? 1'b1 : 1'b0);
    
  end // next state logic

  
  
endmodule