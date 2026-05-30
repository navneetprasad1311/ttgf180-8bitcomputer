module reg_b(
    input clk,
    input reset,
    input b_in,
    input [7:0] bus_in,
    output [7:0] alu_in
);
    reg [7:0] reg_b;
    always @(posedge clk or negedge reset) begin
        if (!reset)
            reg_b <= 8'b0;
        else if (b_in)
            reg_b <= bus_in;
    end
    assign alu_in = reg_b;
endmodule
