module reg_IR(
    input clk,
    input reset,
    input ir_in,
    input [7:0] bus_in,
    output [3:0] cs_in,     
    output [3:0] bus_out 
);
    reg [7:0] reg_ir;
    always @(posedge clk or negedge reset) begin
        if (!reset)
            reg_ir <= 8'b0;
        else if (ir_in)
            reg_ir <= bus_in;         
    end
    assign cs_in = reg_ir[7:4];
    assign bus_out = reg_ir[3:0];
endmodule
