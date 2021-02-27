`include "AXI_define.svh"
`define IDLE 			 4'd0
`define PRE 			 4'd1
`define PRE_delay 		 4'd2
`define RowAddr 		 4'd3
`define RowAddr_delay 	 4'd4
`define ColAddr 		 4'd5
`define ReadData_delay 	 4'd6
`define ReadData 		 4'd7
`define WriteData 		 4'd8
`define WriteData_delay  4'd9
`define WriteResp 		 4'd10


module DRAM_wrapper (

	input logic clk,
	input logic rst,

	//SLAVE INTERFACE FOR MASTERS
	//WRITE ADDRESS
	input logic [`AXI_IDS_BITS-1:0] AWID,    
	input logic [`AXI_ADDR_BITS-1:0] AWADDR,
	input logic [`AXI_LEN_BITS-1:0] AWLEN,
	input logic [`AXI_SIZE_BITS-1:0] AWSIZE,
	input logic [1:0] AWBURST,
	input logic AWVALID,
	output logic AWREADY,
	//WRITE DATA0
	input logic [`AXI_DATA_BITS-1:0] WDATA,
	input logic [`AXI_STRB_BITS-1:0] WSTRB,
	input logic WLAST,
	input logic WVALID,
	output logic WREADY,
	//WRITE RESPONSE0
	output logic [`AXI_IDS_BITS-1:0] BID,
	output logic [1:0] BRESP,
	output logic BVALID,
	input logic BREADY,
	
	//READ ADDRESS0
	input logic [`AXI_IDS_BITS-1:0] ARID,
	input logic [`AXI_ADDR_BITS-1:0] ARADDR,
	input logic [`AXI_LEN_BITS-1:0] ARLEN,
	input logic [`AXI_SIZE_BITS-1:0] ARSIZE,
	input logic [1:0] ARBURST,
	input logic ARVALID,
	output logic ARREADY,
	//READ DATA0
	output logic [`AXI_IDS_BITS-1:0] RID,
	output logic [`AXI_DATA_BITS-1:0] RDATA,
	output logic [1:0] RRESP,
	output logic RLAST,
	output logic RVALID,
	input logic RREADY,
	
	output logic DRAM_CSn,
	output logic [10:0] DRAM_A,
	output logic [3:0] DRAM_WEn,
	output logic DRAM_RASn,
	output logic DRAM_CASn,
	output logic [31:0] DRAM_D, 
	input logic [31:0] DRAM_Q,  
	input logic DRAM_valid
	
);


parameter WAIT = 2'd0;
parameter READ = 2'd1;
parameter WRITE = 2'd2;

logic [1:0] ACT;
logic [2:0] PRE_counter, Row_counter, Col_counter;
logic [`AXI_IDS_BITS-1:0] AWID_buf, ARID_buf;
logic [31:0] A, A_buf;
logic [31:0] DRAM_Q_buf;
logic [3:0] CS, NS;
assign DRAM_CSn = 1'b0;

always_ff@(posedge clk or posedge rst)
begin
	if(rst) begin
		CS <= `IDLE;
	end
	else begin
		CS <= NS;
	end
end

always_comb
begin
	case(CS)
		`IDLE: begin
			if(ARVALID == 1'b1 || AWVALID == 1'b1) begin
				if(PRE_counter == 3'd5)
					NS = `RowAddr;
				else
					NS = `PRE;
			end
			else
				NS = `IDLE;
		end
		`PRE: begin
			NS = `PRE_delay;
		end
		`PRE_delay: begin
			if(PRE_counter == 3'd5)
				NS = `RowAddr;
			else
				NS = `PRE_delay;
		end
		`RowAddr: begin
			NS = `RowAddr_delay;			
		end
		`RowAddr_delay: begin
			if(Row_counter == 3'd5)
				NS = `ColAddr;
			else
				NS = `RowAddr_delay;
		end
		`ColAddr: begin
			if(ACT == READ)
				NS = `ReadData_delay;
			else if(ACT == WRITE)
				NS = `WriteData_delay;
			else NS = `ColAddr;
		end
		`ReadData_delay: begin
			if(DRAM_valid)
				NS = `ReadData;
			else
				NS = `ReadData_delay;
		end
		`ReadData: begin
			if(RVALID && RREADY)
				NS = `IDLE;
			else
				NS = `ReadData;
		end
		`WriteData_delay: begin
			if(Col_counter == 3'd4)
				NS = `WriteResp;
			else
				NS = `WriteData_delay;
		end
		`WriteResp: begin
			if(BVALID && BREADY)
				NS = `IDLE;
			else
				NS = `WriteResp;
		end
		default: begin
			NS = `IDLE;
		end
	endcase
end

always_comb
begin
	if(CS == `IDLE) begin
		if(ARVALID) begin
			ARREADY = 1'b1;
			AWREADY = 1'b0;
		end
		else if(AWVALID) begin
			ARREADY = 1'b0;
			AWREADY = 1'b1;
		end
		else begin
			ARREADY = 1'b0;
			AWREADY = 1'b0;
		end
	end
	else begin
		ARREADY = 1'b0;
		AWREADY = 1'b0;
	end
end

always_comb
begin
	case(CS)
		`PRE: begin
			DRAM_RASn = 1'b0;
			DRAM_CASn = 1'b1;
			DRAM_A = A_buf[22:12];
			DRAM_WEn = 4'h0;
			DRAM_D = 32'b0;	
			RID = 8'b0;
			RDATA = 32'b0;
			RVALID = 1'b0;
			RRESP = 2'b11;
			RLAST = 1'b0;	
			WREADY = 1'b0;	
			BID = 8'b0;
			BRESP = 2'b11;
			BVALID = 1'b0;
		end
		`PRE_delay: begin
			DRAM_RASn = 1'b1;
			DRAM_CASn = 1'b1;
			DRAM_A = A[22:12];
			DRAM_WEn = 4'hf;
			DRAM_D = 32'b0;
			RID = 8'b0;
			RDATA = 32'b0;
			RVALID = 1'b0;
			RRESP = 2'b11;
			RLAST = 1'b0;
			WREADY = 1'b0;
			BID = 8'b0;
			BRESP = 2'b11;
			BVALID = 1'b0;
		end
		`RowAddr: begin
			DRAM_RASn = 1'b0;
			DRAM_CASn = 1'b1;
			DRAM_A = A[22:12];
			DRAM_WEn = 4'hf;
			DRAM_D = 32'b0;
			RID = 8'b0;
			RDATA = 32'b0;
			RVALID = 1'b0;
			RRESP = 2'b11;
			RLAST = 1'b0;
			WREADY = 1'b0;
			BID = 8'b0;
			BRESP = 2'b11;
			BVALID = 1'b0;
		end
		`RowAddr_delay: begin
			DRAM_RASn = 1'b1;
			DRAM_CASn = 1'b1;
			DRAM_A = A[22:12];
			DRAM_WEn = 4'hf;
			DRAM_D = 32'b0;
			RID = 8'b0;
			RDATA = 32'b0;
			RVALID = 1'b0;
			RRESP = 2'b11;
			RLAST = 1'b0;
			WREADY = 1'b0;
			BID = 8'b0;
			BRESP = 2'b11;
			BVALID = 1'b0;
		end
		`ColAddr: begin
			DRAM_RASn = 1'b1;
			DRAM_CASn = 1'b0;
			DRAM_A = {1'b0, A[11:2]};
			if(ACT == WRITE)
			begin
				DRAM_WEn = WSTRB;
				DRAM_D = WDATA;
			end
			else
			begin
				DRAM_WEn = 4'hf;
				DRAM_D = 32'b0;
			end
			RID = 8'b0;
			RDATA = 32'b0;
			RVALID = 1'b0;
			RRESP = 2'b11;
			RLAST = 1'b0;
			WREADY = 1'b0;
			BID = 8'b0;
			BRESP = 2'b11;
			BVALID = 1'b0;
		end
		`ReadData_delay: begin
			DRAM_RASn = 1'b1;
			DRAM_CASn = 1'b1;
			DRAM_A = {1'b0, A[11:2]};
			DRAM_WEn = 4'hf;
			DRAM_D = 32'b0;
			RID = 8'b0;
			RDATA = 32'b0;
			RVALID = 1'b0;
			RRESP = 2'b11;
			RLAST = 1'b0;
			WREADY = 1'b0;
			BID = 8'b0;
			BRESP = 2'b11;
			BVALID = 1'b0;
		end
		`ReadData: begin
			DRAM_RASn = 1'b1;
			DRAM_CASn = 1'b1;
			DRAM_A = {1'b0, A[11:2]};
			DRAM_WEn = 4'hf;
			DRAM_D = 32'b0;
			RID = ARID_buf;
			RDATA = DRAM_Q_buf;
			RVALID = 1'b1;
			RRESP = 2'b00;
			RLAST = 1'b1;
			WREADY = 1'b0;
			BID = 8'b0;
			BRESP = 2'b11;
			BVALID = 1'b0;
		end
		`WriteData_delay: begin
			DRAM_RASn = 1'b1;
			DRAM_CASn = 1'b1;
			DRAM_A = {1'b0, A[11:2]};
			DRAM_WEn = 4'hf;
			DRAM_D = WDATA;
			RID = 8'b0;
			RDATA = 32'b0;
			RVALID = 1'b0;
			RRESP = 2'b11;
			RLAST = 1'b0;
			if(Col_counter == 3'd4)
				WREADY = 1'b1;
			else
				WREADY = 1'b0;
			BID = 8'b0;
			BRESP = 2'b11;
			BVALID = 1'b0;
		end
		`WriteResp: begin
			DRAM_RASn = 1'b1;
			DRAM_CASn = 1'b1;
			DRAM_A = 11'b0;
			DRAM_WEn = 4'hf;
			DRAM_D = 32'b0;
			RID = 8'b0;
			RDATA = 32'b0;
			RVALID = 1'b0;
			RRESP = 2'b11;
			RLAST = 1'b0;
			WREADY = 1'b0;
			BID = AWID_buf;
			BRESP = 2'b00;
			BVALID = 1'b1;
		end
		default: begin
			DRAM_RASn = 1'b1;
			DRAM_CASn = 1'b1;
			DRAM_A = 11'b0;
			DRAM_WEn = 4'hf;
			DRAM_D = 32'b0;
			RID = 8'b0;
			RDATA = 32'b0;
			RVALID = 1'b0;
			RRESP = 2'b11;
			RLAST = 1'b0;
			WREADY = 1'b0;
			BID = 8'b0;
			BRESP = 2'b11;
			BVALID = 1'b0;
		end
	endcase
end

always_ff@(posedge clk or posedge rst)
begin
	if(rst) DRAM_Q_buf <= 32'd0;
	else if(DRAM_valid) DRAM_Q_buf <= DRAM_Q;
	else if(NS == `IDLE) DRAM_Q_buf <= 32'd0;
end

always_ff@(posedge clk or posedge rst)
begin
	if(rst) begin
		ARID_buf <= 8'b0;
		AWID_buf <= 8'b0;
		A <= 32'b0;
		A_buf <= 32'b0;
	end
	else begin
		if(ARVALID) begin
			ARID_buf <= ARID;
			A <= ARADDR;
		end
		else if(AWVALID) begin
			AWID_buf <= AWID;
			A <= AWADDR;	
		end
		else if((CS == `WriteResp || CS == `ReadData) && NS == `IDLE) begin
			ARID_buf <= 8'b0;
			AWID_buf <= 8'b0;
			A_buf <= A;
		end
	end
end

always_ff@(posedge clk or posedge rst)
begin
	if(rst) ACT <= WAIT;
	else begin
		if(ARVALID) ACT <= READ;
		else if(AWVALID) ACT <= WRITE;
		else if(NS == `IDLE) ACT <= WAIT;
	end
end

always_ff@(posedge clk or posedge rst)
begin
	if(rst) PRE_counter <= 3'd5;
	else if (Row_counter == 3'd1) PRE_counter <= 3'd0;
	else if((PRE_counter > 3'd0) && (PRE_counter < 3'd5)) PRE_counter <= PRE_counter + 3'd1;
	else if ((~DRAM_CSn) && ((~DRAM_RASn)&&(DRAM_CASn)&&(DRAM_WEn == 4'h0))) PRE_counter <= 3'd1;
end

always_ff@(posedge clk or posedge rst)
begin
	if(rst) Row_counter <= 3'd0;
	else if((Row_counter > 3'd0) && (Row_counter < 3'd5)) Row_counter <= Row_counter + 3'd1;
   	else if ((~DRAM_CSn) && ((~DRAM_RASn)&&(DRAM_CASn)&&(DRAM_WEn == 4'hf)) && (PRE_counter == 3'd5)) Row_counter <= 3'd1;
end
	
always_ff@(posedge clk or posedge rst)
begin
	if(rst) Col_counter <= 3'd0;
	else if(Col_counter > 3'd3) Col_counter <= 3'd0;
	else if(Col_counter > 3'd0) Col_counter <= Col_counter + 3'd1;
	else if ((~DRAM_CSn) && ((DRAM_RASn)&&(~DRAM_CASn)) && (Row_counter == 3'd5)) Col_counter <= 3'd1;
end

endmodule
