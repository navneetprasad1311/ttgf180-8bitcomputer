module cpu_core(
    input clk,
    input reset,
    input start,
    input inp_loaded,
    input [7:0] inp_data,
    output inp_req,
    output [3:0] pc_disp,
    output [7:0] out_display,
    input  [7:0] ram_data_in,
    output [3:0] ram_addr,
    output ram_in_en,
    output [7:0] ram_data_out,
    output halt
);

    // ============================
    // Internal signals and wires
    // ============================
    
    wire [18:0] ctrl;
    wire INP = ctrl[18];
    wire ANA = ctrl[17];
    wire XRA = ctrl[16];
    wire FE  = ctrl[15];
    wire HLT = ctrl[14];
    wire MI  = ctrl[13];
    wire RI  = ctrl[12];
    wire RO  = ctrl[11];
    wire II  = ctrl[10];
    wire IO  = ctrl[9];
    wire AI  = ctrl[8];
    wire AO  = ctrl[7];
    wire ALO = ctrl[6];
    wire SUB = ctrl[5];
    wire BI  = ctrl[4];
    wire OI  = ctrl[3];
    wire CE  = ctrl[2];
    wire CL  = ctrl[1];
    wire CO  = ctrl[0];
    assign halt = (HLT == 1'b1);
    
    // ============================
    // Datapath internal wires
    // ============================
    wire [7:0] alu_out;
    wire carry_flag,cout;
    wire zero_flag,zout;
    wire [7:0] a_alu_in, b_alu_in ,data_out;
    wire [3:0] mar_addr;
    wire [3:0] ir_bus_out;
    wire [3:0] opcode;
    wire [7:0] a_bus_out;
    wire [3:0] pc_bus_out;
    wire [7:0] pc_bus_ext = {4'b0000, pc_bus_out};
    reg [7:0] bus_mux;

    // ============================
    // Datapath external wires
    // ============================    
    
    assign ram_in_en  = RI;
    assign ram_addr   = mar_addr;
    assign ram_data_out = a_bus_out;
    // ============================
    // INPUT Register
    // ============================
    
    INP_reg INP_inst(
        .clk(clk),
        .reset(reset),
        .inp_loaded(inp_loaded),
        .inp_data(inp_data),
        .data_out(data_out)
    );

    // ============================
    // Program Counter
    // ============================

    PC pc_inst (
        .clk(clk),
        .reset(reset),
        .pc_en(CE),
        .jmp(CL),          
        .bus_in(bus_mux[3:0]),
        .dis_out(pc_disp),
        .bus_out(pc_bus_out)
    );

    // ============================
    // MAR Register
    // ============================

    MAR_reg mar_inst (
        .clk(clk),
        .reset(reset),
        .mar_in(MI),
        .bus_in(bus_mux[3:0]),
        .ram_in(mar_addr)
    );   

    // ============================
    // Instruction Register
    // ============================

    reg_IR ir_inst (
       .clk(clk),
       .reset(reset),
       .ir_in(II), 
       .bus_in(bus_mux),
       .bus_out(ir_bus_out),
       .cs_in(opcode)
    );

    // ============================
    // Register A
    // ============================

    reg_a regA (
        .clk(clk),
        .reset(reset),
        .a_in(AI),  
        .bus_in(bus_mux),
        .bus_out(a_bus_out),
        .alu_in(a_alu_in)
    );

    // ============================
    // Register B
    // ============================

    reg_b regB (
        .clk(clk),
        .reset(reset),
        .b_in(BI),
        .bus_in(bus_mux),
        .alu_in(b_alu_in)
    );

    // ============================
    // ALU
    // ============================

    alu alu_inst (
        .sub(SUB),
        .xra(XRA),
        .ana(ANA),
        .a(a_alu_in),
        .b(b_alu_in),
        .bus_out(alu_out),
        .carry_flag(carry_flag),
        .zero_flag(zero_flag)
    );

    // ============================
    // Flag Register
    // ============================
    
    flag_reg fr_inst (
        .clk(clk),
        .reset(reset),
        .flag_en(FE),
        .cin(carry_flag),
        .zin(zero_flag),
        .cout(cout),
        .zout(zout)
        );
    
    // ============================
    // Output Register
    // ============================

    reg_OUT out_reg (
        .clk(clk),
        .out_in(OI),
        .reset(reset),
        .bus_in(bus_mux),
        .dis_out(out_display)
    );

    // ============================
    // Control Unit
    // ============================
    
    ctrl_unit cu_inst (
        .start(start),
        .clk(clk),
        .reset(reset),
        .inp_loaded(inp_loaded),
        .opcode(opcode),
        .carry_flag(cout),
        .zero_flag(zout),
        .inp_req(inp_req),
        .out(ctrl)//
    );

    // ============================
    // Bus Multiplexer (central bus)
    // ============================

    always @(*) begin   
        if (CO) begin  
            bus_mux = pc_bus_ext;
        end else if (IO) begin
            bus_mux = {4'b0000,ir_bus_out};
        end else if (ALO) begin
            bus_mux = alu_out;
        end else if (AO) begin
            bus_mux = a_bus_out;
        end else if (RO) begin
            bus_mux = ram_data_in;
        end else if (INP) begin
            bus_mux = data_out;
        end else begin
            bus_mux = 8'b0;
        end 
    end
endmodule
