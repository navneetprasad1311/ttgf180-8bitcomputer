module tt_um_8bitcustomcomputer (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,

    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,

    input  wire clk,
    input  wire rst_n,
    input  wire ena
);
	
	wire reset; 
	assign reset = rst_n;

	wire [3:0] sw_addr;
	assign sw_addr = ui_in [7:4];
	
	wire load_ram;
	assign load_ram = ui_in[3];
	
	wire inp_loaded;
	assign inp_loaded = ui_in[2];
	
	wire start;
    assign start = ui_in[1];
		
	wire prog_mode;
	assign prog_mode = ui_in [0] ;

	assign uio_oe = (prog_mode) ? 8'd1 : 8'd0;  // SELF CONTROLLED

	wire [7:0] out_display;
	assign uio_out = out_display;

	wire [7:0] enter_data ;
	assign enter_data = uio_in ;
	
    wire [3:0] ram_addr;
    
	wire [7:0] ram_data_in;
    wire [7:0] ram_data_out;
    wire ram_in_en;
    wire inp_sig;
	
    assign uo_out[7] = inp_sig;
	
	wire halt;
	assign uo_out[6] = halt;
	
	wire [3:0] pc_disp;
	assign uo_out[5:2] = pc_disp; 
	
	assign uo_out [1:0] = 2'd0;

    wire _unused = &{ena, 1'b0};
	
	reg [7:0] sw_data;
    reg [7:0] inp_data;
	
    always @(*)begin
        inp_data = 8'b0;
        sw_data = 8'b0;
        if(inp_sig)
            inp_data = enter_data;
        else 
            sw_data = enter_data;
    end
    
    // ============================
    // Instantiate CPU core
    // ============================

    cpu_core CPU (
        .clk(clk),
        .reset(reset),
        .start(start),
		.pc_disp(pc_disp),
        .out_display(out_display),
        .inp_req(inp_sig),   
        .inp_loaded(inp_loaded), 
        .inp_data(inp_data),   
        .ram_data_in(ram_data_in),
        .ram_data_out(ram_data_out),
        .ram_addr(ram_addr),
        .ram_in_en(ram_in_en),
		.halt(halt)
    );

    // ============================
    // Instantiate RAM (external)
    // ============================

    RAM RAM_inst (
        .clk(clk),
        .reset(reset),         
        .ram_in_en(ram_in_en),
        .ram_in_addr(ram_addr),
        .bus_in(ram_data_out),
        .bus_out(ram_data_in),
        .start(start),
        .sw_addr(sw_addr),
        .sw_data(sw_data),
        .load_btn(load_ram)
    );

endmodule