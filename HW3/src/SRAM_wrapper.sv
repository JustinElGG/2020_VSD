`include "AXI_define.svh"
`define IDLE      3'b000
`define WriteAddr 3'b001
`define WriteData 3'b010
`define WriteResp 3'b011
`define ReadAddr  3'b100
`define ReadData  3'b101
`define Buffer    3'b110


module SRAM_wrapper (

  input ACLK,
  input ARESETn,
  

///////////////////////
	//WRITE ADDRESS
	input [`AXI_IDS_BITS-1:0] AWID,      
	input [`AXI_ADDR_BITS-1:0] AWADDR,  
	input [`AXI_LEN_BITS-1:0] AWLEN,    
	input [`AXI_SIZE_BITS-1:0] AWSIZE,  
	input [1:0] AWBURST,
	input AWVALID,
	output logic AWREADY,
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA,
	input [`AXI_STRB_BITS-1:0] WSTRB,
	input WLAST,
	input WVALID,
	output logic WREADY,
	//WRITE RESPONSE
	output logic [`AXI_IDS_BITS-1:0] BID,  
	output logic [1:0] BRESP,
	output logic BVALID,
	input BREADY, 
	//READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	output logic ARREADY,
	//READ DATA
	output logic[`AXI_IDS_BITS-1:0] RID,
	output logic[`AXI_DATA_BITS-1:0] RDATA,
	output logic[1:0] RRESP,
	output logic RLAST,
	output logic RVALID,
	input RREADY

);

  logic OE,chipsel;
  logic [3:0] WEB;
  logic [13:0] A;
  logic [31:0] DI;
  logic  [31:0] DO;

logic chipsel_R, chipsel_W;
logic [`AXI_IDS_BITS-1:0] AWID_buf, ARID_buf;
logic [`AXI_ADDR_BITS-1:0] AWADDR_buf;
logic [`AXI_STRB_BITS-1:0] WSTRB_buf;
logic [2:0] CS, NS;



always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn)
    begin
	CS <= `IDLE;
    end
  else
    begin
	CS <= NS;	
    end	
end

always_comb
begin
  case(CS)
    `IDLE : begin 
	if(ARVALID)
	  NS = `ReadAddr;
	else if(AWVALID)
	  NS = `WriteAddr;
	else
	  NS = `IDLE;       
     end
   `WriteAddr: begin
	if(AWVALID == 1'b1 && AWREADY == 1'b1)
	  NS = `WriteData;
	else
	  NS = `WriteAddr;
    end
   `WriteData: begin
	if(WVALID == 1'b1 && WREADY == 1'b1)
	  NS = `WriteResp;
	else
	  NS = `WriteData;
    end
   `WriteResp: begin
	if(BVALID == 1'b1 && BREADY == 1'b1)
	  NS = `Buffer;
	else
	  NS = `WriteResp;
   end
    `ReadAddr: begin
	if(ARVALID && ARREADY)
	  NS = `ReadData;
	else
	  NS = `ReadAddr;		
     end
    `ReadData:begin
	if(RVALID == 1'b1 && RREADY == 1'b1)
	  NS = `IDLE;
	else
	  NS = `ReadData;
    end

   `Buffer: NS = `IDLE;

   default : NS = `IDLE;
  endcase	
end


always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn)
  begin
	AWADDR_buf <= 32'd0;
	WSTRB_buf <= 4'b1111;
	AWID_buf <= 8'd0;		
  end
  else
  begin
    if(NS == `WriteAddr)
    begin
	AWADDR_buf <= AWADDR;
	WSTRB_buf <= WSTRB;
	AWID_buf <= AWID;			
    end
	
    else if(NS == `IDLE)
    begin
	AWADDR_buf <= 32'd0;
	WSTRB_buf <= 4'b1111;
	AWID_buf <= 8'd0;		
    end
  end
end
/*
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn)
  begin
	WSTRB_buf <= 4'b1111;	
  end
  else
  begin
    if(NS == `WriteData)
    begin
	WSTRB_buf <= WSTRB;		
    end
  end
end
*/

always_comb
begin
  if(CS == `WriteAddr)
    AWREADY = 1'b1;
  else
    AWREADY = 1'b0;
end

//assign WEB = WSTRB ;

always_comb
begin
  if(CS == `WriteData)
  begin
	WEB = WSTRB;
	DI = WDATA;
	chipsel_W = 1'b1;
	WREADY = 1'b1;	
  end
  else
  begin
	WEB = 4'b1111;
	DI = WDATA;
	chipsel_W = 1'b0;
	WREADY = 1'b0;	
  end	
end

