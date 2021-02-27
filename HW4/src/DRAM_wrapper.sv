`include "AXI_define.svh"
`define IDLE            4'd0
`define WriteAddr       4'd1
`define WriteData       4'd2
`define WriteResp       4'd3
`define Buffer          4'd4
`define ReadAddr_row    4'd5
`define ReadAddr_col    4'd6
`define ReadData_wait   4'd7
`define ReadData        4'd8


module DRAM_wrapper (

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
	input RREADY,
	//DRAM output
	input logic [31:0] DRAM_Q,
	input logic DRAM_valid,
	//DRAM input
	output logic CSn,
	output logic [3:0] WEn,
	output logic RASn,
	output logic CASn,
	output logic [10:0] A,
	output logic [31:0] D
);

logic [`AXI_IDS_BITS-1:0] AWID_buf, ARID_buf;
logic [`AXI_ADDR_BITS-1:0] AWADDR_buf;
logic [`AXI_STRB_BITS-1:0] WSTRB_buf;
logic [3:0] CS, NS;

//--------------------FSM----------------------//
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
				NS = `ReadAddr_row;
			else if(AWVALID)
				NS = `WriteAddr;
			else
				NS = `IDLE;       
		end
		`WriteAddr: begin //<-feed in first addr(row)
			if(AWVALID && AWREADY)
				NS = `WriteData;
			else
				NS = `WriteAddr;
		end
		`WriteData: begin //<-feed in second addr(column), and write data
			if(WVALID && WREADY)
				NS = `WriteResp;
			else
				NS = `WriteData;
		end
		`WriteResp: begin
			/*
			if(BVALID && BREADY)
				NS = `Buffer;
			else
				NS = `WriteResp;
			*/
			NS = `Buffer;
		end
		`ReadAddr_row: begin
			NS = `ReadAddr_col;
		end
		`ReadAddr_col : begin
		    NS = `ReadData_wait;
		end
		`ReadData_wait : begin
		    if(DRAM_valid)
				NS = `ReadData;
			else
				NS = `ReadData_wait;
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

//-----Read-----//
logic [31:0]ARADDR_buf;
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) begin
		ARADDR_buf <= 32'd0;
	end
	else begin
		if(NS == `ReadAddr_row) begin
			ARADDR_buf <= ARADDR;
		end
		else begin
			ARADDR_buf <= ARADDR_buf;
		end
	end
end

//--------------------assign signals----------------------//
assign CSn = 1'b0;
//-----addr related-----//
//row=[22:12] col=[11:2]
always_comb begin
	if(CS == `ReadAddr_row) begin
		A = ARADDR_buf[22:12]; //write first addr(row)
		WEn = 4'b1111;
		RASn = 1'b0;
		CASn = 1'b1;
	end
	else if(CS == `ReadAddr_col) begin
		A = {1'b0, ARADDR_buf[11:2]}; //write second addr(column)
		WEn = 4'b1111;
		RASn = 1'b0;
		CASn = 1'b0;
	end	
	
	else if(CS == `ReadData_wait) begin
		A = 11'd0;
		WEn = 4'b1111;
		RASn = 1'b1;
		CASn = 1'b1;
	end		
	
	else if(CS == `ReadData) begin
		A = 11'd0;
		WEn = 4'b1111;
		RASn = 1'b1;
		CASn = 1'b1;
	end		

	else if(CS == `WriteAddr) begin
		A = AWADDR[12:2]; 	 //write first  addr(row)
		WEn = WSTRB;
		RASn = 1'b0;
		CASn = 1'b1;
	end
	else if(CS == `WriteData) begin
		A = AWADDR_buf[23:13]; //write second addr(column)
		WEn = WSTRB_buf;
		RASn = 1'b0;
		CASn = 1'b0;
	end
	else begin
		A = 11'd0;
		WEn = 4'b1111;
		RASn = 1'b1;
		CASn = 1'b1;
	end
end


//-----Read-----//
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) begin
		ARID_buf <= 8'd0;
	end
	else begin
		if(CS == `ReadAddr_row)
			ARID_buf <= ARID;
		else if(NS == `IDLE)
			ARID_buf <= 8'd0;
	end	
end

always_comb begin
	//if(CS == `ReadAddr_row) begin
	if(ARVALID) begin
		ARREADY = 1'b1;
	end
	else begin
		ARREADY = 1'b0;
	end	
end

always_comb begin
	if(CS == `ReadData || DRAM_valid) begin
		RVALID = 1'b1;
		RRESP = 2'b00;
		//RDATA = ROM_DO;
		RDATA = DRAM_Q;
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
/*
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) begin

	end
	else begin
      if(CS == `ReadData && DRAM_valid)
	  
	end
end
*/

//-----Write-----//
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) begin
		AWADDR_buf <= 32'd0;
		WSTRB_buf <= 4'b1111;
		AWID_buf <= 8'd0;
	end
	else begin
		if(NS == `WriteAddr) begin
			AWADDR_buf <= AWADDR;
			WSTRB_buf <= WSTRB;
			AWID_buf <= AWID;
		end
		else if(NS == `IDLE) begin
			AWADDR_buf <= 32'd0;
			WSTRB_buf <= 4'b1111;
			AWID_buf <= 8'd0;
		end
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






endmodule