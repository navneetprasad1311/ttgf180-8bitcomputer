module INP_reg(
    input clk,reset,inp_loaded,
    input [7:0] inp_data,
    output [7:0] data_out
);
    reg [7:0] inp;    
    assign data_out = inp;
    always @(posedge clk or negedge reset)begin
        if(!reset)
            inp <= 8'b0;
        else if(inp_loaded)
                inp <= inp_data;  
    end
endmodule