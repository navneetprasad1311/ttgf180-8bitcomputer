module alu(sub,xra,ana,a,b,bus_out,carry_flag,zero_flag);
  input sub,xra,ana;
  input [7:0] a,b;
  output [7:0] bus_out;
  output carry_flag ,zero_flag;
  reg [8:0] w;
  always @(*)begin
    case ({sub,xra,ana})
      3'b000: w = {1'b0,a}+{1'b0,b};
      3'b100: w = {1'b0,a}-{1'b0,b};
      3'b010: w = {1'b0,a^b};
      3'b001: w = {1'b0,a&b};
      default: w = 9'b0;
    endcase
  end
  assign bus_out    = w[7:0] ;
  assign carry_flag = w[8];
  assign zero_flag  = (w[7:0] == 8'b0);
endmodule
