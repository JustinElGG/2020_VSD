module CSR(	output logic [31:0] csr_out,
			output logic [31:0] csr_pc,
			input reg_write,
			input [11:0] read_addr,
			input [11:0] write_addr,
			input [31:0] csr_in,
			input [31:0] pc,
			input clk,
			input rst,
			input interrupt_taken,
			input interrupt_return,
			input interrupt);

logic [31:0]mstatus ;
logic [31:0]mie ;
logic [31:0]mtvec;
logic [31:0]mepc;
logic [31:0]mip;
logic [31:0]mcycle;
logic [31:0]minstret;
logic [31:0]mcycleh;
logic [31:0]minstreth;
logic [31:0]pc_buf;

//***** write CSR *****//
//assign CSR value for different stage
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		mstatus   <= 32'd0;
		mie       <= 32'd0;
		mtvec     <= 32'h0001_0000;
		mepc      <= 32'd0;
		mip       <= 32'd0;
		mcycle    <= 32'd0;
		minstret  <= 32'd0;
		mcycleh   <= 32'd0;
		minstreth <= 32'd0;
		pc_buf	  <= 32'hf;
	end
	else begin
		pc_buf <= pc;
		if(interrupt_taken) begin              //MPIE          //MIE
			mstatus   <= {19'd0, 2'b11, 3'd0, mstatus[3], 3'd0, 1'd0, 3'd0};
			mie       <= {20'd0, 1'b1, 11'd0};
			mtvec     <= mtvec;
			mepc      <= 32'h00010334;
			mcycle    <= mcycle;
			minstret  <= minstret;
			mcycleh   <= mcycleh;
			minstreth <= minstreth;
		end
		else if(interrupt_return) begin
			mstatus   <= {19'd0, 2'b11, 3'd0, 1'b1, 3'd0, mstatus[7], 3'd0};
			mie       <= {20'd0, 1'b0, 11'd0};
			mtvec     <= mtvec;
			mepc      <= mepc;
			mcycle    <= mcycle;
			minstret  <= minstret;
			mcycleh   <= mcycleh;
			minstreth <= minstreth;
		end
		else if(reg_write) begin
			case(write_addr)
				12'h300:mstatus   <= {19'd0,csr_in[12:11],3'd0,csr_in[7],3'd0,csr_in[3],3'd0};
				12'h304:mie       <= {20'd0,csr_in[11],11'd0};
				12'h305:mtvec     <= mtvec;
				12'h341:mepc      <= {csr_in[31:2],2'b00};
				12'hB00:mcycle    <= csr_in;
				12'hB02:minstret  <= csr_in;
				12'hB80:mcycleh   <= csr_in;
				12'hB82:minstreth <= csr_in;
				default:mtvec     <= mtvec;
			endcase
		end
		mip <= {20'd0,interrupt,11'd0};
	
		//carry
		if(mcycle == 32'hffffffff) begin
			mcycle  <= 32'b0;
			mcycleh <= mcycleh+32'b1;
		end
		else begin
			mcycle  <= mcycle+32'b1;
			mcycleh <= mcycleh;
		end
		if(pc_buf != pc) begin
			if(minstret == 32'hffffffff) begin
				minstret  <= 32'b0;
				minstreth <= minstreth+32'b1;
			end
			else begin
				minstret  <= minstret+32'b1;
				minstreth <= minstreth;
			end
		end
		else begin
			minstret  <= minstret;
			minstreth <= minstreth;
		end
	end
end


logic interrupt_taken_buf;
always_ff @(posedge clk or posedge rst) begin
	if(rst) interrupt_taken_buf<=1'b0;
	else interrupt_taken_buf<=interrupt_taken;
end



//***** read CSR *****//

always_comb begin
	if(interrupt_taken /*&& csr_in[11]==1'b1*/) //externel interrupt enable
		//csr_pc = {mtvec[31:2], 2'b00};
		csr_pc = 32'h0001_0000;
	else if(interrupt_return)
		//csr_pc = mepc+32'd4;
		csr_pc = mepc;
	else
		csr_pc = 32'h0;

	case(read_addr)
		12'h300:csr_out = mstatus;
		12'h304:csr_out = mie;
		12'h305:csr_out = mtvec;
		12'h341:csr_out = mepc;
		12'h344:csr_out = mip;
		12'hB00:csr_out = mcycle;
		12'hB02:csr_out = minstret;
		12'hB80:csr_out = mcycleh;
		12'hB82:csr_out = minstreth;
		default:csr_out = 32'd0;
	endcase
end
endmodule
