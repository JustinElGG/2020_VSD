//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "def.svh"
`define IDLE               4'd0
`define ReadMiss           4'd1
`define ReadRecieve        4'd2
`define ReadHit            4'd3
`define ReadSensor         4'd4
`define ReadSensor_Recieve 4'd5
`define ReadSensor_Pass    4'd6
`define WriteMiss          4'd7
`define WriteHit           4'd8
`define Read               4'd9
`define Write              4'd10


//`include "data_array_wrapper.sv"
//`include "tag_array_wrapper.sv"
module L1C_data(
  input clk,
  input rst,
  // Core to CPU wrapper
  input [`DATA_BITS-1:0] core_addr,
  input core_req,
  input core_write,
  input [`DATA_BITS-1:0] core_in,
  input [`CACHE_TYPE_BITS-1:0] core_type,
  // Mem to CPU wrapper
  input [`DATA_BITS-1:0] D_out,
  input D_wait,
  // CPU wrapper to core
  output logic [`DATA_BITS-1:0] core_out,
  output logic core_wait,
  // CPU wrapper to Mem
  output logic D_req,
  output logic [`DATA_BITS-1:0] D_addr,
  output logic D_write,
  output logic [`DATA_BITS-1:0] D_in,
  output logic [`CACHE_TYPE_BITS-1:0] D_type
);

logic [`CACHE_INDEX_BITS-1:0] index;
logic [`CACHE_DATA_BITS-1:0] DA_out;
logic [`CACHE_DATA_BITS-1:0] DA_in;
logic [`CACHE_WRITE_BITS-1:0] DA_write;
logic DA_read;
logic [`CACHE_TAG_BITS-1:0] TA_out;
logic [`CACHE_TAG_BITS-1:0] TA_in;
logic TA_write;
logic TA_read;
logic [`CACHE_LINES-1:0] valid;
logic [`DATA_BITS-1:0]D_out_buf;

logic [3:0] c_state, n_state;
logic hit;
logic [3:0] write_enable;
logic [`DATA_BITS-1:0] core_in_data, core_out_data;
logic [2:0] pos_counter, n_pos_counter;

logic cacheable;
always_comb cacheable = (core_addr[31:16] != 16'h1000);

//--------------- stuffs -----------------//
assign D_type = core_type;
assign index = core_addr[9:4];

//--------------- state machine -----------------//
always_ff @(posedge clk, posedge rst) begin
	if(rst) begin
		c_state <= `IDLE;
	end
	else begin
		c_state <= n_state;
	end
end

always_comb begin
	case(c_state)
		`IDLE: begin
			if(core_req && core_write) begin
				n_state = `Write;
			end
			else if(core_req && ~core_write) begin
				n_state = `Read;
			end
			else n_state = `IDLE;
		end
		`Read :begin
			if(hit) n_state = `ReadHit;
			else if(!cacheable) n_state = `ReadSensor;
			else n_state = `ReadMiss;
		end
		`ReadMiss: begin
			n_state = `ReadRecieve;
		end
		`ReadRecieve: begin
			if((~D_wait) && (n_pos_counter==3'd5)) n_state = `ReadHit;
			else n_state = `ReadRecieve;
		end
		`ReadHit: begin
			n_state = `IDLE;
		end
		//*****////////////SENSOR////////////*****//
		`ReadSensor: begin
			n_state = `ReadSensor_Recieve;
		end
		`ReadSensor_Recieve: begin
			if(!D_wait)
				n_state = `ReadSensor_Pass;
			else
				n_state = `ReadSensor_Recieve;
		end
		`ReadSensor_Pass: begin
			n_state = `IDLE;
		end
		//*****////////////SENSOR////////////*****//
		`Write: begin
			if(!core_write) n_state = `IDLE;
			else if (hit) n_state = `WriteHit;
			else n_state = `WriteMiss;
		end
		`WriteMiss: begin
			if(D_wait) n_state = `WriteMiss;
			else n_state = 4'd11;
		end
		`WriteHit: begin
			if(D_wait) n_state = `WriteHit;
			else n_state =  4'd11;
		end
		default: begin
			n_state = `IDLE;
		end
	endcase
end


//--------------- valid -----------------//
always_ff@(posedge clk , posedge rst)
begin
	if(rst)
		valid <= 64'd0;
	else if(c_state == `ReadRecieve && n_state == `ReadHit && cacheable)
		valid[index] <= 1'b1;
end

//--------------- compare -----------------//
logic [`CACHE_TAG_BITS-1:0]TAG ;
assign TAG = core_addr[31:10] ;

