module PC(clk,reset,pc_en,jmp,bus_in,dis_out,bus_out);
  input clk,reset,pc_en,jmp;
  input [3:0] bus_in;
  output [3:0] dis_out;
  output [3:0] bus_out;
  reg [3:0] pc_reg;
  assign dis_out=pc_reg;
  assign bus_out=pc_reg;
  always @(posedge clk or negedge reset)
    begin 
      if(!reset)
        pc_reg<=4'b0000;
      else if(jmp)  
        pc_reg<=bus_in;
      else if(pc_en)
        pc_reg<=pc_reg + 1'b1;
    end 
endmodule  
