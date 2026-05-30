module RAM(
    input clk,
    input reset,
    input ram_in_en,
    input [3:0] ram_in_addr,
    input [7:0] bus_in,
    output [7:0] bus_out,
    input start, 
    input [3:0] sw_addr,
    input [7:0] sw_data,
    input load_btn
);
    reg [7:0] memory [15:0];
    integer i;
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            for (i = 0; i < 16; i = i + 1)
                memory[i] <= 8'b00000000;
        end 
        else begin
            if (!start && load_btn) begin
                memory[sw_addr] <= sw_data;
            end
            else if (ram_in_en) begin
                memory[ram_in_addr] <= bus_in;
            end
        end
    end
    assign bus_out = memory[ram_in_addr];

endmodule
