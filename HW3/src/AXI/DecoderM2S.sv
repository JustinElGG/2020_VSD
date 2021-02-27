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

module DecoderM2S (
  
  //----AW channel-----//
  input ACLK,ARESETn,
  input [3:0]CS_R,
  input [3:0]CS_W, 
  input [3:0]NS_R,
  input [3:0]NS_W,  
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
  //----W channel-----//  
  output logic[`AXI_DATA_BITS-1:0] WDATA_S0  ,
  output logic[`AXI_STRB_BITS-1:0] WSTRB_S0  ,
  output logic                     WLAST_S0  ,
  output logic                     WVALID_S0 ,
  output logic[`AXI_DATA_BITS-1:0] WDATA_S1  ,
  output logic[`AXI_STRB_BITS-1:0] WSTRB_S1  ,
  output logic                     WLAST_S1  ,
  output logic                     WVALID_S1 ,
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

  output logic RREADY_S0   ,
  output logic BREADY_S0   ,
  output logic RREADY_S1   ,
  output logic BREADY_S1   
  
  
);

logic AWSEL_S0,AWSEL_S1,AWSEL_Default;
logic ARSEL_S0,ARSEL_S1,ARSEL_Default;

always_comb
begin
  case(AWADDR[31:16])
    16'd0:begin
	  AWSEL_Default =1'b0;
	  AWSEL_S0      =1'b1;
	  AWSEL_S1      =1'b0;
	end
	16'd1:begin
	  AWSEL_Default =1'b0;
	  AWSEL_S0      =1'b0;
	  AWSEL_S1      =1'b1;	
	end
	default:begin
	  AWSEL_Default =1'b1;
	  AWSEL_S0      =1'b0;
	  AWSEL_S1      =1'b0;	
	end
  endcase
end

always_comb
begin
  case(ARADDR[31:16])
    16'd0:begin
	  ARSEL_Default =1'b0;
	  ARSEL_S0      =1'b1;
	  ARSEL_S1      =1'b0;
	end
	16'd1:begin
	  ARSEL_Default =1'b0;
	  ARSEL_S0      =1'b0;
	  ARSEL_S1      =1'b1;	
	end
	default:begin
	  ARSEL_Default =1'b1;
	  ARSEL_S0      =1'b0;
	  ARSEL_S1      =1'b0;	
	end
  endcase
end

logic [2:0]ARsel_slave,AWsel_slave;
assign ARsel_slave={ARSEL_S0,ARSEL_S1,ARSEL_Default};
assign AWsel_slave={AWSEL_S0,AWSEL_S1,AWSEL_Default};
/*
logic [2:0]Wsel_slave;

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn)begin
    Wsel_slave<=0;
  end
  else begin
    if(WVALID) Wsel_slave<=Wsel_slave;
    else  Wsel_slave<=AWsel_slave;
  end
end
*/

//----------------AW channel DEmux------------//
always_comb
begin
  case(AWsel_slave)
    3'b100: begin
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
	end
	3'b010: begin
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
	end
  endcase  
end


