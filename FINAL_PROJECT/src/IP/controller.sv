`define	RESET		3'd0
`define	IDLE		3'd1
`define	A_DATA		3'd2
`define	A_FFT		3'd3
`define	A_DIV		3'd4
`define B_DATA		3'd5
`define B_FFT		3'd6
`define B_IFFT		3'd7

module controller(
	input clk,
	input rst,
	input [1:0] inst,
	input [9:0] fft_addr_out,
	input [9:0] div_addr_out,
	input [9:0] ifft_addr_out,
	input mul_enable,
	output logic sr0_addr_sel,
	output logic [9:0] sr0_addr,
	output logic sr0_oe,
	output logic fft_data_sel,
	output logic fft_en,
	output logic ifft_en,
	output logic sr1_addr_sel
);

	logic [2:0] cstate;
	logic [2:0] nstate;
	logic [9:0] addr_reg;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			cstate <= `RESET;
			addr_reg <= 10'd0;
		end
		else begin
			cstate <= nstate;
			if(cstate == `A_DATA || cstate == `B_DATA) addr_reg <= addr_reg + 10'd1;
			else addr_reg <= 10'd0;
		end
	end

	always_comb begin
		case(cstate)
			`RESET:begin
				sr0_addr_sel	= 1'd0;
				sr0_addr		= 10'd0;
				sr0_oe			= 1'd0;
				fft_data_sel	= 1'd0;
				fft_en			= 1'd0;
				ifft_en			= 1'd0;
				sr1_addr_sel	= 1'd0;
				nstate			= `IDLE;
			end
			`IDLE:begin
				sr0_addr_sel	= 1'd0;
				sr0_addr		= 10'd0;
				sr0_oe			= 1'd0;
				fft_data_sel	= 1'd0;
				fft_en			= 1'd0;
				ifft_en			= 1'd0;
				sr1_addr_sel	= 1'd0;
				if(inst == 2'b01)
					nstate		= `A_DATA;
				else if(inst == 2'b10)
					nstate		= `B_DATA;
				else
					nstate		= `IDLE;
			end
			`A_DATA:begin
				sr0_addr_sel	= 1'd1;
				sr0_addr		= addr_reg;
				sr0_oe			= 1'd1;
				fft_data_sel	= 1'd0;
				fft_en			= 1'd1;
				ifft_en			= 1'd0;
				sr1_addr_sel	= 1'd0;
				if(addr_reg == 10'd1023)
					nstate		= `A_FFT;
				else
					nstate 		= `A_DATA;
			end
			`A_FFT:begin
				sr0_addr_sel	= 1'd0;
				sr0_addr		= 10'd0;
				sr0_oe			= 1'd0;
				fft_data_sel	= 1'd0;
				fft_en			= 1'd1;
				ifft_en			= 1'd0;
				sr1_addr_sel	= 1'd0;
				if(fft_addr_out == 10'd1023)
					nstate 		= `A_DIV;
				else
					nstate		= `A_FFT;
			end
			`A_DIV:begin
				sr0_addr_sel	= 1'd0;
				sr0_addr		= 10'd0;
				sr0_oe			= 1'd0;
				fft_data_sel	= 1'd0;
				fft_en			= 1'd0;
				ifft_en			= 1'd0;
				sr1_addr_sel	= 1'd0;
				if(div_addr_out == 10'd1023)
					nstate 		= `IDLE;
				else
					nstate		= `A_DIV;
			end
			`B_DATA:begin
				sr0_addr_sel	= 1'd1;
				sr0_addr		= addr_reg;
				sr0_oe			= 1'd1;
				fft_data_sel	= 1'd1;
				fft_en			= 1'd1;
				ifft_en			= 1'd0;
				sr1_addr_sel	= 1'd0;
				if(addr_reg == 10'd1023)
					nstate		= `B_FFT;
				else
					nstate 		= `B_DATA;
			end
			`B_FFT:begin
				sr0_addr_sel	= 1'd0;
				sr0_addr		= 10'd0;
				sr0_oe			= 1'd0;
				fft_data_sel	= 1'd1;
				fft_en			= 1'd1;
				ifft_en			= 1'd0;
				sr1_addr_sel	= 1'd0;
				if(fft_addr_out == 10'd1023)
					nstate 		= `B_IFFT;
				else
					nstate		= `B_FFT;
			end
			`B_IFFT:begin
				sr0_addr_sel	= 1'd0;
				sr0_addr		= 10'd0;
				sr0_oe			= 1'd0;
				fft_data_sel	= 1'd1;
				fft_en			= 1'd0;
				ifft_en			= 1'd1;
				sr1_addr_sel	= 1'd1;
				if(ifft_addr_out == 10'd1023)
					nstate 		= `IDLE;
				else
					nstate		= `B_IFFT;
			end
			/*
			default:begin
				sr0_addr_sel	= 1'd0;
				sr0_addr		= 10'd0;
				sr0_oe			= 1'd0;
				fft_data_sel	= 1'd0;
				fft_en			= 1'd0;
				ifft_en			= 1'd0;
				sr1_addr_sel	= 1'd0;
				nstate			= `IDLE;
			end
			*/
		endcase
	end


endmodule
