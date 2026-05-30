module MAR_reg(clk,reset,mar_in,bus_in,ram_in);
  input clk, reset, mar_in;
  input [3:0] bus_in;
  output reg [3:0] ram_in;
  
  always @(posedge clk or negedge reset) 
    begin
      if (!reset)
        ram_in <= 4'b0000;       
      else if (mar_in)
        ram_in <= bus_in;        
      else
        ram_in <= ram_in;        
    end
endmodule