always_comb
begin
  if(CS == `WriteResp)
    begin
	BID = AWID_buf;
	BRESP = 2'b00;
	BVALID = 1'b1;
	
    end
  else
    begin
	BID = 8'b0;
	BRESP = 2'b11;
	BVALID = 1'b0;	
    end
end

always_comb
begin
  if(CS == `ReadAddr)
    begin
	ARREADY = 1'b1;
	chipsel_R = 1'b1;	
    end
    else
    begin
	ARREADY = 1'b0;
	chipsel_R = 1'b0;
    end	
end

assign chipsel = chipsel_R | chipsel_W;

always_comb
begin
  if(CS == `ReadAddr) A = ARADDR[15:2];
  else if(CS == `WriteData) A = AWADDR_buf[15:2];
  else A = 14'd0;
end

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn)
    begin
	ARID_buf <= 8'd0;
    end
  else
  begin
    if(CS == `ReadAddr)
	ARID_buf <= ARID;
    else if(NS == `IDLE)
	ARID_buf <= 8'd0;
  end	
end

always_comb
begin
  if(CS == `ReadData)
  begin
	RVALID = 1'b1;
	OE = 1'b1;
	RRESP = 2'b00;
	RDATA = DO;
	RLAST = 1'b1;
	RID = ARID_buf;	
  end
  else
  begin
	RVALID = 1'b0;
	OE = 1'b0;
	RRESP = 2'b00;
	RDATA = 32'd0;
	RLAST = 1'b0;
	RID = 8'd0;
  end	
  end


  SRAM i_SRAM (
    .A0   (A[0]  ),
    .A1   (A[1]  ),
    .A2   (A[2]  ),
    .A3   (A[3]  ),
    .A4   (A[4]  ),
    .A5   (A[5]  ),
    .A6   (A[6]  ),
    .A7   (A[7]  ),
    .A8   (A[8]  ),
    .A9   (A[9]  ),
    .A10  (A[10] ),
    .A11  (A[11] ),
    .A12  (A[12] ),
    .A13  (A[13] ),
    .DO0  (DO[0] ),
    .DO1  (DO[1] ),
    .DO2  (DO[2] ),
    .DO3  (DO[3] ),
    .DO4  (DO[4] ),
    .DO5  (DO[5] ),
    .DO6  (DO[6] ),
    .DO7  (DO[7] ),
    .DO8  (DO[8] ),
    .DO9  (DO[9] ),
    .DO10 (DO[10]),
    .DO11 (DO[11]),
    .DO12 (DO[12]),
    .DO13 (DO[13]),
    .DO14 (DO[14]),
    .DO15 (DO[15]),
    .DO16 (DO[16]),
    .DO17 (DO[17]),
    .DO18 (DO[18]),
    .DO19 (DO[19]),
    .DO20 (DO[20]),
    .DO21 (DO[21]),
    .DO22 (DO[22]),
    .DO23 (DO[23]),
    .DO24 (DO[24]),
    .DO25 (DO[25]),
    .DO26 (DO[26]),
    .DO27 (DO[27]),
    .DO28 (DO[28]),
    .DO29 (DO[29]),
    .DO30 (DO[30]),
    .DO31 (DO[31]),
    .DI0  (DI[0] ),
    .DI1  (DI[1] ),
    .DI2  (DI[2] ),
    .DI3  (DI[3] ),
    .DI4  (DI[4] ),
    .DI5  (DI[5] ),
    .DI6  (DI[6] ),
    .DI7  (DI[7] ),
    .DI8  (DI[8] ),
    .DI9  (DI[9] ),
    .DI10 (DI[10]),
    .DI11 (DI[11]),
    .DI12 (DI[12]),
    .DI13 (DI[13]),
    .DI14 (DI[14]),
    .DI15 (DI[15]),
    .DI16 (DI[16]),
    .DI17 (DI[17]),
    .DI18 (DI[18]),
    .DI19 (DI[19]),
    .DI20 (DI[20]),
    .DI21 (DI[21]),
    .DI22 (DI[22]),
    .DI23 (DI[23]),
    .DI24 (DI[24]),
    .DI25 (DI[25]),
    .DI26 (DI[26]),
    .DI27 (DI[27]),
    .DI28 (DI[28]),
    .DI29 (DI[29]),
    .DI30 (DI[30]),
    .DI31 (DI[31]),
    .CK   (ACLK   ),
    .WEB0 (WEB[0]),
    .WEB1 (WEB[1]),
    .WEB2 (WEB[2]),
    .WEB3 (WEB[3]),
    .OE   (OE    ),
    .CS   (chipsel    )
  );
  
  
  

endmodule
