`include "AXI_define.svh"
`define IDLE      3'd0
`define WriteAddr 3'd1
`define WriteData 3'd2
`define WriteResp 3'd3
`define ReadAddr  3'd4
`define ReadData  3'd5
`define Buffer    3'd6

module sctrl_wrapper(
	input ACLK,
	input ARESETn,
	
	//SENSOR
	//input sctrl_interrupt,
	input [31:0] sctrl_out,
	output logic sctrl_en,		//0 means sctrl is full, stop requesting data
	output logic sctrl_clear,	
	output logic [5:0] sctrl_addr,

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


//--------------------FSM----------------------//
logic[2:0]CS,NS;
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) begin
		CS <= `IDLE;
	end
	else begin
		CS <= NS;	
	end	
end

always_comb begin
	case(CS)
		`IDLE : begin 
			if(ARVALID)
				NS = `ReadAddr;
			else if(AWVALID)
	            NS = `WriteAddr;	
			else
				NS = `IDLE;
		end
		
		`WriteAddr: begin //<-feed in first addr(row)
			if(AWVALID == 1'b1 && AWREADY == 1'b1)
				NS = `WriteData;
			else
				NS = `WriteAddr;
		end
		`WriteData: begin //<-feed in second addr(column), and write data
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
			if(RVALID && RREADY)
				NS = `IDLE;
			else
				NS = `ReadData;
		end
		`Buffer: NS = `IDLE;
		default : NS = `IDLE;
	endcase	
end


//--------------------assign signals----------------------//
//-----addr related-----//
assign sctrl_addr = ARADDR[7:2];
logic [`AXI_IDS_BITS-1:0] ARID_buf;
logic [31:0] sctrl_out_buf;
//-----Read-----//
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) begin
		ARID_buf <= 8'd0;
	end
	else begin
		if(CS == `ReadAddr)
			ARID_buf <= ARID;
		else if(NS == `IDLE)
			ARID_buf <= 8'd0;
	end	
end

always_ff@(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) begin
		sctrl_out_buf <= 32'd0;
	end
	else begin
		if(CS == `ReadAddr)
			sctrl_out_buf <= sctrl_out;
		else
			sctrl_out_buf <= sctrl_out_buf;
	end
end

always_comb begin
	if(CS == `ReadAddr) begin
		ARREADY = 1'b1;
	end
	else begin
		ARREADY = 1'b0;
	end	
end

always_comb begin
	if(CS == `ReadData) begin
		RVALID = 1'b1;
		RRESP = 2'b00;
		RDATA = sctrl_out_buf;
		RLAST = 1'b1;
		RID = ARID_buf;
	end
	else begin
		RVALID = 1'b0;
		RRESP = 2'b00;
		RDATA = 32'd0;
		RLAST = 1'b0;
		RID = 8'd0;
	end
end


//-----Write-----//
logic [31:0] D,AWADDR_buf;

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) begin
		AWADDR_buf <= 32'd0;
	end
	else begin
		//if(NS == `WriteAddr) begin
			AWADDR_buf <= AWADDR;
		/*end
		else if(NS == `IDLE) begin
			AWADDR_buf <= 32'd0;
		end*/
	end
end

always_comb begin
	if(CS == `WriteAddr)
		AWREADY = 1'b1;
	else
		AWREADY = 1'b0;
end

always_comb begin
	if(CS == `WriteData) begin
		D = WDATA;
		WREADY = 1'b1;
	end
	else begin
		D = WDATA;
		WREADY = 1'b0;
	end
end

always_comb begin
	if(CS == `WriteResp) begin
		BVALID = 1'b1;
		BRESP  = 2'b00;
	end
	else begin
		BVALID = 1'b0;
		BRESP  = 2'b00;
	end
end

////************** SIGNAL TO SENSOR **************////
/*
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) begin
		sctrl_en    <= 1'b0;
	end
	else begin
		if((AWADDR_buf == 32'h1000_0100) && (D != 32'd0) ) 
			sctrl_en    <= 1'b1;
		else if((AWADDR_buf == 32'h1000_0100) && (D == 32'd0))
			sctrl_en	<= 1'b0;
		else 
			sctrl_en	<= sctrl_en;
	end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) begin
		sctrl_clear    <= 1'b0;
	end
	else begin
		if((AWADDR_buf == 32'h1000_0200) && (D != 32'd0) ) 
			sctrl_clear    <= 1'b1;
		else if((AWADDR_buf == 32'h1000_0200) && (D == 32'd0))
			sctrl_clear	<= 1'b0;
		else 
			sctrl_clear	<= sctrl_clear;
	end
end
*/


logic sctrl_en_next;
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) begin
		sctrl_en    <= 1'b0;
		//sctrl_clear <= 1'b0;
	end
	else begin
		sctrl_en    <= sctrl_en_next;
		//sctrl_clear <= sctrl_clear_next;
	end
end



always_comb begin
	if(AWADDR_buf == 32'h1000_0100) begin  //sctrl_en
		if(D != 32'd0) begin
			sctrl_en_next = 1'b1;
			sctrl_clear   = 1'b0;
		end
		else begin
			sctrl_en_next = sctrl_en;
			sctrl_clear   = 1'b0;
		end
	end
	else if(AWADDR_buf == 32'h1000_0200) begin  //sctrl_clear
		if(D != 32'd0) begin
			sctrl_en_next = sctrl_en;
			sctrl_clear   = 1'b1;
		end
		else begin
			sctrl_en_next = sctrl_en;
			sctrl_clear   = 1'b0;
		end
	end
	else begin
		sctrl_en_next = sctrl_en;
		sctrl_clear   = 1'b0;
	end
end


endmodule

