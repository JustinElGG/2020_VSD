`include "CPU.sv"
`include "SRAM_wrapper.sv"

module top(
input clk,rst
);

logic IM_CS,IM_OE,DM_CS,DM_OE;
logic [3:0]IM_WEB,DM_WEB;
logic [31:0]IM_addr,DM_addr;
logic [31:0]DM_Data_in;
logic [31:0]IM_Data_out,DM_Data_out;
CPU cpu(
//output
.IM_CS(IM_CS),.IM_OE(IM_OE),.DM_CS(DM_CS),.DM_OE(DM_OE),
.IM_WEB(IM_WEB),.DM_WEB(DM_WEB),
.IM_addr(IM_addr),.DM_addr(DM_addr),
.DM_Data_in(DM_Data_in),
//input
.clk(clk),.rst(rst),
.IM_Data_out(IM_Data_out),.DM_Data_out(DM_Data_out)
);

SRAM_wrapper IM1(
//input
.CK(clk),
.CS(IM_CS),
.OE(IM_OE),
.WEB(IM_WEB),
.A(IM_addr[15:2]),
.DI(32'd0),
//output  
.DO(IM_Data_out)
);

SRAM_wrapper DM1(
//input
.CK(clk),
.CS(DM_CS),
.OE(DM_OE),
.WEB(DM_WEB),
.A(DM_addr[15:2]),
.DI(DM_Data_in),
//output  
.DO(DM_Data_out)
);
endmodule