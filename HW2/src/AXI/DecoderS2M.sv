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

module DecoderS2M (
  input ACLK,ARESETn,
  input [3:0]CS_R,
  input [3:0]CS_W, 
  input [3:0]NS_R,
  input [3:0]NS_W, 
  
  //----R channel----//
  input [`AXI_IDS_BITS-1:0]  RID   ,
  input [`AXI_DATA_BITS-1:0] RDATA ,
  input [1:0]                RRESP ,
  input                      RLAST ,
  input                      RVALID,
  //----B channel----//
  input [`AXI_IDS_BITS-1:0] BID   ,
  input [1:0]               BRESP ,
  input                     BVALID, 
  //----READY signal----//
  input AWREADY,
  input WREADY,
  input ARREADY,
  //----output----//
  //----R channel----//
  output logic[`AXI_ID_BITS-1:0]   RID_M0   ,
  output logic[`AXI_DATA_BITS-1:0] RDATA_M0 ,
  output logic[1:0]                RRESP_M0 ,
  output logic                     RLAST_M0 ,
  output logic                     RVALID_M0, 
  output logic[`AXI_ID_BITS-1:0]   RID_M1   ,
  output logic[`AXI_DATA_BITS-1:0] RDATA_M1 ,
  output logic[1:0]                RRESP_M1 ,
  output logic                     RLAST_M1 ,
  output logic                     RVALID_M1, 
  //----B channel----//
  output logic[`AXI_ID_BITS-1:0] BID_M0   ,    
  output logic[1:0]              BRESP_M0 ,
  output logic                   BVALID_M0, 
  output logic[`AXI_ID_BITS-1:0] BID_M1   ,    
  output logic[1:0]              BRESP_M1 ,
  output logic                   BVALID_M1,
  //----READY signal----//
  output logic  AWREADY_M0  ,
  output logic  WREADY_M0   ,
  output logic  ARREADY_M0  ,
  output logic  AWREADY_M1  ,
  output logic  WREADY_M1   ,
  output logic  ARREADY_M1
);



//----------------------R channel demux----------------------//
always_comb
begin
  case(CS_R)
    `ReadData_M0S0:begin
	 RID_M0       =RID[3:0]   ;
	 RDATA_M0     =RDATA      ;
	 RRESP_M0     =RRESP      ;
	 RLAST_M0     =RLAST      ;
         //if(!RLAST)
	   RVALID_M0    =RVALID     ;
         //else 
	   //RVALID_M0    =0     ;         
	 RID_M1       = 4'd0           ;
	 RDATA_M1     = 32'd0          ;
	 RRESP_M1     = 2'd0           ;
	 RLAST_M1     = 1'd0           ;
	 RVALID_M1    = 1'd0           ;
	end
    `ReadData_M0S1:begin
	 RID_M0       =RID[3:0]   ;
	 RDATA_M0     =RDATA      ;
	 RRESP_M0     =RRESP      ;
	 RLAST_M0     =RLAST      ;
         //if(!RLAST)
	   RVALID_M0    =RVALID     ;
         //else 
	   //RVALID_M0    =0     ;         
	 RID_M1       = 4'd0           ;
	 RDATA_M1     = 32'd0          ;
	 RRESP_M1     = 2'd0           ;
	 RLAST_M1     = 1'd0           ;
	 RVALID_M1    = 1'd0           ;
	end	
	`ReadData_M1S0:begin
	 RID_M0       = 4'd0           ;
	 RDATA_M0     = 32'd0          ;
	 RRESP_M0     = 2'd0           ;
	 RLAST_M0     = 1'd0           ;
	 RVALID_M0    = 1'd0           ;
	 RID_M1       =RID[3:0]        ;
	 RDATA_M1     =RDATA      ;
	 RRESP_M1     =RRESP      ;
	 RLAST_M1     =RLAST      ;
         //if(!RLAST)
	   RVALID_M1    =RVALID     ;
         //else 
	   //RVALID_M1    =0     ;         
    end
	`ReadData_M1S1:begin
	 RID_M0       = 4'd0           ;
	 RDATA_M0     = 32'd0          ;
	 RRESP_M0     = 2'd0           ;
	 RLAST_M0     = 1'd0           ;
	 RVALID_M0    = 1'd0           ;
	 RID_M1       =RID[3:0]        ;
	 RDATA_M1     =RDATA      ;
	 RRESP_M1     =RRESP      ;
	 RLAST_M1     =RLAST      ;
         //if(!RLAST)
	   RVALID_M1    =RVALID     ;
         //else 
	   //RVALID_M1    =0     ;         
    end	
	default:begin
	 RID_M0       = 4'd0           ;
	 RDATA_M0     = 32'd0          ;
	 RRESP_M0     = 2'd0           ;
	 RLAST_M0     = 1'd0           ;
	 RVALID_M0    = 1'd0           ;	
	 RID_M1       = 4'd0           ;
	 RDATA_M1     = 32'd0          ;
	 RRESP_M1     = 2'd0           ;
	 RLAST_M1     = 1'd0           ;
	 RVALID_M1    = 1'd0           ;	
	end
  endcase
end

//----------------------B channel demux----------------------//
always_comb
begin
  case(CS_W)
	`WriteResp_S0M1:begin
	  BID_M0     = 4'd0       ;
	  BRESP_M0   = 2'd0       ;
	  BVALID_M0  = 1'd0       ;
	  BID_M1     = BID[3:0];
	  BRESP_M1   = BRESP   ;
	  BVALID_M1  = BVALID  ;
    end
	`WriteResp_S1M1:begin
	  BID_M0     = 4'd0       ;
	  BRESP_M0   = 2'd0       ;
	  BVALID_M0  = 1'd0       ;
	  BID_M1     = BID[3:0];
	  BRESP_M1   = BRESP   ;
	  BVALID_M1  = BVALID  ;
    end	
	default:begin
	  BID_M0     = 4'd0       ;
	  BRESP_M0   = 2'd0       ;
	  BVALID_M0  = 1'd0       ;
	  BID_M1     = 4'd0       ;
	  BRESP_M1   = 2'd0       ;
	  BVALID_M1  = 1'd0       ;	
	end
  endcase
end

//----AWREADY demux----//
always_comb
begin
  case(CS_W)
    `WriteAddr_M0:begin
      AWREADY_M0 = AWREADY ;
	  AWREADY_M1 = 1'd0 ;
	end
	`WriteAddr_M1:begin
      AWREADY_M0 = 1'd0 ;
	  AWREADY_M1 = AWREADY ;
    end
	`Write_Addr_Data_M1S0:begin
      AWREADY_M0 = 1'd0 ;
	  AWREADY_M1 = AWREADY ;
    end
	`Write_Addr_Data_M1S1:begin
      AWREADY_M0 = 1'd0 ;
	  AWREADY_M1 = AWREADY ;
    end
	default:begin
      AWREADY_M0 = 1'd0 ;
	  AWREADY_M1 = 1'd0 ;	
	end
  endcase
end
//----WREADY demux----//
always_comb
begin
  case(CS_W)
	`WriteData_M1S0:begin
      WREADY_M0 = 1'd0 ;
      WREADY_M1 = WREADY ;
    end
	`WriteData_M1S1:begin
      WREADY_M0 = 1'd0 ;
      WREADY_M1 = WREADY ;
    end	
	`Write_Addr_Data_M1S0:begin
      WREADY_M0 = 1'd0 ;
      WREADY_M1 = WREADY ;
    end
	`Write_Addr_Data_M1S1:begin
      WREADY_M0 = 1'd0 ;
      WREADY_M1 = WREADY ;
    end	
	default:begin
      WREADY_M0 = 1'd0 ;
      WREADY_M1 = 1'd0 ;	
	end
  endcase
end
//----ARREADY demux----//
always_comb
begin
  case(CS_R)
    `ReadAddr_M0:begin
      ARREADY_M0 = ARREADY ;
	  ARREADY_M1 = 1'd0 ;
	end
	`ReadAddr_M1:begin
      ARREADY_M0 = 1'd0 ;
	  ARREADY_M1 = ARREADY ;
    end
	default:begin
      ARREADY_M0 = 1'd0 ;
	  ARREADY_M1 = 1'd0 ;	
	end
  endcase
end




endmodule 