always_comb begin
	if(valid[index]) begin
		if(TA_out==core_addr[31:10] && cacheable)
			hit = 1'b1;
		else
			hit = 1'b0;
	end
	else begin
		hit = 1'b0;
	end
end

//--------------- core_out(read) -----------------//
logic [1:0]word_sel;
assign word_sel = core_addr[3:2] ;
always_comb begin
	case(core_addr[3:2])
		2'b00: core_out_data = DA_out[31:0];
		2'b01: core_out_data = DA_out[63:32];
		2'b10: core_out_data = DA_out[95:64];
		2'b11: core_out_data = DA_out[127:96];
	endcase
end

//--------------- core_in(write) -----------------//
logic [1:0]byte_sel;
assign byte_sel = core_addr[1:0] ;

always_comb begin
	case(D_type)
		3'b000,3'b100: begin
			case(core_addr[1:0])
				2'b00: begin
					core_in_data = {24'b0, core_in[7:0]};
					write_enable = 4'b1110;
				end
				2'b01: begin
					core_in_data = {16'b0, core_in[7:0], 8'b0};
					write_enable = 4'b1101;
				end
				2'b10: begin
					core_in_data = {8'b0, core_in[7:0], 16'b0};
					write_enable = 4'b1011;
				end
				2'b11: begin
					core_in_data = {core_in[7:0], 24'b0};
					write_enable = 4'b0111;
				end
			endcase
		end
		3'b001,3'b101: begin
			case(core_addr[1:0])
				2'b00: begin
					core_in_data = {16'b0, core_in[15:0]};
					//core_in_data = core_in;
					write_enable = 4'b1100;
				end
				2'b01: begin
					core_in_data = {core_in[15:0], 16'b0};
					//core_in_data = core_in;
					write_enable = 4'b1001;
				end				
				2'b10: begin
					core_in_data = {core_in[15:0], 16'b0};
					//core_in_data = core_in;
					write_enable = 4'b0011;
				end
				default:begin
					core_in_data = 32'd0;
					//core_in_data = core_in;
					write_enable = 4'b1111;				
				end
			endcase
		end
		3'b010: begin
			core_in_data = core_in;
			write_enable = 4'b0000;
		end
		
		default: begin
			core_in_data = 32'b0;
			write_enable = 4'b1111;
		end
	endcase
end

//--------------- outputs(including cache) -----------------//
			/*
			core_out  = 
			core_wait = 
			D_addr    = 
			D_req     = 
			D_write   = 
			D_in      = 
			DA_in     = 
			DA_write  = active low?
			DA_read   = active low?
			TA_in     = 
			TA_write  = active low?
			TA_read   =	active low?
			*/

always_ff @(posedge clk, posedge rst) begin
	if(rst) begin
		pos_counter <= 3'b0;
	end
	else begin
		pos_counter <= n_pos_counter;
	end
end

always_comb begin
	case(c_state)
		`IDLE: begin
			core_out  = `DATA_BITS'b0;
			core_wait = 1'b0;
			D_addr    = `DATA_BITS'b0;
			D_req     = 1'b0;
			D_write   = 1'b0;
			D_in      = `DATA_BITS'd0;
			DA_in     = `CACHE_DATA_BITS'd0;
			DA_write  = `CACHE_WRITE_BITS'hffff;
			DA_read   = 1'b0;
			TA_in     = `CACHE_TAG_BITS'd0;
			TA_write  = 1'b1;
			TA_read   = 1'b0;
			n_pos_counter = 3'b0;
		end
		`ReadMiss: begin //send request if miss
			core_out  = `DATA_BITS'b0;
			core_wait = 1'b1;
			D_addr    = {core_addr[31:4], 2'b00, 2'b00};//////
			D_req     = 1'b1;
			D_write   = 1'b0;
			D_in      = `DATA_BITS'd0;
			DA_in     = `CACHE_DATA_BITS'd0;
			DA_write  = `CACHE_WRITE_BITS'hffff;
			DA_read   = 1'b0;
			TA_in     = core_addr[31:10];
			TA_write  = 1'b1;
			TA_read   =	1'b0;
			n_pos_counter = 3'd0;
		end
		`ReadRecieve: begin //recieve missed data(delayed compare to request)
			core_out  = `DATA_BITS'd0;
			core_wait = 1'b1;
			D_addr    = {core_addr[31:4], pos_counter[1:0], 2'b00};//////
			D_req     = 1'b1;
			D_write   = 1'b0;
			D_in      = `DATA_BITS'd0;
			case(pos_counter)
				3'd1: begin
					DA_in = {96'b0, D_out};
					DA_write = `CACHE_WRITE_BITS'hfff0;
				end
				3'd2: begin
					DA_in = {64'b0, D_out, 32'b0};
					DA_write = `CACHE_WRITE_BITS'hff0f;
				end
				3'd3: begin
					DA_in = {32'b0, D_out, 64'b0};
					DA_write = `CACHE_WRITE_BITS'hf0ff;
				end
				3'd4: begin
					DA_in = {D_out, 96'b0};
					DA_write = `CACHE_WRITE_BITS'h0fff;
			    end
			    default: begin
					DA_in     = `CACHE_DATA_BITS'd0;
					DA_write  = `CACHE_WRITE_BITS'hffff;							
				end
			endcase
			DA_read   = 1'b0;
			TA_in     = core_addr[31:10];
			TA_write  = 1'b0;
			TA_read   =	1'b0;
			n_pos_counter = (D_wait) ? pos_counter:pos_counter+3'd1;
		end
		`ReadHit: begin
			core_out  = core_out_data;
			core_wait = 1'b1;
			D_addr    = `DATA_BITS'd0; //data already in cache, no need to request new data
			D_req     = 1'b0;
			D_write   = 1'b0;
			D_in      = `DATA_BITS'd0;
			DA_in     = `CACHE_DATA_BITS'd0;
			DA_write  = `CACHE_WRITE_BITS'hffff;
			DA_read   = 1'b1;
			TA_in     = `CACHE_TAG_BITS'd0;
			TA_write  = 1'b1;
			TA_read   = 1'b0;
			n_pos_counter = 3'b0;
		end
		////////////////////////////////////////////////////////////
		`ReadSensor: begin //request data
			core_out  = `DATA_BITS'd0;
			core_wait = 1'b1;
			D_addr    = core_addr;
			D_req     = 1'b1;
			D_write   = 1'b0;
			D_in      = `DATA_BITS'd0;
			DA_in     = `CACHE_DATA_BITS'd0;
			DA_write  = `CACHE_WRITE_BITS'hffff;
			DA_read   = 1'b1;
			TA_in     = `CACHE_TAG_BITS'd0;
			TA_write  = 1'b1;
			TA_read   = 1'b1;
			n_pos_counter = 3'b0;
		end
		`ReadSensor_Recieve: begin //recieve data
			core_out  = `DATA_BITS'd0;
			core_wait = 1'b1;
			D_addr    = `DATA_BITS'd0;
			D_req     = 1'b0;
			D_write   = 1'b0;
			D_in      = `DATA_BITS'd0;
			DA_in     = `CACHE_DATA_BITS'd0;
			DA_write  = `CACHE_WRITE_BITS'hffff;
			DA_read   = 1'b1;
			TA_in     = `CACHE_TAG_BITS'd0;
			TA_write  = 1'b1;
			TA_read   = 1'b1;
			n_pos_counter = 3'b0;
		end
		`ReadSensor_Pass: begin //send data
			core_out  = D_out;
			core_wait = 1'b1;
			D_addr    = `DATA_BITS'd0;
			D_req     = 1'b0;
			D_write   = 1'b0;
			D_in      = `DATA_BITS'd0;
			DA_in     = `CACHE_DATA_BITS'd0;
			DA_write  = `CACHE_WRITE_BITS'hffff;
			DA_read   = 1'b1;
			TA_in     = `CACHE_TAG_BITS'd0;
			TA_write  = 1'b1;
			TA_read   = 1'b1;
			n_pos_counter = 3'b0;
		end
		////////////////////////////////////////////////////////////
		`WriteMiss: begin //write data(a word) into mem only
			core_out  = `DATA_BITS'd0;
			core_wait = 1'b1;
			D_addr    = core_addr;
			D_req     = 1'b1;
			D_write   = 1'b1;
			//D_in      = core_in_data;
			D_in      = core_in;
			DA_in     = `CACHE_DATA_BITS'd0;
			DA_write  = `CACHE_WRITE_BITS'hffff;
			DA_read   = 1'b0;
			TA_in     = `CACHE_TAG_BITS'd0;
			TA_write  = 1'b1;
			TA_read   = 1'b0;
			n_pos_counter = 3'b0;
		end
		`WriteHit: begin //write data(a word) into cache and mem
			core_out  = `DATA_BITS'd0;
			core_wait = 1'b1;
			D_addr    = core_addr;
			D_req     = 1'b1;
			D_write   = 1'b1;
			//D_in      = core_in_data;
			D_in      = core_in;
			case(core_addr[3:2]) //which position in line to write
				2'b00: begin
					DA_in = {96'b0, core_in};
					DA_write = {12'hfff,write_enable};
				end
				2'b01: begin
					DA_in = {64'b0, core_in, 32'b0};
					DA_write = {8'hff,write_enable,4'hf};
				end
				2'b10: begin
					DA_in = {32'b0, core_in, 64'b0};
					DA_write = {4'hf,write_enable,8'hff};
				end
				2'b11: begin
					DA_in = {core_in, 96'b0};
					DA_write = {write_enable,12'hfff};
				end
			endcase
			DA_read   = 1'b0;
			TA_in     = core_addr[31:10];
			TA_write  = 1'b0;
			TA_read   = 1'b0;
			n_pos_counter = 3'b0;
		end
		`Read: begin
			core_out  = core_out_data;
			core_wait = 1'b1;
			D_addr    = `DATA_BITS'd0;
			D_req     = 1'b0;
			D_write   = 1'b0;
			D_in      = `DATA_BITS'd0;
			DA_in     = `CACHE_DATA_BITS'd0;
			DA_write  = `CACHE_WRITE_BITS'hffff;
			DA_read   = 1'b0;
			TA_in     = core_addr[31:10];
			TA_write  = 1'b1;
			TA_read   = 1'b1;
			n_pos_counter = 3'b0;
		end	
		`Write: begin
			core_out  = `DATA_BITS'b0;
			core_wait = 1'b1;
			D_addr    = (core_write)? core_addr: 32'd0;
			D_req     = (core_write)? 1'b1 : 1'b0;
			D_write   = (core_write)? 1'b1 : 1'b0;
			//D_in      = core_in_data;
			D_in      = core_in;
			DA_in     = `CACHE_DATA_BITS'd0;
			DA_write  = `CACHE_WRITE_BITS'hffff;
			DA_read   = 1'b0;
			TA_in     = `CACHE_TAG_BITS'd0;
			TA_write  = /*(hit)? 1'b0 : 1'b1*/ 1'b1 ;
			TA_read   = 1'b1;
			n_pos_counter = 3'b0;
		end				
		default: begin
			core_out  = `DATA_BITS'd0;
			core_wait = 1'b1;
			D_addr    = `DATA_BITS'd0;
			D_req     = 1'b0;
			D_write   = 1'b0;
			D_in      = `DATA_BITS'd0;
			DA_in     = `CACHE_DATA_BITS'd0;
			DA_write  = `CACHE_WRITE_BITS'hffff;
			DA_read   = 1'b0;
			TA_in     = `CACHE_TAG_BITS'd0;
			TA_write  = 1'b1;
			TA_read   = 1'b1;
			n_pos_counter = 3'b0;
		end
	endcase
end




data_array_wrapper DA(
	.A(index),
	.DO(DA_out),
	.DI(DA_in),
	.CK(clk),
	.WEB(DA_write),
	.OE(DA_read),
	.CS(1'b1)
);

tag_array_wrapper  TA(
	.A(index),
	.DO(TA_out),
	.DI(TA_in),
	.CK(clk),
	.WEB(TA_write),
	.OE(TA_read),
	.CS(1'b1)
);
endmodule