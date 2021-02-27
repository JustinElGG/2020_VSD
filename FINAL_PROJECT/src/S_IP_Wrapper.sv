`include "IP/IP_top.sv"

module S_IP_Wrapper(
	input ACLK,
	input ARESETn,
	
	//MASTER INTERFACE FOR SLAVES
	//WRITE ADDRESS
	input [`AXI_IDS_BITS-1:0] AWID_S,
	input [`AXI_ADDR_BITS-1:0] AWADDR_S,
	input [`AXI_LEN_BITS-1:0] AWLEN_S,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_S,
	input [1:0] AWBURST_S,
	input AWVALID_S,
	output logic AWREADY_S,
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_S,
	input [`AXI_STRB_BITS-1:0] WSTRB_S,
	input WLAST_S,
	input WVALID_S,
	output logic WREADY_S,
	//WRITE RESPONSE
	output logic [`AXI_IDS_BITS-1:0] BID_S,
	output logic [1:0] BRESP_S,
	output logic BVALID_S,
	input BREADY_S,
	
	//READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID_S,
	input [`AXI_ADDR_BITS-1:0] ARADDR_S,
	input [`AXI_LEN_BITS-1:0] ARLEN_S,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_S,
	input [1:0] ARBURST_S,
	input ARVALID_S,
	output logic ARREADY_S,
	//READ DATA
	output logic [`AXI_IDS_BITS-1:0] RID_S,
	output logic [`AXI_DATA_BITS-1:0] RDATA_S,
	output logic [1:0] RRESP_S,
	output logic RLAST_S,
	output logic RVALID_S,
	input RREADY_S
);
	logic [1:0]  IP_inst;
	logic [9:0]  IP_sr0_addr_in;
	logic [31:0] IP_sr0_data_in;
	logic 		 IP_sr0_we;
	logic 		 IP_sr1_oe;
	logic 		 IP_sr1_oe_D1;
	logic [9:0]  IP_sr1_addr_in;
	logic [31:0] IP_sr1_data_out;

	logic [31:0] reg_raddr;
	logic [31:0] reg_rdata;
 	logic [31:0] reg_waddr;
	logic [31:0] reg_wdata;
	
	//READ ADDRESS CHANNEL SIGNAL DECLERATION
	logic reg_arready_s;
	logic [`AXI_IDS_BITS-1:0] reg_arid_s;
	
	assign ARREADY_S = reg_arready_s;
	
	//READ DATA CHANNEL SIGNAL DECLERATION
	logic reg_rvalid_s;
	logic [1:0] reg_rresp_s;
	logic [`AXI_IDS_BITS-1:0] reg_rid_s;
	logic reg_rlast_s;
	
	
	assign RVALID_S = reg_rvalid_s;
	assign RRESP_S = reg_rresp_s;
	assign RID_S = reg_rid_s;
	assign RLAST_S = reg_rlast_s;
	assign RDATA_S = (IP_sr1_oe_D1 == 1'b1) ? IP_sr1_data_out : reg_rdata;

	//WRITE ADDRESS CHANNEL SIGNAL DECLERATION
	logic reg_awready_s;
	logic [`AXI_IDS_BITS-1:0] reg_wbid_s;
	
	assign AWREADY_S = reg_awready_s;
	
	//WRITE DATA CHANNEL SIGNAL DECLERATION
	logic reg_wready_s;
	logic [3:0] reg_wstrb_s;
	
	assign WREADY_S = reg_wready_s;
	
	//WRITE RESPONSE CHANNEL SIGNAL DECLERATION
	logic reg_bvalid_s;
	logic [1:0] reg_bresp_s;
	logic [`AXI_IDS_BITS-1:0] reg_bid_s;
	
	assign BVALID_S = reg_bvalid_s;
	assign BRESP_S = reg_bresp_s;
	assign BID_S = reg_bid_s;
	
	//IP LOGIC	
	assign IP_inst = (reg_waddr[15:0] == 16'h4000 && IP_sr0_we) ? WDATA_S[1:0] : 2'd0;
	assign IP_sr0_addr_in = (reg_waddr[15:0] == 16'h4000) ? 10'd0 : reg_waddr[11:2];
	assign IP_sr0_data_in = (reg_waddr[15:0] == 16'h4000) ? 32'd0 : WDATA_S;
	assign IP_sr0_we = WVALID_S && reg_wready_s;
	assign IP_sr1_oe = reg_arready_s & ARVALID_S & ~reg_rvalid_s;
	assign IP_sr1_addr_in = reg_raddr[11:2];
	
	/*
		READ ADDRESS CHANNEL
	*/
	always_ff@(posedge ACLK or negedge ARESETn)begin
		if(~ARESETn)begin
			reg_arready_s <= 1'b0;
			reg_raddr <= 32'd0;
			reg_arid_s <= 8'd0;
		end
		else if(~reg_arready_s && ARVALID_S)begin
			reg_arready_s <= 1'b1;
			reg_raddr <= ARADDR_S;
			reg_arid_s <= ARID_S;
		end
		else begin
			reg_arready_s <= 1'b0;
		end
	end
	
	/*
		READ DATA CHANNEL
	*/
	always_ff@(posedge ACLK or negedge ARESETn)begin
		if(~ARESETn)begin
			reg_rvalid_s <= 1'b0;
			reg_rresp_s <= 2'b0;
			reg_rid_s <= 8'd0;
			reg_rlast_s <= 1'b0;
		end
		else if(reg_arready_s && ~reg_rvalid_s && ARVALID_S)begin
			reg_rvalid_s <= 1'b1;
			reg_rresp_s <= 2'd0;
			reg_rid_s <= reg_arid_s;
			reg_rlast_s <= 1'b1;
		end
		else if(reg_rvalid_s && RREADY_S)begin
			reg_rvalid_s <= 1'b0;
			reg_rlast_s <= 1'b0;
		end
	end
	
	
	
	always_ff@(posedge ACLK or negedge ARESETn)begin
		if(~ARESETn)begin
			IP_sr1_oe_D1 <= 1'd0;
		end
		else begin
			IP_sr1_oe_D1 <= IP_sr1_oe;
		end
	end
	
	always_ff@(posedge ACLK or negedge ARESETn)begin
		if(~ARESETn)begin
			reg_rdata <= 32'd0;
		end
		else begin
			if(IP_sr1_oe_D1) reg_rdata <= IP_sr1_data_out;
			else reg_rdata <= reg_rdata;
		end
	end
	
	/*
		WRITE ADDRESS CHANNEL
	*/
	always_ff@(posedge ACLK or negedge ARESETn)begin
		if(~ARESETn)begin
			reg_awready_s <= 1'b0;
			reg_wbid_s <= 8'd0;
		end
		else if(~reg_awready_s && AWVALID_S)begin
			reg_awready_s <= 1'b1;
			reg_wbid_s <= AWID_S;
		end
		else if(reg_awready_s && AWVALID_S)begin
			reg_awready_s <= 1'b0;
		end
	end
	
	always_ff@(posedge ACLK or negedge ARESETn)begin
		if(~ARESETn)begin
			reg_waddr <= 32'd0;
		end
		else if(AWVALID_S && ~reg_awready_s)begin
			reg_waddr <= AWADDR_S;
		end
	end
	
	/*
		WRITE DATA CHANNEL
	*/
	always_ff@(posedge ACLK or negedge ARESETn)begin
		if(~ARESETn)begin
			reg_wready_s <= 1'b0;
		end
		else begin
			if(AWVALID_S && reg_awready_s)begin
				reg_wready_s <= 1'b1;
			end
			else if(WVALID_S && reg_wready_s)begin
				reg_wready_s <= 1'b0;
			end
			else begin
				reg_wready_s <= reg_wready_s;
			end
		end
	end
	
	/*
		WRITE RESPONSE CHANNEL
	*/
	always_ff@(posedge ACLK or negedge ARESETn)begin
		if(~ARESETn)begin
			reg_bvalid_s <= 1'b0;
			reg_bresp_s <= 2'd0;
			reg_bid_s <= 8'd0;
		end
		else if(~reg_bvalid_s && WVALID_S && reg_wready_s)begin
			reg_bvalid_s <= 1'b1;
			reg_bresp_s <= 2'd0;
			reg_bid_s <= reg_wbid_s;
		end
		else if(reg_bvalid_s && BREADY_S)begin
			reg_bvalid_s <= 1'b0;
			reg_bresp_s <= 2'd0;
		end
	end

	
	IP_top ip_top_i(
		.clk			(ACLK			),
		.rst			(~ARESETn		),
		.inst			(IP_inst		),
		.sr0_addr_in	(IP_sr0_addr_in	),
		.sr0_data_in	(IP_sr0_data_in	),
		.sr0_we			(IP_sr0_we		),
		.sr1_oe			(IP_sr1_oe		),
		.sr1_addr_in	(IP_sr1_addr_in	),
		.sr1_data_out	(IP_sr1_data_out)
	);
	

	

endmodule