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

module MuxS2M (
        input ACLK,ARESETn,
	input [3:0]CS_R,
	input [3:0]CS_W,  
	input [3:0]NS_R,
	input [3:0]NS_W, 	
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
    //----B----//
	input [`AXI_IDS_BITS-1:0] BID_S0   ,
	input [1:0]               BRESP_S0 ,
	input                     BVALID_S0,
	input [`AXI_IDS_BITS-1:0] BID_S1   ,
	input [1:0]               BRESP_S1 ,
	input                     BVALID_S1,
    //----READY signal----//
    input AWREADY_S0,
    input AWREADY_S1,
    input ARREADY_S0,
    input ARREADY_S1,
    input WREADY_S0 ,
    input WREADY_S1 ,
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

//----R----//
always_comb
begin
		  case(CS_R)
		    `ReadData_M0S0 :begin
		      RID       =     RID_S0       ;
		      RDATA     =     RDATA_S0     ;
		      RRESP     =     RRESP_S0     ;
		      RLAST     =     RLAST_S0     ;
              //if(!RLAST)
		      RVALID    =     RVALID_S0    ;
              //else  
              //RVALID    =     0    ;
			end
		    `ReadData_M1S0:begin
		      RID       =     RID_S0       ;
		      RDATA     =     RDATA_S0     ;
		      RRESP     =     RRESP_S0     ;
		      RLAST     =     RLAST_S0     ;
              //if(!RLAST)
		      RVALID    =     RVALID_S0    ;
              //else  
              //RVALID    =     0    ;
			end			
			`ReadData_M0S1:begin
		      RID       =     RID_S1       ;
		      RDATA     =     RDATA_S1     ;
		      RRESP     =     RRESP_S1     ;
		      RLAST     =     RLAST_S1     ;
              //if(!RLAST)
		      RVALID    =     RVALID_S1    ;
              //else    
              //RVALID    =     0    ;                    
			end
			`ReadData_M1S1:begin
		      RID       =     RID_S1       ;
		      RDATA     =     RDATA_S1     ;
		      RRESP     =     RRESP_S1     ;
		      RLAST     =     RLAST_S1     ;
              //if(!RLAST)
		      RVALID    =     RVALID_S1    ;
              //else    
              //RVALID    =     0    ;                    
			end			
			`Default_Slave:begin
		      RID       =     8'd0            ;
		      RDATA     =     32'd0           ;
		      RRESP     =   RRESP_default  ;
		      RLAST     =     1'd0            ;
		      RVALID    =     1'd0            ;	  
			end			
			default:begin
		      RID       =     8'd0            ;
		      RDATA     =     32'd0           ;
		      RRESP     =     2'd0            ;
		      RLAST     =     1'd0            ;
		      RVALID    =     1'd0            ;	  
			end
		  endcase
end

//----B----//
always_comb
begin
		  case(CS_W)
		    `WriteResp_S0M1:begin
		      BID        =   BID_S0        ;
		      BRESP      =   BRESP_S0      ;
		      BVALID     =   BVALID_S0     ;
			end
			`WriteResp_S1M1:begin
		      BID        =   BID_S1        ;
		      BRESP      =   BRESP_S1      ;
		      BVALID     =   BVALID_S1     ;
			end
			`Default_Slave:begin
		      BID        =   8'd0          ;
		      BRESP      =   BRESP_default ;
		      BVALID     =   1'd0             ;	  
			end			
			default:begin
		      BID        =   8'd0             ;
		      BRESP      =   2'd0             ;
		      BVALID     =   1'd0             ;	  
			end
		  endcase
end

//----ARREADY----//
always_comb
begin
  case(CS_R)
    `ReadAddr_M0:begin
	  if(ARADDR_M0[31:16]==16'd0)
         ARREADY = ARREADY_S0;
	  else if(ARADDR_M0[31:16]==16'd1)	
         ARREADY = ARREADY_S1;
      else 	ARREADY = 1'd0;	 
	end
	`ReadAddr_M1:begin
	  if(ARADDR_M1[31:16]==16'd0)
         ARREADY = ARREADY_S0;
	  else if(ARADDR_M1[31:16]==16'd1)	
         ARREADY = ARREADY_S1;
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
    `WriteAddr_M1:begin
	     if(AWADDR_M1[31:16]==16'd0)
	       AWREADY = AWREADY_S0;
		 else if(AWADDR_M1[31:16]==16'd1)
	       AWREADY = AWREADY_S1; 
		 else AWREADY = 1'd0;	
	end
     `Write_Addr_Data_M1S0:begin
	     //if(AWADDR_M1[31:16]==16'd0)
	       AWREADY = AWREADY_S0;
		 //else if(AWADDR_M1[31:16]==16'd1)
	      // AWREADY = AWREADY_S1; 
		 //else AWREADY = 0;	
	end
    `Write_Addr_Data_M1S1:begin
	   //  if(AWADDR_M1[31:16]==16'd0)
	       AWREADY = AWREADY_S1;
		// else if(AWADDR_M1[31:16]==16'd1)
	      // AWREADY = AWREADY_S1; 
		// else AWREADY = 0;	
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
     `WriteData_M1S0:begin
      WREADY = WREADY_S0;
	end
	`WriteData_M1S1:begin
      WREADY = WREADY_S1;
	end
     `Write_Addr_Data_M1S0:begin
      WREADY = WREADY_S0;
	end
	`Write_Addr_Data_M1S1:begin
      WREADY = WREADY_S1;
	end
	default:begin
	  WREADY = 1'd0;  
	end
  endcase
end
endmodule



