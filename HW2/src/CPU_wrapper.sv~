`include "AXI_define.svh"
`include "CPU.sv"
`define IDLE      3'b000
`define WriteAddr 3'b001
`define WriteData 3'b010
`define WriteResp 3'b011
`define ReadAddr  3'b100
`define ReadData  3'b101
`define Buffer    3'b110



module CPU_wrapper(
///////////////////CPU///////////////////////////
/*
output logic IM_CS,IM_OE,DM_CS,DM_OE,
output logic [3:0]IM_WEB,DM_WEB,
output logic [31:0]IM_addr,DM_addr,
output logic [31:0]DM_Data_in,
*/
input ACLK,
input ARESETn,
//input [31:0]IM_Data_out,DM_Data_out,
//////////////////M0////////////////////////////
///output logic [`AXI_IDS_BITS-1:0] AWID_M0,
///output logic [`AXI_ADDR_BITS-1:0] AWADDR_M0,
///output logic [`AXI_LEN_BITS-1:0] AWLEN_M0,
///output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M0,
///output logic [1:0] AWBURST_M0,
///output logic AWVALID_M0,
///input AWREADY_M0,
////WRITE DATA
//output logic [`AXI_DATA_BITS-1:0] WDATA_M0,
//output logic [`AXI_STRB_BITS-1:0] WSTRB_M0,
//output logic WLAST_M0,
//output logic WVALID_M0,
//input WREADY_M0,
// //WRITE RESPONSE
//input [`AXI_IDS_BITS-1:0] BID_M0,
//input [1:0] BRESP_M0,
//input BVALID_M0,
//output logic BREADY_M0,
//READ ADDRESS
output logic [`AXI_ID_BITS-1:0]  ARID_M0   ,
output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0 ,
output logic [`AXI_LEN_BITS-1:0]  ARLEN_M0  ,
output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0 ,
output logic [1:0]                ARBURST_M0,
output logic                      ARVALID_M0,
input                             ARREADY_M0,
//READ DATA
input [`AXI_ID_BITS-1:0]  RID_M0   ,
input [`AXI_DATA_BITS-1:0] RDATA_M0 ,
input [1:0]                RRESP_M0 ,
input                      RLAST_M0 ,
input                      RVALID_M0,
output logic               RREADY_M0,
//////////////////M1////////////////////////////
output logic [`AXI_ID_BITS-1:0]  AWID_M1   ,
output logic [`AXI_ADDR_BITS-1:0] AWADDR_M1 ,
output logic [`AXI_LEN_BITS-1:0]  AWLEN_M1  ,
output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1 ,
output logic [1:0]                AWBURST_M1,
output logic                      AWVALID_M1,
input                             AWREADY_M1,
//WRITE DATA
output logic [`AXI_DATA_BITS-1:0] WDATA_M1 ,
output logic [`AXI_STRB_BITS-1:0] WSTRB_M1 ,
output logic                      WLAST_M1 ,
output logic                      WVALID_M1,
input                             WREADY_M1,
 //WRITE RESPONSE
input [`AXI_ID_BITS-1:0] BID_M1   ,
input [1:0]               BRESP_M1 ,
input                     BVALID_M1,
output logic              BREADY_M1,
//READ ADDRESS
output logic [`AXI_ID_BITS-1:0]  ARID_M1   ,
output logic [`AXI_ADDR_BITS-1:0] ARADDR_M1 ,
output logic [`AXI_LEN_BITS-1:0]  ARLEN_M1  ,
output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1 ,
output logic [1:0]                ARBURST_M1,
output logic                      ARVALID_M1,
input                             ARREADY_M1,
//READ DATA
input [`AXI_ID_BITS-1:0]  RID_M1   ,
input [`AXI_DATA_BITS-1:0] RDATA_M1 ,
input [1:0]                RRESP_M1 ,
input                      RLAST_M1 ,
input                      RVALID_M1,
output logic               RREADY_M1
);

logic [31:0]DM_Data_out,IM_Data_out;
logic IM_Read,DM_Read,DM_Write;
logic [2:0] CS_M0,CS_M1,NS_M0,NS_M1;
logic CPU_Ready;

logic IM_CS,IM_OE,DM_CS,DM_OE;
logic [3:0]IM_WEB,DM_WEB;
logic [31:0]IM_addr,DM_addr;
logic [31:0]DM_Data_in;

CPU CPU1 (
//IM
.IM_CS(IM_CS),
.IM_OE(IM_OE),
.IM_WEB(IM_WEB),
.IM_addr(IM_addr),
.IM_Data_out(IM_Data_out),
//DM
.DM_CS(DM_CS),
.DM_OE(DM_OE),
.DM_WEB(DM_WEB),
.DM_addr(DM_addr),
.DM_Data_in(DM_Data_in),
.DM_Data_out(DM_Data_out),
.CPU_Ready(CPU_Ready),
.CS_M0(CS_M0),
.CS_M1(CS_M1),
.NS_M0(NS_M0),
.NS_M1(NS_M1),
//
.clk(ACLK),
.rst(~ARESETn)
);


assign IM_Read = (IM_CS && IM_OE) ;
assign DM_Read = DM_CS && DM_OE ;
assign DM_Write= DM_CS && (DM_WEB!=4'b1111) ;

//-------FSM_M0-------//
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) CS_M0 <= 3'd0;
  else CS_M0 <= NS_M0 ;
end

always_comb
begin
  case(CS_M0)
    `IDLE :begin
	   if(IM_Read /*&& CS_M1==`IDLE*/) NS_M0 = `ReadAddr;   //IM_Read  or ARVALID ?
	   else NS_M0 = `IDLE;
	end
    `WriteAddr :begin
      NS_M0 = `IDLE;	   
	end	
    `WriteData :begin
	  NS_M0 = `IDLE;
	end
    `WriteResp :begin
	  NS_M0 = `IDLE;
	end	
    `ReadAddr :begin
	  if(ARVALID_M0 && ARREADY_M0) NS_M0 = `ReadData;
	  else NS_M0 = `ReadAddr;
	end
    `ReadData :begin
	  if(RVALID_M0 && RREADY_M0) NS_M0 = `Buffer;
	  else NS_M0 = `ReadData;
	end	
    `Buffer	: NS_M0 = `IDLE;
	default : begin
	  NS_M0 = `IDLE;
	end
  endcase
end

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) ARADDR_M0 <= 32'd0    ; 
  else if(ARVALID_M0)begin
     ARADDR_M0 <= ARADDR_M0   ;
  end
  else ARADDR_M0 <=IM_addr;
end


assign ARID_M0    = (ARVALID_M0)? 4'd1 : 4'd0 ;  
assign ARLEN_M0   = 4'd0 ;  
assign ARSIZE_M0  = (ARVALID_M0)? 3'd2 : 3'd0 ;  
assign ARBURST_M0 = (ARVALID_M0)? 2'd1 : 2'd0 ;  


//assign ARADDR_M0 = (ARVALID_M0)? IM_addr : 32'd0;
/*
always_comb
begin
  if(CS_M0==`ReadAddr) begin
    ARADDR_M0 = IM_addr   ;	
  end
  else begin
    ARADDR_M0 = 32'd0    ; 
  end
