module reg_OUT(
  input clk,
  input reset,
  input out_in,
  input [7:0] bus_in,
  output reg [7:0] dis_out
);
  always @(posedge clk or negedge reset) begin
    if (!reset)
      dis_out <= 8'd0;
    else if (out_in)
      dis_out <= bus_in;
  end
endmodule
