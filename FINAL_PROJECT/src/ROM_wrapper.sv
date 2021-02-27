`include "AXI_define.svh"
`define IDLE      3'd0
`define WriteAddr 3'd1
`define WriteData 3'd2
`define WriteResp 3'd3
`define ReadAddr  3'd4
`define ReadData  3'd5
`define Buffer    3'd6


module ROM_wrapper (
	
	input ACLK,
	input ARESETn,
	
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
	//ROM output
	input [31:0]ROM_out,
	//ROM input
	output logic ROM_CS,
	output logic ROM_OE,
	output logic [11:0] ROM_A
);

logic [`AXI_IDS_BITS-1:0] ARID_buf;
logic [2:0] CS, NS;

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
				NS = `ReadAddr;
			else
				NS = `IDLE;       
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
		default : NS = `IDLE;
	endcase	
end

//--------------------assign signals----------------------//

//---dummy port---

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

always_comb begin
	if(CS == `ReadAddr) begin
		ARREADY = 1'b1;
		ROM_CS = 1'b1;
		ROM_A = ARADDR[13:2];
	end
	else begin
		ARREADY = 1'b0;
		ROM_CS = 1'b0;
		ROM_A = 12'd0;		
	end	
end



always_comb begin
	if(CS == `ReadData) begin
		RVALID = 1'b1;
		RRESP = 2'b00;
		//RDATA = ROM_DO;
		RDATA = ROM_out;
		RLAST = 1'b1;
		RID = ARID_buf;
		ROM_OE = 1'b1;
	end
	else begin
		RVALID = 1'b0;
		RRESP = 2'b00;
		RDATA = 32'd0;
		RLAST = 1'b0;
		RID = 8'd0;
		ROM_OE = 1'b0;
	end
end






endmodule