end
*/

logic [31:0]RDATA_M0_buf;
always_comb
begin
  //if(CS_M0==`ReadData) begin
    IM_Data_out = RDATA_M0_buf   ; 
 /* end
  else begin
    IM_Data_out =  IM_Data_out    ; 
  end*/
end


always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) RDATA_M0_buf <= 32'd0;
  else begin
	  if(RVALID_M0 && RREADY_M0) RDATA_M0_buf <= RDATA_M0;
	  else RDATA_M0_buf <= RDATA_M0_buf ;
  end
end





//-------FSM_M1-------//
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) CS_M1 <= 3'b0;
  else CS_M1 <= NS_M1 ;
end

always_comb
begin
  case(CS_M1)
    `IDLE :begin
	   if(DM_Read) NS_M1 = `ReadAddr;   //DM_Read  or ARVALID ?
	   else if (DM_Write) NS_M1 = `WriteAddr;
	   else NS_M1 = `IDLE;
	end
    `WriteAddr :begin
	   if(AWVALID_M1 && AWREADY_M1) NS_M1 = `WriteData; 
	   else NS_M1 = `WriteAddr;
	end	
    `WriteData :begin
      if(WVALID_M1 && WREADY_M1) NS_M1 = `WriteResp;
	  else NS_M1 = `WriteData;
	end
    `WriteResp :begin
      if(BVALID_M1 && BREADY_M1) NS_M1 = `IDLE;
	  else NS_M1 = `WriteResp;
	end	
    `ReadAddr :begin
	  if(ARVALID_M1 && ARREADY_M1) NS_M1 = `ReadData;
	  else NS_M1 = `ReadAddr;
	end
    `ReadData :begin
	  if(RVALID_M1 && RREADY_M1) NS_M1 = `IDLE;
	  else NS_M1 = `ReadData;
	end		
	//`Buffer	: NS_M1 = `IDLE;
	default : begin
	  NS_M1 = `IDLE;
	end
  endcase
end


always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) ARADDR_M1 <= 32'd0    ; 
  else if(ARVALID_M1)begin
     ARADDR_M1 <= ARADDR_M1   ;
  end
  else ARADDR_M1 <=DM_addr;
end

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) AWADDR_M1 <= 32'd0    ; 
  else if(AWVALID_M1)begin
     AWADDR_M1 <= AWADDR_M1   ;
  end
  else AWADDR_M1 <=DM_addr;
