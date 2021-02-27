`include "AXI_define.svh"

module DecoderM2S (
  
  //----AW channel-----//
  input ACLK,ARESETn,
  input [4:0]CS_R,
  input [4:0]CS_W, 
  input [4:0]NS_R,
  input [4:0]NS_W,  
  input [`AXI_ID_BITS-1:0]  AWID   ,
  input [`AXI_ADDR_BITS-1:0] AWADDR ,
  input [`AXI_LEN_BITS-1:0]  AWLEN  ,
  input [`AXI_SIZE_BITS-1:0] AWSIZE ,
  input [1:0]                AWBURST,
  input                      AWVALID,
  //----W channel-----//
  input [`AXI_DATA_BITS-1:0] WDATA  ,
  input [`AXI_STRB_BITS-1:0] WSTRB  ,
  input                      WLAST  ,
  input                      WVALID ,
  //----AR channel----//
  input [`AXI_ID_BITS-1:0]  ARID   , 
  input [`AXI_ADDR_BITS-1:0] ARADDR , 
  input [`AXI_LEN_BITS-1:0]  ARLEN  , 
  input [`AXI_SIZE_BITS-1:0] ARSIZE , 
  input [1:0]                ARBURST, 
  input                      ARVALID,
  //----BREADY/RREADY----//
  input                      RREADY ,
  input                      BREADY ,
  
  //----------output-------------
  //----AW channel-----//
  output logic[`AXI_IDS_BITS-1:0]  AWID_S0   ,
  output logic[`AXI_ADDR_BITS-1:0] AWADDR_S0 ,
  output logic[`AXI_LEN_BITS-1:0]  AWLEN_S0  ,
  output logic[`AXI_SIZE_BITS-1:0] AWSIZE_S0 ,
  output logic[1:0]                AWBURST_S0,
  output logic                     AWVALID_S0,
  output logic[`AXI_IDS_BITS-1:0]  AWID_S1   ,
  output logic[`AXI_ADDR_BITS-1:0] AWADDR_S1 ,
  output logic[`AXI_LEN_BITS-1:0]  AWLEN_S1  ,
  output logic[`AXI_SIZE_BITS-1:0] AWSIZE_S1 ,
  output logic[1:0]                AWBURST_S1,
  output logic                     AWVALID_S1, 
  output logic[`AXI_IDS_BITS-1:0]  AWID_S2   ,
  output logic[`AXI_ADDR_BITS-1:0] AWADDR_S2 ,
  output logic[`AXI_LEN_BITS-1:0]  AWLEN_S2  ,
  output logic[`AXI_SIZE_BITS-1:0] AWSIZE_S2 ,
  output logic[1:0]                AWBURST_S2,
  output logic                     AWVALID_S2,
  output logic[`AXI_IDS_BITS-1:0]  AWID_S3   ,
  output logic[`AXI_ADDR_BITS-1:0] AWADDR_S3 ,
  output logic[`AXI_LEN_BITS-1:0]  AWLEN_S3  ,
  output logic[`AXI_SIZE_BITS-1:0] AWSIZE_S3 ,
  output logic[1:0]                AWBURST_S3,
  output logic                     AWVALID_S3, 
  output logic[`AXI_IDS_BITS-1:0]  AWID_S4   ,
  output logic[`AXI_ADDR_BITS-1:0] AWADDR_S4 ,
  output logic[`AXI_LEN_BITS-1:0]  AWLEN_S4  ,
  output logic[`AXI_SIZE_BITS-1:0] AWSIZE_S4 ,
  output logic[1:0]                AWBURST_S4,
  output logic                     AWVALID_S4,  
  output logic[`AXI_IDS_BITS-1:0]  AWID_S5   ,
  output logic[`AXI_ADDR_BITS-1:0] AWADDR_S5 ,
  output logic[`AXI_LEN_BITS-1:0]  AWLEN_S5  ,
  output logic[`AXI_SIZE_BITS-1:0] AWSIZE_S5 ,
  output logic[1:0]                AWBURST_S5,
  output logic                     AWVALID_S5,   
  //----W channel-----//  
  output logic[`AXI_DATA_BITS-1:0] WDATA_S0  ,
  output logic[`AXI_STRB_BITS-1:0] WSTRB_S0  ,
  output logic                     WLAST_S0  ,
  output logic                     WVALID_S0 ,
  output logic[`AXI_DATA_BITS-1:0] WDATA_S1  ,
  output logic[`AXI_STRB_BITS-1:0] WSTRB_S1  ,
  output logic                     WLAST_S1  ,
  output logic                     WVALID_S1 ,
  output logic[`AXI_DATA_BITS-1:0] WDATA_S2  ,
  output logic[`AXI_STRB_BITS-1:0] WSTRB_S2  ,
  output logic                     WLAST_S2  ,
  output logic                     WVALID_S2 ,
  output logic[`AXI_DATA_BITS-1:0] WDATA_S3  ,
  output logic[`AXI_STRB_BITS-1:0] WSTRB_S3  ,
  output logic                     WLAST_S3  ,
  output logic                     WVALID_S3 ,
  output logic[`AXI_DATA_BITS-1:0] WDATA_S4  ,
  output logic[`AXI_STRB_BITS-1:0] WSTRB_S4  ,
  output logic                     WLAST_S4  ,
  output logic                     WVALID_S4 ,
  output logic[`AXI_DATA_BITS-1:0] WDATA_S5  ,
  output logic[`AXI_STRB_BITS-1:0] WSTRB_S5  ,
  output logic                     WLAST_S5  ,
  output logic                     WVALID_S5 ,  
  //----AR channel----//
  output logic[`AXI_IDS_BITS-1:0]  ARID_S0   ,
  output logic[`AXI_ADDR_BITS-1:0] ARADDR_S0 ,
  output logic[`AXI_LEN_BITS-1:0]  ARLEN_S0  ,
  output logic[`AXI_SIZE_BITS-1:0] ARSIZE_S0 ,
  output logic[1:0]                ARBURST_S0,
  output logic                     ARVALID_S0,
  output logic[`AXI_IDS_BITS-1:0]  ARID_S1   ,
  output logic[`AXI_ADDR_BITS-1:0] ARADDR_S1 ,
  output logic[`AXI_LEN_BITS-1:0]  ARLEN_S1  ,
  output logic[`AXI_SIZE_BITS-1:0] ARSIZE_S1 ,
  output logic[1:0]                ARBURST_S1,
  output logic                     ARVALID_S1,
  output logic[`AXI_IDS_BITS-1:0]  ARID_S2   ,
  output logic[`AXI_ADDR_BITS-1:0] ARADDR_S2 ,
  output logic[`AXI_LEN_BITS-1:0]  ARLEN_S2  ,
  output logic[`AXI_SIZE_BITS-1:0] ARSIZE_S2 ,
  output logic[1:0]                ARBURST_S2,
  output logic                     ARVALID_S2,
  output logic[`AXI_IDS_BITS-1:0]  ARID_S3   ,
  output logic[`AXI_ADDR_BITS-1:0] ARADDR_S3 ,
  output logic[`AXI_LEN_BITS-1:0]  ARLEN_S3  ,
  output logic[`AXI_SIZE_BITS-1:0] ARSIZE_S3 ,
  output logic[1:0]                ARBURST_S3,
  output logic                     ARVALID_S3,
  output logic[`AXI_IDS_BITS-1:0]  ARID_S4   ,
  output logic[`AXI_ADDR_BITS-1:0] ARADDR_S4 ,
  output logic[`AXI_LEN_BITS-1:0]  ARLEN_S4  ,
  output logic[`AXI_SIZE_BITS-1:0] ARSIZE_S4 ,
  output logic[1:0]                ARBURST_S4,
  output logic                     ARVALID_S4,
  output logic[`AXI_IDS_BITS-1:0]  ARID_S5   ,
  output logic[`AXI_ADDR_BITS-1:0] ARADDR_S5 ,
  output logic[`AXI_LEN_BITS-1:0]  ARLEN_S5  ,
  output logic[`AXI_SIZE_BITS-1:0] ARSIZE_S5 ,
  output logic[1:0]                ARBURST_S5,
  output logic                     ARVALID_S5,  

  output logic RREADY_S0   ,
  output logic BREADY_S0   ,
  output logic RREADY_S1   ,
  output logic BREADY_S1   ,
  output logic RREADY_S2   ,
  output logic BREADY_S2   ,
  output logic RREADY_S3   ,
  output logic BREADY_S3   , 
  output logic RREADY_S4   ,
  output logic BREADY_S4   ,
  output logic RREADY_S5   ,
  output logic BREADY_S5   
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

logic AWSEL_S0,AWSEL_S1,AWSEL_Default;
logic ARSEL_S0,ARSEL_S1,ARSEL_Default;
logic [2:0]ARsel_slave,AWsel_slave;
//assign ARsel_slave={ARSEL_S0,ARSEL_S1,ARSEL_Default};
//assign AWsel_slave={AWSEL_S0,AWSEL_S1,AWSEL_Default};

/*
always_comb
begin
  case(AWADDR[31:16])
    16'h0000:begin
       AWsel_slave = 3'd0 ;
	end
	16'h0001:begin
       AWsel_slave = 3'd1 ;
	end
	16'h0002:begin
       AWsel_slave = 3'd2 ;
	end	
	16'h1000:begin
       AWsel_slave = 3'd3 ;
	end
	16'h2000:begin
       AWsel_slave = 3'd4 ;
	end		
	default:begin
       AWsel_slave = 3'd7 ;
	end
  endcase
end
*/
always_comb
begin
  if(AWADDR[31:16]==16'h0000)       AWsel_slave = 3'd0 ;
  else if (AWADDR[31:16]==16'h0001) AWsel_slave = 3'd1 ;
  else if (AWADDR[31:16]==16'h0002) AWsel_slave = 3'd2 ;
  else if (AWADDR[31:16]==16'h1000) AWsel_slave = 3'd3 ;
  else if (AWADDR[31:24]==8'h20)    AWsel_slave = 3'd4 ;
  else if (AWADDR[31:16]==16'h3000) AWsel_slave = 3'd5 ;  
  else                              AWsel_slave = 3'd7 ;
end

always_comb
begin
  if(ARADDR[31:16]==16'h0000)       ARsel_slave = 3'd0 ;
  else if (ARADDR[31:16]==16'h0001) ARsel_slave = 3'd1 ;
  else if (ARADDR[31:16]==16'h0002) ARsel_slave = 3'd2 ;
  else if (ARADDR[31:16]==16'h1000) ARsel_slave = 3'd3 ;
  else if (ARADDR[31:24]==8'h20)    ARsel_slave = 3'd4 ;
  else if (ARADDR[31:16]==16'h3000) ARsel_slave = 3'd5 ;  
  else                              ARsel_slave = 3'd7 ;
end
/*
always_comb
begin
  case(ARADDR[31:16])
    16'h0000:begin
       ARsel_slave = 3'd0 ;
	end
	16'h0001:begin
       ARsel_slave = 3'd1 ;
	end
	16'h0002:begin
       ARsel_slave = 3'd2 ;
	end	
	16'h1000:begin
       ARsel_slave = 3'd3 ;
	end
	16'h2000:begin
       ARsel_slave = 3'd4 ;
	end		
	default:begin
       ARsel_slave = 3'd7 ;
	end
  endcase
end
*/


//----------------AW channel DEmux------------//
always_comb
begin
  case(AWsel_slave)
    3'd0: begin
	  AWID_S0     = {4'b0000,AWID}      ;
	  AWADDR_S0   = AWADDR    ;
	  AWLEN_S0    = AWLEN     ;
	  AWSIZE_S0   = AWSIZE    ;
	  AWBURST_S0  = AWBURST   ;
	  AWVALID_S0  = AWVALID   ;
	  AWID_S1     = 8'd0      ;
	  AWADDR_S1   = 32'd0     ;
	  AWLEN_S1    = 4'd0      ;
	  AWSIZE_S1   = 3'd0      ;
	  AWBURST_S1  = 2'd0      ;
	  AWVALID_S1  = 1'd0      ; 
	  AWID_S2     = 8'd0      ;
	  AWADDR_S2   = 32'd0     ;
	  AWLEN_S2    = 4'd0      ;
	  AWSIZE_S2   = 3'd0      ;
	  AWBURST_S2  = 2'd0      ;
	  AWVALID_S2  = 1'd0      ; 
	  AWID_S3     = 8'd0      ;
	  AWADDR_S3   = 32'd0     ;
	  AWLEN_S3    = 4'd0      ;
	  AWSIZE_S3   = 3'd0      ;
	  AWBURST_S3  = 2'd0      ;
	  AWVALID_S3  = 1'd0      ; 	
	  AWID_S4     = 8'd0      ;
	  AWADDR_S4   = 32'd0     ;
	  AWLEN_S4    = 4'd0      ;
	  AWSIZE_S4   = 3'd0      ;
	  AWBURST_S4  = 2'd0      ;
	  AWVALID_S4  = 1'd0      ; 	 
	  AWID_S5     = 8'd0      ;
	  AWADDR_S5   = 32'd0     ;
	  AWLEN_S5    = 4'd0      ;
	  AWSIZE_S5   = 3'd0      ;
	  AWBURST_S5  = 2'd0      ;
	  AWVALID_S5  = 1'd0      ; 		  
	end
	3'd1: begin
	  AWID_S0     = 8'd0      ;
	  AWADDR_S0   = 32'd0     ;
	  AWLEN_S0    = 4'd0      ;
	  AWSIZE_S0   = 3'd0      ;
	  AWBURST_S0  = 2'd0      ;
	  AWVALID_S0  = 1'd0      ;  
	  AWID_S1     = {4'b0000,AWID}       ;
	  AWADDR_S1   = AWADDR    ;
	  AWLEN_S1    = AWLEN     ;
	  AWSIZE_S1   = AWSIZE    ;
	  AWBURST_S1  = AWBURST   ;
	  AWVALID_S1  = AWVALID   ; 	
	  AWID_S2     = 8'd0      ;
	  AWADDR_S2   = 32'd0     ;
	  AWLEN_S2    = 4'd0      ;
	  AWSIZE_S2   = 3'd0      ;
	  AWBURST_S2  = 2'd0      ;
	  AWVALID_S2  = 1'd0      ; 
	  AWID_S3     = 8'd0      ;
	  AWADDR_S3   = 32'd0     ;
	  AWLEN_S3    = 4'd0      ;
	  AWSIZE_S3   = 3'd0      ;
	  AWBURST_S3  = 2'd0      ;
	  AWVALID_S3  = 1'd0      ; 	
	  AWID_S4     = 8'd0      ;
	  AWADDR_S4   = 32'd0     ;
	  AWLEN_S4    = 4'd0      ;
	  AWSIZE_S4   = 3'd0      ;
	  AWBURST_S4  = 2'd0      ;
	  AWVALID_S4  = 1'd0      ; 
	  AWID_S5     = 8'd0      ;
	  AWADDR_S5   = 32'd0     ;
	  AWLEN_S5    = 4'd0      ;
	  AWSIZE_S5   = 3'd0      ;
	  AWBURST_S5  = 2'd0      ;
	  AWVALID_S5  = 1'd0      ; 	  
	end
	3'd2: begin
	  AWID_S0     = 8'd0      ;
	  AWADDR_S0   = 32'd0     ;
	  AWLEN_S0    = 4'd0      ;
	  AWSIZE_S0   = 3'd0      ;
	  AWBURST_S0  = 2'd0      ;
	  AWVALID_S0  = 1'd0      ;  
	  AWID_S1     = 8'd0      ;
	  AWADDR_S1   = 32'd0     ;
	  AWLEN_S1    = 4'd0      ;
	  AWSIZE_S1   = 3'd0      ;
	  AWBURST_S1  = 2'd0      ;
	  AWVALID_S1  = 1'd0      ;	
	  AWID_S2     = {4'b0000,AWID}       ;
	  AWADDR_S2   = AWADDR    ;
	  AWLEN_S2    = AWLEN     ;
	  AWSIZE_S2   = AWSIZE    ;
	  AWBURST_S2  = AWBURST   ;
	  AWVALID_S2  = AWVALID   ; 	 
	  AWID_S3     = 8'd0      ;
	  AWADDR_S3   = 32'd0     ;
	  AWLEN_S3    = 4'd0      ;
	  AWSIZE_S3   = 3'd0      ;
	  AWBURST_S3  = 2'd0      ;
	  AWVALID_S3  = 1'd0      ; 	
	  AWID_S4     = 8'd0      ;
	  AWADDR_S4   = 32'd0     ;
	  AWLEN_S4    = 4'd0      ;
	  AWSIZE_S4   = 3'd0      ;
	  AWBURST_S4  = 2'd0      ;
	  AWVALID_S4  = 1'd0      ; 
	  AWID_S5     = 8'd0      ;
	  AWADDR_S5   = 32'd0     ;
	  AWLEN_S5    = 4'd0      ;
	  AWSIZE_S5   = 3'd0      ;
	  AWBURST_S5  = 2'd0      ;
	  AWVALID_S5  = 1'd0      ; 	  
	end	
	3'd3: begin
	  AWID_S0     = 8'd0      ;
	  AWADDR_S0   = 32'd0     ;
	  AWLEN_S0    = 4'd0      ;
	  AWSIZE_S0   = 3'd0      ;
	  AWBURST_S0  = 2'd0      ;
	  AWVALID_S0  = 1'd0      ;  
	  AWID_S1     = 8'd0      ;
	  AWADDR_S1   = 32'd0     ;
	  AWLEN_S1    = 4'd0      ;
	  AWSIZE_S1   = 3'd0      ;
	  AWBURST_S1  = 2'd0      ;
	  AWVALID_S1  = 1'd0      ;	
	  AWID_S2     = 8'd0      ;
	  AWADDR_S2   = 32'd0     ;
	  AWLEN_S2    = 4'd0      ;
	  AWSIZE_S2   = 3'd0      ;
	  AWBURST_S2  = 2'd0      ;
	  AWVALID_S2  = 1'd0      ; 
	  AWID_S3     = {4'b0000,AWID}       ;
	  AWADDR_S3   = AWADDR    ;
	  AWLEN_S3    = AWLEN     ;
	  AWSIZE_S3   = AWSIZE    ;
	  AWBURST_S3  = AWBURST   ;
	  AWVALID_S3  = AWVALID   ; 		
	  AWID_S4     = 8'd0      ;
	  AWADDR_S4   = 32'd0     ;
	  AWLEN_S4    = 4'd0      ;
	  AWSIZE_S4   = 3'd0      ;
	  AWBURST_S4  = 2'd0      ;
	  AWVALID_S4  = 1'd0      ;
	  AWID_S5     = 8'd0      ;
	  AWADDR_S5   = 32'd0     ;
	  AWLEN_S5    = 4'd0      ;
	  AWSIZE_S5   = 3'd0      ;
	  AWBURST_S5  = 2'd0      ;
	  AWVALID_S5  = 1'd0      ;  	  
	end		
	3'd4: begin
	  AWID_S0     = 8'd0      ;
	  AWADDR_S0   = 32'd0     ;
	  AWLEN_S0    = 4'd0      ;
	  AWSIZE_S0   = 3'd0      ;
	  AWBURST_S0  = 2'd0      ;
	  AWVALID_S0  = 1'd0      ;  
	  AWID_S1     = 8'd0      ;
	  AWADDR_S1   = 32'd0     ;
	  AWLEN_S1    = 4'd0      ;
	  AWSIZE_S1   = 3'd0      ;
	  AWBURST_S1  = 2'd0      ;
	  AWVALID_S1  = 1'd0      ;	
	  AWID_S2     = 8'd0      ;
	  AWADDR_S2   = 32'd0     ;
	  AWLEN_S2    = 4'd0      ;
	  AWSIZE_S2   = 3'd0      ;
	  AWBURST_S2  = 2'd0      ;
	  AWVALID_S2  = 1'd0      ; 
	  AWID_S3     = 8'd0      ;
	  AWADDR_S3   = 32'd0     ;
	  AWLEN_S3    = 4'd0      ;
	  AWSIZE_S3   = 3'd0      ;
	  AWBURST_S3  = 2'd0      ;
	  AWVALID_S3  = 1'd0      ; 	
	  AWID_S4     = {4'b0000,AWID};
	  AWADDR_S4   = AWADDR    ;
	  AWLEN_S4    = AWLEN     ;
	  AWSIZE_S4   = AWSIZE    ;
	  AWBURST_S4  = AWBURST   ;
	  AWVALID_S4  = AWVALID   ; 
	  AWID_S5     = 8'd0      ;
	  AWADDR_S5   = 32'd0     ;
	  AWLEN_S5    = 4'd0      ;
	  AWSIZE_S5   = 3'd0      ;
	  AWBURST_S5  = 2'd0      ;
	  AWVALID_S5  = 1'd0      ; 	  
	end	
	3'd5:begin
	  AWID_S0     = 8'd0      ;
	  AWADDR_S0   = 32'd0     ;
	  AWLEN_S0    = 4'd0      ;
	  AWSIZE_S0   = 3'd0      ;
	  AWBURST_S0  = 2'd0      ;
	  AWVALID_S0  = 1'd0      ;  
	  AWID_S1     = 8'd0      ;
	  AWADDR_S1   = 32'd0     ;
	  AWLEN_S1    = 4'd0      ;
	  AWSIZE_S1   = 3'd0      ;
	  AWBURST_S1  = 2'd0      ;
	  AWVALID_S1  = 1'd0      ;	
	  AWID_S2     = 8'd0      ;
	  AWADDR_S2   = 32'd0     ;
	  AWLEN_S2    = 4'd0      ;
	  AWSIZE_S2   = 3'd0      ;
	  AWBURST_S2  = 2'd0      ;
	  AWVALID_S2  = 1'd0      ; 
	  AWID_S3     = 8'd0      ;
	  AWADDR_S3   = 32'd0     ;
	  AWLEN_S3    = 4'd0      ;
	  AWSIZE_S3   = 3'd0      ;
	  AWBURST_S3  = 2'd0      ;
	  AWVALID_S3  = 1'd0      ; 	
	  AWID_S4     = 8'd0      ;
	  AWADDR_S4   = 32'd0     ;
	  AWLEN_S4    = 4'd0      ;
	  AWSIZE_S4   = 3'd0      ;
	  AWBURST_S4  = 2'd0      ;
	  AWVALID_S4  = 1'd0      ; 
	  AWID_S5     = {4'b0000,AWID};
	  AWADDR_S5   = AWADDR    ;
	  AWLEN_S5    = AWLEN     ;
	  AWSIZE_S5   = AWSIZE    ;
	  AWBURST_S5  = AWBURST   ;
	  AWVALID_S5  = AWVALID   ; 	  
	end	
	default:begin
	  AWID_S0     = 8'd0      ;
	  AWADDR_S0   = 32'd0     ;
	  AWLEN_S0    = 4'd0      ;
	  AWSIZE_S0   = 3'd0      ;
	  AWBURST_S0  = 2'd0      ;
	  AWVALID_S0  = 1'd0      ;  
	  AWID_S1     = 8'd0      ;
	  AWADDR_S1   = 32'd0     ;
	  AWLEN_S1    = 4'd0      ;
	  AWSIZE_S1   = 3'd0      ;
	  AWBURST_S1  = 2'd0      ;
	  AWVALID_S1  = 1'd0      ;	
	  AWID_S2     = 8'd0      ;
	  AWADDR_S2   = 32'd0     ;
	  AWLEN_S2    = 4'd0      ;
	  AWSIZE_S2   = 3'd0      ;
	  AWBURST_S2  = 2'd0      ;
	  AWVALID_S2  = 1'd0      ; 
	  AWID_S3     = 8'd0      ;
	  AWADDR_S3   = 32'd0     ;
	  AWLEN_S3    = 4'd0      ;
	  AWSIZE_S3   = 3'd0      ;
	  AWBURST_S3  = 2'd0      ;
	  AWVALID_S3  = 1'd0      ; 	
	  AWID_S4     = 8'd0      ;
	  AWADDR_S4   = 32'd0     ;
	  AWLEN_S4    = 4'd0      ;
	  AWSIZE_S4   = 3'd0      ;
	  AWBURST_S4  = 2'd0      ;
	  AWVALID_S4  = 1'd0      ; 
	  AWID_S5     = 8'd0      ;
	  AWADDR_S5   = 32'd0     ;
	  AWLEN_S5    = 4'd0      ;
	  AWSIZE_S5   = 3'd0      ;
	  AWBURST_S5  = 2'd0      ;
	  AWVALID_S5  = 1'd0      ; 	  
	end
  endcase  
end


//----------------W channel DEmux------------//
always_comb
begin
  case(CS_W)
    WriteData_M1S0: begin
	  WDATA_S0   = WDATA      ;
	  WSTRB_S0   = WSTRB      ;
	  WLAST_S0   = WLAST      ;
	  WVALID_S0  = WVALID     ;
	  WDATA_S1   = 32'd0      ;
	  WSTRB_S1   = 4'hf       ;
	  WLAST_S1   = 1'd0       ;
	  WVALID_S1	 = 1'd0       ;	 	
	  WDATA_S2   = 32'd0      ;
	  WSTRB_S2   = 4'hf       ;
	  WLAST_S2   = 1'd0       ;
	  WVALID_S2	 = 1'd0       ;	 
	  WDATA_S3   = 32'd0      ;
	  WSTRB_S3   = 4'hf       ;
	  WLAST_S3   = 1'd0       ;
	  WVALID_S3	 = 1'd0       ;	 	
	  WDATA_S4   = 32'd0      ;
	  WSTRB_S4   = 4'hf       ;
	  WLAST_S4   = 1'd0       ;
	  WVALID_S4	 = 1'd0       ;	 
	  WDATA_S5   = 32'd0      ;
	  WSTRB_S5   = 4'hf       ;
	  WLAST_S5   = 1'd0       ;
	  WVALID_S5	 = 1'd0       ;	 	  
	end
	WriteData_M1S1: begin
	  WDATA_S0   = 32'd0      ;
	  WSTRB_S0   = 4'hf       ;
	  WLAST_S0   = 1'd0       ;
	  WVALID_S0  = 1'd0       ;	  
	  WDATA_S1   = WDATA      ; 
	  WSTRB_S1   = WSTRB      ; 
	  WLAST_S1   = WLAST      ; 
	  WVALID_S1	 = WVALID     ; 
	  WDATA_S2   = 32'd0      ;
	  WSTRB_S2   = 4'hf       ;
	  WLAST_S2   = 1'd0       ;
	  WVALID_S2	 = 1'd0       ;	 
	  WDATA_S3   = 32'd0      ;
	  WSTRB_S3   = 4'hf       ;
	  WLAST_S3   = 1'd0       ;
	  WVALID_S3	 = 1'd0       ;	 	
	  WDATA_S4   = 32'd0      ;
	  WSTRB_S4   = 4'hf       ;
	  WLAST_S4   = 1'd0       ;
	  WVALID_S4	 = 1'd0       ;	 
	  WDATA_S5   = 32'd0      ;
	  WSTRB_S5   = 4'hf       ;
	  WLAST_S5   = 1'd0       ;
	  WVALID_S5	 = 1'd0       ;		  
	end
	WriteData_M1S2: begin
	  WDATA_S0   = 32'd0      ;
	  WSTRB_S0   = 4'hf       ;
	  WLAST_S0   = 1'd0       ;
	  WVALID_S0  = 1'd0       ;	  
	  WDATA_S1   = 32'd0      ; 
	  WSTRB_S1   = 4'hf       ; 
	  WLAST_S1   = 1'd0       ; 
	  WVALID_S1	 = 1'd0       ; 	
	  WDATA_S2   = WDATA      ;
	  WSTRB_S2   = WSTRB      ;
	  WLAST_S2   = WLAST      ;
	  WVALID_S2	 = WVALID     ;	 
	  WDATA_S3   = 32'd0      ;
	  WSTRB_S3   = 4'hf       ;
	  WLAST_S3   = 1'd0       ;
	  WVALID_S3	 = 1'd0       ;	 	
	  WDATA_S4   = 32'd0      ;
	  WSTRB_S4   = 4'hf       ;
	  WLAST_S4   = 1'd0       ;
	  WVALID_S4	 = 1'd0       ;
	  WDATA_S5   = 32'd0      ;
	  WSTRB_S5   = 4'hf       ;
	  WLAST_S5   = 1'd0       ;
	  WVALID_S5	 = 1'd0       ;		  
	end
	WriteData_M1S3: begin
	  WDATA_S0   = 32'd0      ;
	  WSTRB_S0   = 4'hf       ;
	  WLAST_S0   = 1'd0       ;
	  WVALID_S0  = 1'd0       ;	  
	  WDATA_S1   = 32'd0      ; 
	  WSTRB_S1   = 4'hf       ; 
	  WLAST_S1   = 1'd0       ; 
	  WVALID_S1	 = 1'd0       ; 	
	  WDATA_S2   = 32'd0      ;
	  WSTRB_S2   = 4'hf       ;
	  WLAST_S2   = 1'd0       ;
	  WVALID_S2	 = 1'd0       ;	 
	  WDATA_S3   = WDATA      ;
	  WSTRB_S3   = WSTRB      ;
	  WLAST_S3   = WLAST      ;
	  WVALID_S3	 = WVALID     ;	 	
	  WDATA_S4   = 32'd0      ;
	  WSTRB_S4   = 4'hf       ;
	  WLAST_S4   = 1'd0       ;
	  WVALID_S4	 = 1'd0       ;
	  WDATA_S5   = 32'd0      ;
	  WSTRB_S5   = 4'hf       ;
	  WLAST_S5   = 1'd0       ;
	  WVALID_S5	 = 1'd0       ;		  
	end		
	WriteData_M1S4: begin
	  WDATA_S0   = 32'd0      ;
	  WSTRB_S0   = 4'hf       ;
	  WLAST_S0   = 1'd0       ;
	  WVALID_S0  = 1'd0       ;	  
	  WDATA_S1   = 32'd0      ; 
	  WSTRB_S1   = 4'hf       ; 
	  WLAST_S1   = 1'd0       ; 
	  WVALID_S1	 = 1'd0       ; 	
	  WDATA_S2   = 32'd0      ;
	  WSTRB_S2   = 4'hf       ;
	  WLAST_S2   = 1'd0       ;
	  WVALID_S2	 = 1'd0       ;	 
	  WDATA_S3   = 32'd0      ;
	  WSTRB_S3   = 4'hf       ;
	  WLAST_S3   = 1'd0       ;
	  WVALID_S3	 = 1'd0       ;	 	
	  WDATA_S4   = WDATA      ;
	  WSTRB_S4   = WSTRB      ;
	  WLAST_S4   = WLAST      ;
	  WVALID_S4	 = WVALID     ;	
	  WDATA_S5   = 32'd0      ;
	  WSTRB_S5   = 4'hf       ;
	  WLAST_S5   = 1'd0       ;
	  WVALID_S5	 = 1'd0       ;	 	  
	end		
	WriteData_M1S5:begin
	  WDATA_S0   = 32'd0      ;
	  WSTRB_S0   = 4'hf       ;
	  WLAST_S0   = 1'd0       ;
	  WVALID_S0  = 1'd0       ;	  
	  WDATA_S1   = 32'd0      ; 
	  WSTRB_S1   = 4'hf       ; 
	  WLAST_S1   = 1'd0       ; 
	  WVALID_S1	 = 1'd0       ; 	
	  WDATA_S2   = 32'd0      ;
	  WSTRB_S2   = 4'hf       ;
	  WLAST_S2   = 1'd0       ;
	  WVALID_S2	 = 1'd0       ;	 
	  WDATA_S3   = 32'd0      ;
	  WSTRB_S3   = 4'hf       ;
	  WLAST_S3   = 1'd0       ;
	  WVALID_S3	 = 1'd0       ;	 	
	  WDATA_S4   = 32'd0      ;
	  WSTRB_S4   = 4'hf       ;
	  WLAST_S4   = 1'd0       ;
	  WVALID_S4	 = 1'd0       ;	 
	  WDATA_S5   = WDATA      ;
	  WSTRB_S5   = WSTRB      ;
	  WLAST_S5   = WLAST      ;
	  WVALID_S5	 = WVALID     ;	  
	end	
	default:begin
	  WDATA_S0   = 32'd0      ;
	  WSTRB_S0   = 4'hf       ;
	  WLAST_S0   = 1'd0       ;
	  WVALID_S0  = 1'd0       ;	  
	  WDATA_S1   = 32'd0      ; 
	  WSTRB_S1   = 4'hf       ; 
	  WLAST_S1   = 1'd0       ; 
	  WVALID_S1	 = 1'd0       ; 	
	  WDATA_S2   = 32'd0      ;
	  WSTRB_S2   = 4'hf       ;
	  WLAST_S2   = 1'd0       ;
	  WVALID_S2	 = 1'd0       ;	 
	  WDATA_S3   = 32'd0      ;
	  WSTRB_S3   = 4'hf       ;
	  WLAST_S3   = 1'd0       ;
	  WVALID_S3	 = 1'd0       ;	 	
	  WDATA_S4   = 32'd0      ;
	  WSTRB_S4   = 4'hf       ;
	  WLAST_S4   = 1'd0       ;
	  WVALID_S4	 = 1'd0       ;	 
	  WDATA_S5   = 32'd0      ;
	  WSTRB_S5   = 4'hf       ;
	  WLAST_S5   = 1'd0       ;
	  WVALID_S5	 = 1'd0       ;		  
	end
  endcase  
end

//--------------AR channel DEmux------------//
always_comb
begin
  case(ARsel_slave)
    3'd0: begin
	  ARID_S0     = {4'b0000,ARID};
	  ARADDR_S0   = ARADDR        ;
	  ARLEN_S0    = ARLEN         ;
	  ARSIZE_S0   = ARSIZE        ;
	  ARBURST_S0  = ARBURST       ;
	  ARVALID_S0  = ARVALID       ;
	  ARID_S1     = 8'd0          ;
	  ARADDR_S1   = 32'd0         ;
	  ARLEN_S1    = 4'd0          ;
	  ARSIZE_S1   = 3'd0          ;
	  ARBURST_S1  = 2'd0          ;
	  ARVALID_S1  = 1'd0          ;  
	  ARID_S2     = 8'd0          ;
	  ARADDR_S2   = 32'd0         ;
	  ARLEN_S2    = 4'd0          ;
	  ARSIZE_S2   = 3'd0          ;
	  ARBURST_S2  = 2'd0          ;
	  ARVALID_S2  = 1'd0          ; 
	  ARID_S3     = 8'd0          ;
	  ARADDR_S3   = 32'd0         ;
	  ARLEN_S3    = 4'd0          ;
	  ARSIZE_S3   = 3'd0          ;
	  ARBURST_S3  = 2'd0          ;
	  ARVALID_S3  = 1'd0          ;  
	  ARID_S4     = 8'd0          ;
	  ARADDR_S4   = 32'd0         ;
	  ARLEN_S4    = 4'd0          ;
	  ARSIZE_S4   = 3'd0          ;
	  ARBURST_S4  = 2'd0          ;
	  ARVALID_S4  = 1'd0          ;   	
	  ARID_S5     = 8'd0          ;
	  ARADDR_S5   = 32'd0         ;
	  ARLEN_S5    = 4'd0          ;
	  ARSIZE_S5   = 3'd0          ;
	  ARBURST_S5  = 2'd0          ;
	  ARVALID_S5  = 1'd0          ;   	  
	end
	3'd1: begin
	  ARID_S0     = 8'd0          ;
	  ARADDR_S0   = 32'd0         ;
	  ARLEN_S0    = 4'd0          ;
	  ARSIZE_S0   = 3'd0          ;
	  ARBURST_S0  = 2'd0          ;
	  ARVALID_S0  = 1'd0          ;  
	  ARID_S1     = {4'b0000,ARID};
	  ARADDR_S1   = ARADDR        ;
	  ARLEN_S1    = ARLEN         ;
	  ARSIZE_S1   = ARSIZE        ;
	  ARBURST_S1  = ARBURST       ;
	  ARVALID_S1  = ARVALID       ; 
	  ARID_S2     = 8'd0          ;
	  ARADDR_S2   = 32'd0         ;
	  ARLEN_S2    = 4'd0          ;
	  ARSIZE_S2   = 3'd0          ;
	  ARBURST_S2  = 2'd0          ;
	  ARVALID_S2  = 1'd0          ; 
	  ARID_S3     = 8'd0          ;
	  ARADDR_S3   = 32'd0         ;
	  ARLEN_S3    = 4'd0          ;
	  ARSIZE_S3   = 3'd0          ;
	  ARBURST_S3  = 2'd0          ;
	  ARVALID_S3  = 1'd0          ;  
	  ARID_S4     = 8'd0          ;
	  ARADDR_S4   = 32'd0         ;
	  ARLEN_S4    = 4'd0          ;
	  ARSIZE_S4   = 3'd0          ;
	  ARBURST_S4  = 2'd0          ;
	  ARVALID_S4  = 1'd0          ;  
	  ARID_S5     = 8'd0          ;
	  ARADDR_S5   = 32'd0         ;
	  ARLEN_S5    = 4'd0          ;
	  ARSIZE_S5   = 3'd0          ;
	  ARBURST_S5  = 2'd0          ;
	  ARVALID_S5  = 1'd0          ; 	  
	end
	3'd2:begin
	  ARID_S0     = 8'd0          ;
	  ARADDR_S0   = 32'd0         ;
	  ARLEN_S0    = 4'd0          ;
	  ARSIZE_S0   = 3'd0          ;
	  ARBURST_S0  = 2'd0          ;
	  ARVALID_S0  = 1'd0          ;  
	  ARID_S1     = 8'd0          ;
	  ARADDR_S1   = 32'd0         ;
	  ARLEN_S1    = 4'd0          ;
	  ARSIZE_S1   = 3'd0          ;
	  ARBURST_S1  = 2'd0          ;
	  ARVALID_S1  = 1'd0          ;	
	  ARID_S2     = {4'b0000,ARID};
	  ARADDR_S2   = ARADDR        ;
	  ARLEN_S2    = ARLEN         ;
	  ARSIZE_S2   = ARSIZE        ;
	  ARBURST_S2  = ARBURST       ;
	  ARVALID_S2  = ARVALID       ;
	  ARID_S3     = 8'd0          ;
	  ARADDR_S3   = 32'd0         ;
	  ARLEN_S3    = 4'd0          ;
	  ARSIZE_S3   = 3'd0          ;
	  ARBURST_S3  = 2'd0          ;
	  ARVALID_S3  = 1'd0          ;  
	  ARID_S4     = 8'd0          ;
	  ARADDR_S4   = 32'd0         ;
	  ARLEN_S4    = 4'd0          ;
	  ARSIZE_S4   = 3'd0          ;
	  ARBURST_S4  = 2'd0          ;
	  ARVALID_S4  = 1'd0          ; 
	  ARID_S5     = 8'd0          ;
	  ARADDR_S5   = 32'd0         ;
	  ARLEN_S5    = 4'd0          ;
	  ARSIZE_S5   = 3'd0          ;
	  ARBURST_S5  = 2'd0          ;
	  ARVALID_S5  = 1'd0          ;  	  
	end	
	3'd3:begin
	  ARID_S0     = 8'd0          ;
	  ARADDR_S0   = 32'd0         ;
	  ARLEN_S0    = 4'd0          ;
	  ARSIZE_S0   = 3'd0          ;
	  ARBURST_S0  = 2'd0          ;
	  ARVALID_S0  = 1'd0          ;  
	  ARID_S1     = 8'd0          ;
	  ARADDR_S1   = 32'd0         ;
	  ARLEN_S1    = 4'd0          ;
	  ARSIZE_S1   = 3'd0          ;
	  ARBURST_S1  = 2'd0          ;
	  ARVALID_S1  = 1'd0          ;	
	  ARID_S2     = 8'd0          ;
	  ARADDR_S2   = 32'd0         ;
	  ARLEN_S2    = 4'd0          ;
	  ARSIZE_S2   = 3'd0          ;
	  ARBURST_S2  = 2'd0          ;
	  ARVALID_S2  = 1'd0          ; 
	  ARID_S3     = {4'b0000,ARID};
	  ARADDR_S3   = ARADDR        ;
	  ARLEN_S3    = ARLEN         ;
	  ARSIZE_S3   = ARSIZE        ;
	  ARBURST_S3  = ARBURST       ;
	  ARVALID_S3  = ARVALID       ;  
	  ARID_S4     = 8'd0          ;
	  ARADDR_S4   = 32'd0         ;
	  ARLEN_S4    = 4'd0          ;
	  ARSIZE_S4   = 3'd0          ;
	  ARBURST_S4  = 2'd0          ;
	  ARVALID_S4  = 1'd0          ;
	  ARID_S5     = 8'd0          ;
	  ARADDR_S5   = 32'd0         ;
	  ARLEN_S5    = 4'd0          ;
	  ARSIZE_S5   = 3'd0          ;
	  ARBURST_S5  = 2'd0          ;
	  ARVALID_S5  = 1'd0          ;   	  
	end	
	3'd4:begin
	  ARID_S0     = 8'd0          ;
	  ARADDR_S0   = 32'd0         ;
	  ARLEN_S0    = 4'd0          ;
	  ARSIZE_S0   = 3'd0          ;
	  ARBURST_S0  = 2'd0          ;
	  ARVALID_S0  = 1'd0          ;  
	  ARID_S1     = 8'd0          ;
	  ARADDR_S1   = 32'd0         ;
	  ARLEN_S1    = 4'd0          ;
	  ARSIZE_S1   = 3'd0          ;
	  ARBURST_S1  = 2'd0          ;
	  ARVALID_S1  = 1'd0          ;	
	  ARID_S2     = 8'd0          ;
	  ARADDR_S2   = 32'd0         ;
	  ARLEN_S2    = 4'd0          ;
	  ARSIZE_S2   = 3'd0          ;
	  ARBURST_S2  = 2'd0          ;
	  ARVALID_S2  = 1'd0          ; 
	  ARID_S3     = 8'd0          ;
	  ARADDR_S3   = 32'd0         ;
	  ARLEN_S3    = 4'd0          ;
	  ARSIZE_S3   = 3'd0          ;
	  ARBURST_S3  = 2'd0          ;
	  ARVALID_S3  = 1'd0          ;  
	  ARID_S4     = {4'b0000,ARID};
	  ARADDR_S4   = ARADDR        ;
	  ARLEN_S4    = ARLEN         ;
	  ARSIZE_S4   = ARSIZE        ;
	  ARBURST_S4  = ARBURST       ;
	  ARVALID_S4  = ARVALID       ; 
	  ARID_S5     = 8'd0          ;
	  ARADDR_S5   = 32'd0         ;
	  ARLEN_S5    = 4'd0          ;
	  ARSIZE_S5   = 3'd0          ;
	  ARBURST_S5  = 2'd0          ;
	  ARVALID_S5  = 1'd0          ;  	  
	end
	3'd5:begin
	  ARID_S0     = 8'd0          ;
	  ARADDR_S0   = 32'd0         ;
	  ARLEN_S0    = 4'd0          ;
	  ARSIZE_S0   = 3'd0          ;
	  ARBURST_S0  = 2'd0          ;
	  ARVALID_S0  = 1'd0          ;  
	  ARID_S1     = 8'd0          ;
	  ARADDR_S1   = 32'd0         ;
	  ARLEN_S1    = 4'd0          ;
	  ARSIZE_S1   = 3'd0          ;
	  ARBURST_S1  = 2'd0          ;
	  ARVALID_S1  = 1'd0          ;	
	  ARID_S2     = 8'd0          ;
	  ARADDR_S2   = 32'd0         ;
	  ARLEN_S2    = 4'd0          ;
	  ARSIZE_S2   = 3'd0          ;
	  ARBURST_S2  = 2'd0          ;
	  ARVALID_S2  = 1'd0          ; 
	  ARID_S3     = 8'd0          ;
	  ARADDR_S3   = 32'd0         ;
	  ARLEN_S3    = 4'd0          ;
	  ARSIZE_S3   = 3'd0          ;
	  ARBURST_S3  = 2'd0          ;
	  ARVALID_S3  = 1'd0          ;  
	  ARID_S4     = 8'd0          ;
	  ARADDR_S4   = 32'd0         ;
	  ARLEN_S4    = 4'd0          ;
	  ARSIZE_S4   = 3'd0          ;
	  ARBURST_S4  = 2'd0          ;
	  ARVALID_S4  = 1'd0          ;
	  ARID_S5     = {4'b0000,ARID};
	  ARADDR_S5   = ARADDR        ;
	  ARLEN_S5    = ARLEN         ;
	  ARSIZE_S5   = ARSIZE        ;
	  ARBURST_S5  = ARBURST       ;
	  ARVALID_S5  = ARVALID       ;   	  
	end	
	default:begin
	  ARID_S0     = 8'd0          ;
	  ARADDR_S0   = 32'd0         ;
	  ARLEN_S0    = 4'd0          ;
	  ARSIZE_S0   = 3'd0          ;
	  ARBURST_S0  = 2'd0          ;
	  ARVALID_S0  = 1'd0          ;  
	  ARID_S1     = 8'd0          ;
	  ARADDR_S1   = 32'd0         ;
	  ARLEN_S1    = 4'd0          ;
	  ARSIZE_S1   = 3'd0          ;
	  ARBURST_S1  = 2'd0          ;
	  ARVALID_S1  = 1'd0          ;	
	  ARID_S2     = 8'd0          ;
	  ARADDR_S2   = 32'd0         ;
	  ARLEN_S2    = 4'd0          ;
	  ARSIZE_S2   = 3'd0          ;
	  ARBURST_S2  = 2'd0          ;
	  ARVALID_S2  = 1'd0          ; 
	  ARID_S3     = 8'd0          ;
	  ARADDR_S3   = 32'd0         ;
	  ARLEN_S3    = 4'd0          ;
	  ARSIZE_S3   = 3'd0          ;
	  ARBURST_S3  = 2'd0          ;
	  ARVALID_S3  = 1'd0          ;  
	  ARID_S4     = 8'd0          ;
	  ARADDR_S4   = 32'd0         ;
	  ARLEN_S4    = 4'd0          ;
	  ARSIZE_S4   = 3'd0          ;
	  ARBURST_S4  = 2'd0          ;
	  ARVALID_S4  = 1'd0          ;
	  ARID_S5     = 8'd0          ;
	  ARADDR_S5   = 32'd0         ;
	  ARLEN_S5    = 4'd0          ;
	  ARSIZE_S5   = 3'd0          ;
	  ARBURST_S5  = 2'd0          ;
	  ARVALID_S5  = 1'd0          ;   	  
	end
  endcase  
end


//----RREADY/BREADY----//
always_comb
begin
  case(CS_W)
    WriteResp_S0M1: begin
	   BREADY_S0 = BREADY ;
	   BREADY_S1 = 1'b0   ;
	   BREADY_S2 = 1'b0   ;	   
	   BREADY_S3 = 1'b0   ;	   
	   BREADY_S4 = 1'b0   ;	   
	   BREADY_S5 = 1'b0   ;	 	   
	end
	WriteResp_S1M1: begin
	   BREADY_S0 = 1'b0   ;
	   BREADY_S1 = BREADY ;	 
	   BREADY_S2 = 1'b0   ;	   
	   BREADY_S3 = 1'b0   ;	   
	   BREADY_S4 = 1'b0   ;	 
	   BREADY_S5 = 1'b0   ;	 	   
	end
    WriteResp_S2M1: begin
	   BREADY_S0 = 1'b0   ;
	   BREADY_S1 = 1'b0   ;		
	   BREADY_S2 = BREADY ;	   
	   BREADY_S3 = 1'b0   ;	   
	   BREADY_S4 = 1'b0   ;	 
	   BREADY_S5 = 1'b0   ;	   
	end
	WriteResp_S3M1: begin
	   BREADY_S0 = 1'b0   ;
	   BREADY_S1 = 1'b0   ;		
	   BREADY_S2 = 1'b0   ;	   
	   BREADY_S3 = BREADY ;	   
	   BREADY_S4 = 1'b0   ;		
	   BREADY_S5 = 1'b0   ;	   
	end
    WriteResp_S4M1: begin
	   BREADY_S0 = 1'b0   ;
	   BREADY_S1 = 1'b0   ;		
	   BREADY_S2 = 1'b0   ;	   
	   BREADY_S3 = 1'b0   ;	   
	   BREADY_S4 = BREADY ;	
	   BREADY_S5 = 1'b0   ; 	   
	end
	WriteResp_S5M1:begin
	   BREADY_S0 = 1'b0   ;
	   BREADY_S1 = 1'b0   ;		
	   BREADY_S2 = 1'b0   ;	   
	   BREADY_S3 = 1'b0   ;	   
	   BREADY_S4 = 1'b0   ;	 
	   BREADY_S5 = BREADY ;	   
	end	
	default:begin
	   BREADY_S0 = 1'b0   ;
	   BREADY_S1 = 1'b0   ;		
	   BREADY_S2 = 1'b0   ;	   
	   BREADY_S3 = 1'b0   ;	   
	   BREADY_S4 = 1'b0   ;	 
	   BREADY_S5 = 1'b0   ;	   
	end
  endcase  
end
//----RREADY/BREADY----//
always_comb
begin
  case(CS_R)
    ReadData_M0S0: begin
	   RREADY_S0 = RREADY ;
	   RREADY_S1 = 1'b0   ;
       RREADY_S2 = 1'b0   ;	
       RREADY_S3 = 1'b0   ;	
       RREADY_S4 = 1'b0   ;	
       RREADY_S5 = 1'b0   ;		   
	end
    ReadData_M1S0: begin
	   RREADY_S0 = RREADY ;
	   RREADY_S1 = 1'b0   ;	
       RREADY_S2 = 1'b0   ;	
       RREADY_S3 = 1'b0   ;	
       RREADY_S4 = 1'b0   ;
       RREADY_S5 = 1'b0   ;		   
	end	
    ReadData_M0S1: begin
	   RREADY_S0 = 1'b0   ;
	   RREADY_S1 = RREADY ;	
       RREADY_S2 = 1'b0   ;	
       RREADY_S3 = 1'b0   ;	
       RREADY_S4 = 1'b0   ;		
       RREADY_S5 = 1'b0   ;		   
	end
    ReadData_M1S1: begin
	   RREADY_S0 = 1'b0   ;
	   RREADY_S1 = RREADY ;	
       RREADY_S2 = 1'b0   ;	
       RREADY_S3 = 1'b0   ;	
       RREADY_S4 = 1'b0   ;	
       RREADY_S5 = 1'b0   ;		   
	end		
	ReadData_M0S2: begin
	   RREADY_S0 = 1'b0   ;
	   RREADY_S1 = 1'b0   ;	
       RREADY_S2 = RREADY ;	
       RREADY_S3 = 1'b0   ;	
       RREADY_S4 = 1'b0   ;	
       RREADY_S5 = 1'b0   ;		   
	end	
	ReadData_M1S2: begin
	   RREADY_S0 = 1'b0   ;
	   RREADY_S1 = 1'b0   ;	
       RREADY_S2 = RREADY ;	
       RREADY_S3 = 1'b0   ;	
       RREADY_S4 = 1'b0   ;	
       RREADY_S5 = 1'b0   ;		   
	end	
	ReadData_M0S3:begin
	   RREADY_S0 = 1'b0   ;
	   RREADY_S1 = 1'b0   ;	
       RREADY_S2 = 1'b0   ;	
       RREADY_S3 = RREADY ;
       RREADY_S4 = 1'b0   ;	
       RREADY_S5 = 1'b0   ;		   
	end	
	ReadData_M1S3:begin
	   RREADY_S0 = 1'b0   ;
	   RREADY_S1 = 1'b0   ;	
       RREADY_S2 = 1'b0   ;	
       RREADY_S3 = RREADY ;	
       RREADY_S4 = 1'b0   ;	
       RREADY_S5 = 1'b0   ;		   
	end	
	ReadData_M0S4:begin
	   RREADY_S0 = 1'b0   ;
	   RREADY_S1 = 1'b0   ;	
       RREADY_S2 = 1'b0   ;	
       RREADY_S3 = 1'b0   ;	
       RREADY_S4 = RREADY ;	
       RREADY_S5 = 1'b0   ;		   
	end	
	ReadData_M1S4:begin
	   RREADY_S0 = 1'b0   ;
	   RREADY_S1 = 1'b0   ;	
       RREADY_S2 = 1'b0   ;	
       RREADY_S3 = 1'b0   ;	
       RREADY_S4 = RREADY ;	  
       RREADY_S5 = 1'b0   ;		   
	end	
	ReadData_M1S5:begin
	   RREADY_S0 = 1'b0   ;
	   RREADY_S1 = 1'b0   ;	
       RREADY_S2 = 1'b0   ;	
       RREADY_S3 = 1'b0   ;	
       RREADY_S4 = 1'b0   ;	  
       RREADY_S5 = RREADY ;		   
	end		
	default:begin
	   RREADY_S0 = 1'b0   ;
	   RREADY_S1 = 1'b0   ;	
       RREADY_S2 = 1'b0   ;	
       RREADY_S3 = 1'b0   ;	
       RREADY_S4 = 1'b0   ;	
       RREADY_S5 = 1'b0   ;		   
	end
  endcase  
end


endmodule 
