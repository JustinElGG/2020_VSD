`include "AXI_define.svh"


module DefaultSlave(
  input        ACLK         ,
  input        ARESETn      ,  
  input [4:0]CS_R,
  input [4:0]CS_W,  
  input [4:0]NS_R,
  input [4:0]NS_W,  
  output logic[1:0] RRESP_default,
  output logic[1:0] BRESP_default
);

parameter IDLE                 =5'd0;

parameter ReadAddr_M1          =5'd1;
parameter ReadData_M1S0        =5'd2;
parameter ReadData_M1S1        =5'd3;
parameter ReadData_M1S2        =5'd4;
parameter ReadData_M1S3        =5'd5;
parameter ReadData_M1S4        =5'd6;
parameter ReadData_M1S5        =5'd26;

parameter ReadAddr_M0          =5'd7;
parameter ReadData_M0S0        =5'd8;
parameter ReadData_M0S1        =5'd9;
parameter ReadData_M0S2        =5'd10;
parameter ReadData_M0S3        =5'd11;
parameter ReadData_M0S4        =5'd12;

parameter WriteAddr_M1         =5'd13;
parameter WriteData_M1S0       =5'd14;
parameter WriteData_M1S1       =5'd15;
parameter WriteData_M1S2       =5'd16;
parameter WriteData_M1S3       =5'd17;
parameter WriteData_M1S4       =5'd18;
parameter WriteData_M1S5       =5'd27;

parameter WriteResp_S0M1       =5'd19;
parameter WriteResp_S1M1       =5'd20;
parameter WriteResp_S2M1       =5'd21;
parameter WriteResp_S3M1       =5'd22;
parameter WriteResp_S4M1       =5'd23;
parameter WriteResp_S5M1       =5'd28;

parameter WriteAddr_M0         =5'd24;
parameter Default_Slave        =5'd25;

always_comb
begin
    if(CS_R==Default_Slave) RRESP_default = `AXI_RESP_DECERR; 
	else RRESP_default = 2'd0;
end

always_comb
begin
    if(CS_W==Default_Slave) BRESP_default = `AXI_RESP_DECERR; 
	else BRESP_default = 2'd0;
end





































endmodule
