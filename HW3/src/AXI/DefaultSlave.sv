`include "AXI_define.svh"
`define IDLE              4'b0000
`define ReadAddr_M1       4'b0001
`define ReadData_M1S0     4'b0010
`define ReadData_M1S1     4'b0011
`define ReadAddr_M0       4'b0100
`define ReadData_M0S0     4'b0101
`define ReadData_M0S1     4'b0110
`define WriteAddr_M1      4'b0111
`define WriteData_M1S0    4'b1000
`define WriteData_M1S1    4'b1001
`define WriteResp_S0M1    4'b1010
`define WriteResp_S1M1    4'b1011
`define WriteAddr_M0      4'b1100
`define Default_Slave     4'b1101
`define Write_Addr_Data_M1S0 4'b1110
`define Write_Addr_Data_M1S1 4'b1111

module DefaultSlave(
  input        ACLK         ,
  input        ARESETn      ,  
  input [3:0]CS_R,
  input [3:0]CS_W,  
  input [3:0]NS_R,
  input [3:0]NS_W,  
  output logic[1:0] RRESP_default,
  output logic[1:0] BRESP_default
);

always_comb
begin
    if(CS_R==`Default_Slave) RRESP_default = `AXI_RESP_DECERR; 
	else RRESP_default = 2'd0;
end

always_comb
begin
    if(CS_W==`Default_Slave) BRESP_default = `AXI_RESP_DECERR; 
	else BRESP_default = 2'd0;
end





































endmodule
