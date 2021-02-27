`include "AXI_define.svh"


module MuxS2M (
        input ACLK,ARESETn,
	input [4:0]CS_R,
	input [4:0]CS_W,  
	input [4:0]NS_R,
	input [4:0]NS_W, 	
	//----R----//
	input [`AXI_IDS_BITS-1:0]  RID_S0   ,
	input [`AXI_DATA_BITS-1:0] RDATA_S0 ,
	input [1:0]                RRESP_S0 ,
	input                      RLAST_S0 ,
	input                      RVALID_S0,
	input [`AXI_IDS_BITS-1:0]  RID_S1   ,
	input [`AXI_DATA_BITS-1:0] RDATA_S1 ,
	input [1:0]                RRESP_S1 ,
	input                      RLAST_S1 ,
	input                      RVALID_S1,
	input [`AXI_IDS_BITS-1:0]  RID_S2   ,
	input [`AXI_DATA_BITS-1:0] RDATA_S2 ,
	input [1:0]                RRESP_S2 ,
	input                      RLAST_S2 ,
	input                      RVALID_S2,
	input [`AXI_IDS_BITS-1:0]  RID_S3   ,
	input [`AXI_DATA_BITS-1:0] RDATA_S3 ,
	input [1:0]                RRESP_S3 ,
	input                      RLAST_S3 ,
	input                      RVALID_S3,
	input [`AXI_IDS_BITS-1:0]  RID_S4   ,
	input [`AXI_DATA_BITS-1:0] RDATA_S4 ,
	input [1:0]                RRESP_S4 ,
	input                      RLAST_S4 ,
	input                      RVALID_S4,	
	input [`AXI_IDS_BITS-1:0]  RID_S5   ,
	input [`AXI_DATA_BITS-1:0] RDATA_S5 ,
	input [1:0]                RRESP_S5 ,
	input                      RLAST_S5 ,
	input                      RVALID_S5,		
    //----B----//
	input [`AXI_IDS_BITS-1:0] BID_S0   ,
	input [1:0]               BRESP_S0 ,
	input                     BVALID_S0,
	input [`AXI_IDS_BITS-1:0] BID_S1   ,
	input [1:0]               BRESP_S1 ,
	input                     BVALID_S1,
	input [`AXI_IDS_BITS-1:0] BID_S2   ,
	input [1:0]               BRESP_S2 ,
	input                     BVALID_S2,
	input [`AXI_IDS_BITS-1:0] BID_S3   ,
	input [1:0]               BRESP_S3 ,
	input                     BVALID_S3,
	input [`AXI_IDS_BITS-1:0] BID_S4   ,
	input [1:0]               BRESP_S4 ,
	input                     BVALID_S4,
	input [`AXI_IDS_BITS-1:0] BID_S5   ,
	input [1:0]               BRESP_S5 ,
	input                     BVALID_S5,		
    //----READY signal----//
    input AWREADY_S0,
    input AWREADY_S1,
    input AWREADY_S2,
    input AWREADY_S3,
    input AWREADY_S4,
	input AWREADY_S5,
    input ARREADY_S0,
    input ARREADY_S1,
    input ARREADY_S2,
    input ARREADY_S3,	
    input ARREADY_S4,
    input ARREADY_S5,	
    input WREADY_S0 ,
    input WREADY_S1 ,
    input WREADY_S2 ,
    input WREADY_S3 ,
    input WREADY_S4 ,
    input WREADY_S5 ,	
    //----BRESP_default/RRESP_default----//
    input [1:0] RRESP_default,
    input [1:0] BRESP_default,
    //----ARVLAID----//
    input ARVALID,	
	input [`AXI_ADDR_BITS-1:0]ARADDR_M0,
	input [`AXI_ADDR_BITS-1:0]AWADDR_M1,
	input [`AXI_ADDR_BITS-1:0]ARADDR_M1,
    //----R----//
	output logic[`AXI_IDS_BITS-1:0]  RID   ,
	output logic[`AXI_DATA_BITS-1:0] RDATA ,
	output logic[1:0]                RRESP ,
	output logic                     RLAST ,
	output logic                     RVALID,	
	//----B----//
	output logic[`AXI_IDS_BITS-1:0] BID   ,
	output logic[1:0]               BRESP ,
	output logic                    BVALID,
	//----READY signal----//
    output logic AWREADY,
    output logic WREADY,
    output logic ARREADY
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



//----R----//
always_comb
begin
		  case(CS_R)
		    ReadData_M0S0 :begin
		      RID       =     RID_S0       ;
		      RDATA     =     RDATA_S0     ;
		      RRESP     =     RRESP_S0     ;
		      RLAST     =     RLAST_S0     ;
		      RVALID    =     RVALID_S0    ;
			end
		    ReadData_M1S0:begin
		      RID       =     RID_S0       ;
		      RDATA     =     RDATA_S0     ;
		      RRESP     =     RRESP_S0     ;
		      RLAST     =     RLAST_S0     ;
		      RVALID    =     RVALID_S0    ;
			end			
			ReadData_M0S1:begin
		      RID       =     RID_S1       ;
		      RDATA     =     RDATA_S1     ;
		      RRESP     =     RRESP_S1     ;
		      RLAST     =     RLAST_S1     ;
		      RVALID    =     RVALID_S1    ;                   
			end
			ReadData_M1S1:begin
		      RID       =     RID_S1       ;
		      RDATA     =     RDATA_S1     ;
		      RRESP     =     RRESP_S1     ;
		      RLAST     =     RLAST_S1     ;
		      RVALID    =     RVALID_S1    ;                   
			end	
			ReadData_M0S2:begin
		      RID       =     RID_S2       ;
		      RDATA     =     RDATA_S2     ;
		      RRESP     =     RRESP_S2     ;
		      RLAST     =     RLAST_S2     ;
		      RVALID    =     RVALID_S2    ;                   
			end
			ReadData_M1S2:begin
		      RID       =     RID_S2       ;
		      RDATA     =     RDATA_S2     ;
		      RRESP     =     RRESP_S2     ;
		      RLAST     =     RLAST_S2     ;
		      RVALID    =     RVALID_S2    ;                   
			end				
			ReadData_M0S3:begin
		      RID       =     RID_S3       ;
		      RDATA     =     RDATA_S3     ;
		      RRESP     =     RRESP_S3     ;
		      RLAST     =     RLAST_S3     ;
		      RVALID    =     RVALID_S3    ;                   
			end
			ReadData_M1S3:begin
		      RID       =     RID_S3       ;
		      RDATA     =     RDATA_S3     ;
		      RRESP     =     RRESP_S3     ;
		      RLAST     =     RLAST_S3     ;
		      RVALID    =     RVALID_S3    ;                   
			end	
			ReadData_M0S4:begin
		      RID       =     RID_S4       ;
		      RDATA     =     RDATA_S4     ;
		      RRESP     =     RRESP_S4     ;
		      RLAST     =     RLAST_S4     ;
		      RVALID    =     RVALID_S4    ;                   
			end
			ReadData_M1S4:begin
		      RID       =     RID_S4       ;
		      RDATA     =     RDATA_S4     ;
		      RRESP     =     RRESP_S4     ;
		      RLAST     =     RLAST_S4     ;
		      RVALID    =     RVALID_S4    ;                   
			end		
			ReadData_M1S5:begin
		      RID       =     RID_S5       ;
		      RDATA     =     RDATA_S5     ;
		      RRESP     =     RRESP_S5     ;
		      RLAST     =     RLAST_S5     ;
		      RVALID    =     RVALID_S5    ;                   
			end					
			Default_Slave:begin
		      RID       =     8'd0         ;
		      RDATA     =     32'd0        ;
		      RRESP     =     RRESP_default;
		      RLAST     =     1'd0         ;
		      RVALID    =     1'd0         ;	  
			end			
			default:begin
		      RID       =     8'd0         ;
		      RDATA     =     32'd0        ;
		      RRESP     =     2'd0         ;
		      RLAST     =     1'd0         ;
		      RVALID    =     1'd0         ;	  
			end
		  endcase
end

//----B----//
always_comb
begin
		  case(CS_W)
		    WriteResp_S0M1:begin
		      BID        =   BID_S0        ;
		      BRESP      =   BRESP_S0      ;
		      BVALID     =   BVALID_S0     ;
			end
			WriteResp_S1M1:begin
		      BID        =   BID_S1        ;
		      BRESP      =   BRESP_S1      ;
		      BVALID     =   BVALID_S1     ;
			end
			WriteResp_S2M1:begin
		      BID        =   BID_S2        ;
		      BRESP      =   BRESP_S2      ;
		      BVALID     =   BVALID_S2     ;
			end			
			WriteResp_S3M1:begin
		      BID        =   BID_S3        ;
		      BRESP      =   BRESP_S3      ;
		      BVALID     =   BVALID_S3     ;
			end	
			WriteResp_S4M1:begin
		      BID        =   BID_S4        ;
		      BRESP      =   BRESP_S4      ;
		      BVALID     =   BVALID_S4     ;
			end	
			WriteResp_S5M1:begin
		      BID        =   BID_S5        ;
		      BRESP      =   BRESP_S5      ;
		      BVALID     =   BVALID_S5     ;
			end				
			Default_Slave:begin
		      BID        =   8'd0          ;
		      BRESP      =   BRESP_default ;
		      BVALID     =   1'd0          ;	  
			end			
			default:begin
		      BID        =   8'd0          ;
		      BRESP      =   2'd0          ;
		      BVALID     =   1'd0          ;	  
			end
		  endcase
end

//----ARREADY----//
always_comb
begin
  case(CS_R)
    ReadAddr_M0:begin
	  if(ARADDR_M0[31:16]==16'h0000)
         ARREADY = ARREADY_S0;
	  else if(ARADDR_M0[31:16]==16'h0001)	
         ARREADY = ARREADY_S1;
	  else if(ARADDR_M0[31:16]==16'h0002)	
         ARREADY = ARREADY_S2;
	  else if(ARADDR_M0[31:16]==16'h1000)	
         ARREADY = ARREADY_S3;
	  else if(ARADDR_M0[31:24]==8'h20)	
         ARREADY = ARREADY_S4;	 
      else 	ARREADY = 1'd0;	 
	end
	ReadAddr_M1:begin
	  if(ARADDR_M1[31:16]==16'h0000)
         ARREADY = ARREADY_S0;
	  else if(ARADDR_M1[31:16]==16'h0001)	
         ARREADY = ARREADY_S1;
	  else if(ARADDR_M1[31:16]==16'h0002)	
         ARREADY = ARREADY_S2;
	  else if(ARADDR_M1[31:16]==16'h1000)	
         ARREADY = ARREADY_S3;
	  else if(ARADDR_M1[31:24]==8'h20)	
         ARREADY = ARREADY_S4;	 
	  else if(ARADDR_M1[31:16]==16'h3000)	
         ARREADY = ARREADY_S5;	 		 
      else 	ARREADY = 1'd0;	
	end
	default:begin
	  ARREADY = 1'd0;  
	end
  endcase
end
//----AWREADY----//
always_comb
begin
  case(CS_W)
    WriteAddr_M1:begin
	     if(AWADDR_M1[31:16]==16'h0000)
	       AWREADY = AWREADY_S0;
		 else if(AWADDR_M1[31:16]==16'h0001)
	       AWREADY = AWREADY_S1; 
		 else if(AWADDR_M1[31:16]==16'h0002)
	       AWREADY = AWREADY_S2; 		   
		 else if(AWADDR_M1[31:16]==16'h1000)
	       AWREADY = AWREADY_S3; 
		 else if(AWADDR_M1[31:24]==8'h20)
	       AWREADY = AWREADY_S4;
		 else if(AWADDR_M1[31:16]==16'h3000)
	       AWREADY = AWREADY_S5; 		   
		 else AWREADY = 1'd0;	
	end      
	default:begin
	  AWREADY = 1'd0;  
	end
  endcase
end
//----WREADY----//
always_comb
begin
  case(CS_W)
    WriteData_M1S0:begin
      WREADY = WREADY_S0;
	end
	WriteData_M1S1:begin
      WREADY = WREADY_S1;
	end
	WriteData_M1S2:begin
      WREADY = WREADY_S2;
	end
	WriteData_M1S3:begin
      WREADY = WREADY_S3;
	end
	WriteData_M1S4:begin
      WREADY = WREADY_S4;
	end	
	WriteData_M1S5:begin
      WREADY = WREADY_S5;
	end		
	default:begin
	  WREADY = 1'd0;  
	end
  endcase
end
endmodule