end

assign ARID_M1    = (ARVALID_M1)? 4'd1 : 4'd0 ;  
assign ARLEN_M1   = 4'd0 ;  
assign ARSIZE_M1  = (ARVALID_M1)? 3'd2 : 3'd0 ;  
assign ARBURST_M1 = (ARVALID_M1)? 2'd1 : 2'd0 ;  

assign AWID_M1    = (AWVALID_M1)? 4'd1 : 4'd0 ;  
assign AWLEN_M1   = 4'd0 ;  
assign AWSIZE_M1  = (AWVALID_M1)? 3'd2 : 3'd0 ;  
assign AWBURST_M1 = (AWVALID_M1)? 2'd1 : 2'd0 ;  

//assign WSTRB_M1 = (WVALID_M1)? DM_WEB : 4'd0 ;


always_comb
begin
  if(CS_M1==`WriteData) 
    begin
      WVALID_M1 = 1'b1;
      WDATA_M1  = DM_Data_in ;
      WSTRB_M1  = DM_WEB ;
      WLAST_M1  = 1'b1 ;		
	end
  else begin
    WVALID_M1 = 1'b0;
    WDATA_M1  = 32'd0; 
    WSTRB_M1  = 4'b1111 ;
    WLAST_M1  = 1'b0 ;	
  end
end


/*

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn)  begin
    WDATA_M1 <= 32'd0    ; 
    WSTRB_M1 <= 4'd0 ;
    WLAST_M1    <= 0;
  end
  else if(WVALID_M1)begin
    WDATA_M1 <= WDATA_M1;
    WSTRB_M1 <= WSTRB_M1;
    if(WREADY_M1)
      WLAST_M1    <= 1;
    else
      WLAST_M1    <= WLAST_M1;
  end
  else begin
    WDATA_M1 <= DM_Data_in ;
    WSTRB_M1 <= DM_WEB ;
    WLAST_M1    <= 0;
  end
end
*/


logic [31:0]RDATA_M1_buf;
always_comb
begin
  //if(CS_M0==`ReadData) begin
    DM_Data_out = RDATA_M1_buf   ; 
 /* end
  else begin
    IM_Data_out =  0         ; 
  end*/
end


always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) RDATA_M1_buf <= 0;
  else begin
	  if(RVALID_M1 && RREADY_M1) RDATA_M1_buf <= RDATA_M1;
	  else RDATA_M1_buf <= RDATA_M1_buf ;
  end
end


//--------------M0------------------//
//read ARVALID_M0

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) ARVALID_M0 <= 1'b0;
  else if (ARREADY_M0 && ARVALID_M0) ARVALID_M0 <= 1'b0;
  else if (IM_Read && (CS_M0==`IDLE)) ARVALID_M0 <= 1'b1;
  
end

//read RREADY_M0
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) RREADY_M0 <= 1'b0;
  else if (RREADY_M0) RREADY_M0 <= 1'b0;  
  else if (RVALID_M0 && ~RREADY_M0) RREADY_M0 <= 1'b1;
  
end

//--------------M1-----------------//


//write AWVALID_M1 
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) AWVALID_M1 <= 1'b0;

  else if (AWREADY_M1 && AWVALID_M1) AWVALID_M1 <= 1'b0;
  else if (DM_Write && (CS_M1==`IDLE) && (!DM_Read)) AWVALID_M1 <= 1'b1;
  
end

//write WVALID_M1
/*
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) WVALID_M1 <= 1'b0;
  else if (CS_M1==`WriteData) WVALID_M1 <= 1'b1;             //----may too early
  else if (WREADY_M1 && WVALID_M1) WVALID_M1 <=1'b0; 
end
*/




//read ARVALID_M1
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) ARVALID_M1 <= 1'b0;
  else begin
      if (ARREADY_M1 && ARVALID_M1) ARVALID_M1 <= 1'b0;
      else if (DM_Read && (CS_M1==`IDLE)) ARVALID_M1 <= 1'b1; 
  end
end



//read RREADY_M1
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) RREADY_M1 <= 1'b0;
  else if (RREADY_M1) RREADY_M1 <= 1'b0;
  else if (RVALID_M1 && ~RREADY_M1) RREADY_M1 <= 1'b1;
 

end

//write BREADY_M1
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) BREADY_M1 <= 1'b0;
  else if (BVALID_M1 && ~BREADY_M1) BREADY_M1 <= 1'b1;
  else if (BREADY_M1) BREADY_M1 <= 1'b0; 
end

always_comb
begin
 if((CS_M0==`IDLE) && (CS_M1==`IDLE) || (CS_M0==`IDLE) && (CS_M1==`WriteResp))
   CPU_Ready = 1'b1 ;
 else 
   CPU_Ready = 1'b0 ;
end


endmodule

//----------------------------------------


