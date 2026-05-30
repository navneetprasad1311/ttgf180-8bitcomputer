module reg_a(
    input clk,
    input reset,
    input a_in,
    input [7:0] bus_in,
    output [7:0] alu_in,
    output [7:0] bus_out
);
    reg [7:0] reg_a;
    always @(posedge clk or negedge reset) begin
        if (!reset)
            reg_a <= 8'b0;
        else if (a_in)
            reg_a <= bus_in;
    end
    assign alu_in = reg_a;
    assign bus_out = reg_a;
endmodule