//----------------W channel DEmux------------//
always_comb
begin
  case(CS_W)
    `WriteData_M1S0: begin
	  WDATA_S0   = WDATA  ;
	  WSTRB_S0   = WSTRB  ;
	  WLAST_S0   = WLAST  ;
	  WVALID_S0  = WVALID  ;
	  WDATA_S1   = 32'd0      ;
	  WSTRB_S1   = 4'hf       ;
	  WLAST_S1   = 1'd0       ;
	  WVALID_S1	 = 1'd0       ;	 	   
	end
	`WriteData_M1S1: begin
	  WDATA_S0   = 32'd0      ;
	  WSTRB_S0   = 4'hf       ;
	  WLAST_S0   = 1'd0       ;
	  WVALID_S0  = 1'd0       ;	  
	  WDATA_S1   = WDATA  ; 
	  WSTRB_S1   = WSTRB  ; 
	  WLAST_S1   = WLAST  ; 
	  WVALID_S1	 = WVALID  ; 	  
	end
    `Write_Addr_Data_M1S0: begin
	  WDATA_S0   = WDATA  ;
	  WSTRB_S0   = WSTRB  ;
	  WLAST_S0   = WLAST  ;
	  WVALID_S0  = WVALID  ;
	  WDATA_S1   = 32'd0      ;
	  WSTRB_S1   = 4'hf       ;
	  WLAST_S1   = 1'd0       ;
	  WVALID_S1	 = 1'd0       ;	 	   
	end
	`Write_Addr_Data_M1S1: begin
	  WDATA_S0   = 32'd0      ;
	  WSTRB_S0   = 4'hf       ;
	  WLAST_S0   = 1'd0       ;
	  WVALID_S0  = 1'd0       ;	  
	  WDATA_S1   = WDATA  ; 
	  WSTRB_S1   = WSTRB  ; 
	  WLAST_S1   = WLAST  ; 
	  WVALID_S1	 = WVALID  ; 	  
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
	end
  endcase  
end

//--------------AR channel DEmux------------//
always_comb
begin
  case(ARsel_slave)
    3'b100: begin
	  ARID_S0     = {4'b0000,ARID}      ;
	  ARADDR_S0   = ARADDR    ;
	  ARLEN_S0    = ARLEN     ;
	  ARSIZE_S0   = ARSIZE    ;
	  ARBURST_S0  = ARBURST   ;
	  ARVALID_S0  = ARVALID   ;
	  ARID_S1     = 8'd0          ;
	  ARADDR_S1   = 32'd0         ;
	  ARLEN_S1    = 4'd0          ;
	  ARSIZE_S1   = 3'd0          ;
	  ARBURST_S1  = 2'd0          ;
	  ARVALID_S1  = 1'd0          ;  
	end
	3'b010: begin
	  ARID_S0     = 8'd0          ;
	  ARADDR_S0   = 32'd0         ;
	  ARLEN_S0    = 4'd0          ;
	  ARSIZE_S0   = 3'd0          ;
	  ARBURST_S0  = 2'd0          ;
	  ARVALID_S0  = 1'd0          ;  
	  ARID_S1     = {4'b0000,ARID}      ;
	  ARADDR_S1   = ARADDR    ;
	  ARLEN_S1    = ARLEN     ;
	  ARSIZE_S1   = ARSIZE    ;
	  ARBURST_S1  = ARBURST   ;
	  ARVALID_S1  = ARVALID   ; 	  
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
	end
  endcase  
end





//----RREADY/BREADY----//
always_comb
begin
  case(CS_W)
    `WriteResp_S0M1: begin
	   BREADY_S0 = BREADY ;
	   BREADY_S1 = 1'b0      ;
	end
	`WriteResp_S1M1: begin
	   BREADY_S0 = 1'b0      ;
	   BREADY_S1 = BREADY ;	  
	end
	default:begin
	   BREADY_S0 = 1'b0      ;
	   BREADY_S1 = 1'b0      ;		
	end
  endcase  
end
//----RREADY/BREADY----//
always_comb
begin
  case(CS_R)
    `ReadData_M0S0: begin
	   RREADY_S0 = RREADY ;
	   RREADY_S1 = 1'b0      ;		   
	end
    `ReadData_M1S0: begin
	   RREADY_S0 = RREADY ;
	   RREADY_S1 =  1'b0      ;		   
	end	
	`ReadData_M0S1: begin
	   RREADY_S0 = 1'b0      ;
	   RREADY_S1 = RREADY ;		  
	end
	`ReadData_M1S1: begin
	   RREADY_S0 = 1'b0      ;
	   RREADY_S1 = RREADY ;		  
	end	
	default:begin
	   RREADY_S0 = 1'b0      ;
	   RREADY_S1 = 1'b0      ;			
	end
  endcase  
end


endmodule 
