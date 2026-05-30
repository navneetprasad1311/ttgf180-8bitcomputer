module ctrl_unit(
    input start,
    input clk,
    input reset,
    input inp_loaded,
    input [3:0] opcode,
    input carry_flag,
    input zero_flag,
    output reg inp_req,
    output [18:0] out
);
localparam INP=18,ANA=17,XRA=16,FE=15,HLT=14,MI=13,RI=12,RO=11,II=10;
localparam IO=9,AI=8,AO=7,ALO=6,SUB=5,BI=4,OI=3,CE=2,CL=1,CO=0;
localparam OP_LDA=4'b0001,OP_STA=4'b0100,OP_LDI=4'b0101,OP_ADD=4'b0010,OP_SUB=4'b0011,OP_JMP=4'b0110,OP_JC=4'b0111;
localparam OP_JZ=4'b1000,OP_ADI=4'b1001,OP_SUI=4'b1010,OP_XRA=4'b1011,OP_ANA=4'b1100,OP_INP=4'b1101,OP_OUT=4'b1110,OP_HLT=4'b1111;
reg [18:0] ctrl_wd;
reg [2:0] stage;
reg running;
reg halt;
reg inp_wait;
always @(posedge clk or negedge reset) begin
    if(!reset) begin
        stage<=0;
        running<=0;
        halt<=0;
        inp_req<=0;
        inp_wait<=0;
    end
    else if(start && !running && !halt) begin
        running<=1;
        stage<=0;
    end
    else if(inp_wait) begin
        inp_req<=1;
        if(inp_loaded) begin
            inp_wait<=0;
            inp_req<=0;
            running<=1;
            stage<=stage+1;
        end
    end
    else if(running && !halt) begin
        if(opcode==OP_INP && stage==3) begin
            inp_wait<=1;
            running<=0;
        end
        else if(ctrl_wd[HLT]) begin
            running<=0;
            halt<=1;
        end
        else if(stage==5) stage<=0;
        else stage<=stage+1;
    end
end
always @(*) begin
    ctrl_wd=19'b0;
    case(stage)
        0: begin
            ctrl_wd[CO]=1;
            ctrl_wd[MI]=1;
        end
        1: begin
            ctrl_wd[RO]=1;
            ctrl_wd[II]=1;
        end
        2: begin
            ctrl_wd[CE]=1;
        end
        3: begin
            case(opcode)
                OP_LDA,OP_STA,OP_ADD,OP_SUB,OP_XRA,OP_ANA: begin
                    ctrl_wd[IO]=1;
                    ctrl_wd[MI]=1;
                end
                OP_LDI: begin
                    ctrl_wd[IO]=1;
                    ctrl_wd[AI]=1;
                end
                OP_JMP: begin
                    ctrl_wd[IO]=1;
                    ctrl_wd[CL]=1;
                end
                OP_JC: if(carry_flag) begin
                    ctrl_wd[IO]=1;
                    ctrl_wd[CL]=1;
                end
                OP_JZ: if(zero_flag) begin
                    ctrl_wd[IO]=1;
                    ctrl_wd[CL]=1;
                end
                OP_ADI,OP_SUI: begin
                    ctrl_wd[IO]=1;
                    ctrl_wd[BI]=1;
                end
                OP_OUT: begin
                    ctrl_wd[AO]=1;
                    ctrl_wd[OI]=1;
                end
                OP_HLT: ctrl_wd[HLT]=1;
                default: ctrl_wd = 19'b0;
            endcase
        end
        4: begin
            case(opcode)
                OP_LDA: begin
                    ctrl_wd[RO]=1;
                    ctrl_wd[AI]=1;
                end
                OP_STA: begin
                    ctrl_wd[AO]=1;
                    ctrl_wd[RI]=1;
                end
                OP_ADD,OP_SUB,OP_XRA,OP_ANA: begin
                    ctrl_wd[RO]=1;
                    ctrl_wd[BI]=1;
                end
                OP_ADI: begin
                    ctrl_wd[ALO]=1;
                    ctrl_wd[FE]=1;
                    ctrl_wd[AI]=1;
                end
                OP_SUI: begin
                    ctrl_wd[SUB]=1;
                    ctrl_wd[ALO]=1;
                    ctrl_wd[FE]=1;
                    ctrl_wd[AI]=1;
                end
                OP_INP: begin
                    ctrl_wd[IO]=1;
                    ctrl_wd[MI]=1;
                end
                default: ctrl_wd = 19'b0;
            endcase
        end
        5: begin
            case(opcode)
                OP_ADD: begin
                    ctrl_wd[ALO]=1;
                    ctrl_wd[FE]=1;
                    ctrl_wd[AI]=1;
                end
                OP_SUB: begin
                    ctrl_wd[SUB]=1;
                    ctrl_wd[ALO]=1;
                    ctrl_wd[FE]=1;
                    ctrl_wd[AI]=1;
                end
                OP_XRA: begin
                    ctrl_wd[XRA]=1;
                    ctrl_wd[ALO]=1;
                    ctrl_wd[FE]=1;
                    ctrl_wd[AI]=1;
                end
                OP_ANA: begin
                    ctrl_wd[ANA]=1;
                    ctrl_wd[ALO]=1;
                    ctrl_wd[FE]=1;
                    ctrl_wd[AI]=1;
                end
				OP_INP: begin
                    ctrl_wd[INP]=1;
                    ctrl_wd[AI]=1;
					ctrl_wd[RI]=1;
				end
                default: ctrl_wd = 19'b0;
            endcase
        end
    endcase
end
assign out=ctrl_wd;
endmodule
