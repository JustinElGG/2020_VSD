`include "sign_processing_unit.sv"
`include "BF2.sv"
`include "complex_mul.sv"
`include "FFT_32.sv"
`include "re_index.sv"
`include "FFT_32_32.sv"
`include "IFFT_32_32.sv"
`include "controller.sv"
`include "divider_top.sv"
`include "complex_multiply.sv"
//`include "sram/sram_1024_rtl.sv"
`include "sram_1024_wrapper.sv"

module IP_top(
	input clk,
	input rst,
	input [1:0] inst,
	input [9:0] sr0_addr_in,
	input [31:0] sr0_data_in,
	input sr0_we,
	input sr1_oe,
	input [9:0] sr1_addr_in,
	output logic [31:0] sr1_data_out
);
	
	//controller
	logic [1:0] ctrl_inst;
	logic [9:0] ctrl_fft_addr_out;
	logic [9:0] ctrl_div_addr_out;
	logic [9:0] ctrl_ifft_addr_out;
	logic ctrl_mul_enable;
	logic ctrl_sr0_addr_sel;
	logic [9:0] ctrl_sr0_addr;
	logic ctrl_sr0_oe;
	logic ctrl_fft_data_sel;
	logic ctrl_fft_en;
	logic ctrl_ifft_en;
	logic ctrl_sr1_addr_sel;
	//sr_frame
	logic sr_frame_CS;
	logic sr_frame_OE;	
	logic sr_frame_WEB;
	logic [9:0] sr_frame_A;
	logic [31:0] sr_frame_DI;
	logic [31:0] sr_frame_DO;	
	//fft
	logic fft_enable			;
	logic [31:0] fft_real_in	;
	logic [31:0] fft_imag_in	;
	logic [31:0] fft_real_out	;
	logic [31:0] fft_imag_out	;
	logic [9:0]  fft_counter_out;
	logic fft_valid_out			;
	//div
	logic [31:0] div_F_real		;
	logic [31:0] div_F_image	;
	logic [9:0]  div_addr		;
	logic div_enable			;
	logic [31:0] div_H_real		;
	logic [31:0] div_H_image	;
	logic [9:0]  div_addr_out	;
	logic div_enable_out		;
	//H_real
	logic H_real_CS;
	logic H_real_OE;	
	logic H_real_WEB;
	logic [9:0] H_real_A;
	logic [31:0] H_real_DI;
	logic [31:0] H_real_DO;
	//H_imag
	logic H_imag_CS;
	logic H_imag_OE;	
	logic H_imag_WEB;
	logic [9:0] H_imag_A;
	logic [31:0] H_imag_DI;
	logic [31:0] H_imag_DO;
	//mul
	logic [31:0] mul_a			;
	logic [31:0] mul_b			;
	logic [31:0] mul_c			;
	logic [31:0] mul_d			;
	logic [9:0] mul_addr		;
	logic mul_enable			;
	logic [31:0] mul_real_out	;
	logic [31:0] mul_imag_out	;
	logic [9:0] mul_addr_out	;
	logic mul_enable_out		;
	//ifft
	logic ifft_enable				;
	logic [31:0] ifft_real_in		;
	logic [31:0] ifft_imag_in		;
	logic [31:0] ifft_real_out		;
	logic [31:0] ifft_imag_out		;
	logic [9:0]  ifft_counter_out	;
	logic ifft_valid_out			;
	//sr_response
	logic sr_response_CS;
	logic sr_response_OE;	
	logic sr_response_WEB;
	logic [9:0] sr_response_A;
	logic [31:0] sr_response_DI;
	logic [31:0] sr_response_DO;
	//bridge
	logic [31:0] fft_real_out_B;
	logic [31:0] fft_imag_out_B;
	logic [9:0] fft_counter_out_B;
	logic fft_valid_out_B;
	
	//ctrl
	assign ctrl_inst = inst;
	assign ctrl_fft_addr_out = fft_counter_out;
	assign ctrl_div_addr_out = div_addr_out;
	assign ctrl_ifft_addr_out = ifft_counter_out;
	assign ctrl_mul_enable = mul_enable_out;
	
	logic ctrl_sr0_oe_d1;
	always_ff@(posedge clk or posedge rst)begin
		if(rst)
			ctrl_sr0_oe_d1 <= 1'b0;
		else
			ctrl_sr0_oe_d1 <= ctrl_sr0_oe;
	end
	
	logic ctrl_fft_en_d1;
	always_ff@(posedge clk or posedge rst)begin
		if(rst)
			ctrl_fft_en_d1 <= 1'b0;
		else
			ctrl_fft_en_d1 <= ctrl_fft_en;
	end
	
	//sr_frame
	assign sr_frame_CS = sr0_we | ctrl_sr0_oe;
	assign sr_frame_OE = ctrl_sr0_oe_d1;
	assign sr_frame_WEB = ~sr0_we;
	assign sr_frame_A = (ctrl_sr0_addr_sel == 1'b0) ? sr0_addr_in : ctrl_sr0_addr;
	assign sr_frame_DI = sr0_data_in;
 	
	//fft
	assign fft_enable = ctrl_fft_en_d1;
	assign fft_real_in = sr_frame_DO;
	assign fft_imag_in = 32'd0;
	
	//div
	assign div_F_real = (ctrl_fft_data_sel == 1'b0) ? fft_real_out : 32'd0;
	assign div_F_image = (ctrl_fft_data_sel == 1'b0) ? fft_imag_out : 32'd0;
	assign div_addr = (ctrl_fft_data_sel == 1'b0) ? fft_counter_out : 10'd0;
	assign div_enable = (ctrl_fft_data_sel == 1'b0) ? fft_valid_out : 1'b0;
	
	//bridge
	assign fft_real_out_B = (ctrl_fft_data_sel == 1'b1) ? fft_real_out : 32'd0;
	assign fft_imag_out_B = (ctrl_fft_data_sel == 1'b1) ? fft_imag_out : 32'd0;
	assign fft_counter_out_B = (ctrl_fft_data_sel == 1'b1) ? fft_counter_out : 10'd0;
	assign fft_valid_out_B = (ctrl_fft_data_sel == 1'b1) ? fft_valid_out : 1'd0;
	
	logic [31:0] fft_real_out_B_D1;
	logic [31:0] fft_imag_out_B_D1;
	logic [9:0] fft_counter_out_B_D1;
	logic fft_valid_out_B_D1;
	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			fft_real_out_B_D1 <= 32'd0;
			fft_imag_out_B_D1 <= 32'd0;
			fft_counter_out_B_D1 <= 10'd0;
			fft_valid_out_B_D1 <= 1'd0;
		end
		else begin
			fft_real_out_B_D1 <= fft_real_out_B;
			fft_imag_out_B_D1 <= fft_imag_out_B;
			fft_counter_out_B_D1 <= fft_counter_out_B;
			fft_valid_out_B_D1 <= fft_valid_out_B;
		end
	end
	
	//H_real
	assign H_real_CS = div_enable_out | fft_valid_out_B;
	assign H_real_OE = fft_valid_out_B_D1;
	assign H_real_WEB = ~div_enable_out;
	assign H_real_A = (ctrl_fft_data_sel == 1'b0) ? div_addr_out : fft_counter_out_B;
	assign H_real_DI = div_H_real;
	
	//H_imag
	assign H_imag_CS = div_enable_out | fft_valid_out_B;
	assign H_imag_OE = fft_valid_out_B_D1;
	assign H_imag_WEB = ~div_enable_out;
	assign H_imag_A = (ctrl_fft_data_sel == 1'b0) ? div_addr_out : fft_counter_out_B;
	assign H_imag_DI = div_H_image;
	
	//mul
	assign mul_a = fft_real_out_B_D1;
	assign mul_b = fft_imag_out_B_D1;
	assign mul_c = H_real_DO;
	assign mul_d = H_imag_DO;
	assign mul_addr	= fft_counter_out_B_D1;
	assign mul_enable = fft_valid_out_B_D1;
	
	//ifft
	assign ifft_enable = mul_enable_out | ctrl_ifft_en;
	assign ifft_real_in = mul_real_out;
	assign ifft_imag_in = mul_imag_out;
	
	//sr_response
	logic sr1_oe_D1;
	always_ff@(posedge clk or posedge rst)begin
		if(rst)
			sr1_oe_D1 <= 1'd0;
		else
			sr1_oe_D1 <= sr1_oe;
	end
	
	assign sr_response_CS = sr1_oe | ifft_valid_out;
	assign sr_response_OE = sr1_oe_D1;
	assign sr_response_WEB = ~ifft_valid_out;
	assign sr_response_A = (ctrl_sr1_addr_sel == 1'b0) ? sr1_addr_in : ifft_counter_out;
	assign sr_response_DI = ifft_real_out;
	
	assign sr1_data_out = sr_response_DO;
	
	controller ctrl(
		.clk			(clk				),
		.rst			(rst				),
		.inst			(ctrl_inst			),
		.fft_addr_out	(ctrl_fft_addr_out	),
		.div_addr_out	(ctrl_div_addr_out	),
		.ifft_addr_out	(ctrl_ifft_addr_out	),
		.mul_enable		(ctrl_mul_enable	),
		.sr0_addr_sel	(ctrl_sr0_addr_sel	),
		.sr0_addr		(ctrl_sr0_addr		),
		.sr0_oe			(ctrl_sr0_oe		),
		.fft_data_sel	(ctrl_fft_data_sel	),
		.fft_en			(ctrl_fft_en		),
		.ifft_en		(ctrl_ifft_en		),
		.sr1_addr_sel	(ctrl_sr1_addr_sel	)
	);
	
	sram_1024_wrapper sr_frame(
		.CK	(clk			),
		.CS	(sr_frame_CS	),
		.OE	(sr_frame_OE	),
		.WEB(sr_frame_WEB	),
		.A	(sr_frame_A		),
		.DI	(sr_frame_DI	),
		.DO	(sr_frame_DO	)
	);
	
	FFT_32_32 fft(
		.enable		(fft_enable		),
		.clk		(clk			),
		.rst		(rst			),
		.real_in	(fft_real_in	),
		.imag_in	(fft_imag_in	),
		.real_out	(fft_real_out	),
		.imag_out	(fft_imag_out	),
		.counter_out(fft_counter_out),
		.valid_out	(fft_valid_out	)
	);
	
	divider_top div(
		.clk		(clk			),
		.rst		(rst			),
		.F_real		(div_F_real		),
		.F_image	(div_F_image	),
		.addr		(div_addr		),
		.enable		(div_enable		),
		.H_real		(div_H_real		),
		.H_image	(div_H_image	),
		.addr_out	(div_addr_out	),
		.enable_out	(div_enable_out	)
	);
	
	sram_1024_wrapper H_real(
		.CK	(clk		),
		.CS	(H_real_CS	),
		.OE	(H_real_OE	),
		.WEB(H_real_WEB	),
		.A	(H_real_A	),
		.DI	(H_real_DI	),
		.DO	(H_real_DO	)
	);
	
	sram_1024_wrapper H_imag(
		.CK	(clk		),
		.CS	(H_imag_CS	),
		.OE	(H_imag_OE	),
		.WEB(H_imag_WEB	),
		.A	(H_imag_A	),
		.DI	(H_imag_DI	),
		.DO	(H_imag_DO	)
	);
	
	complex_multiply mul(
		.clk		(clk			),
		.rst		(rst			),
		.a			(mul_a			),
		.b			(mul_b			),
		.c			(mul_c			),
		.d			(mul_d			),
		.addr		(mul_addr		),
		.enable		(mul_enable		),
		.real_out	(mul_real_out	),
		.imag_out	(mul_imag_out	),
		.addr_out	(mul_addr_out	),
		.enable_out	(mul_enable_out	)
	);
	
	IFFT_32_32 ifft(
		.enable		(ifft_enable		),
		.clk		(clk				),
		.rst		(rst				),
		.real_in	(ifft_real_in		),
		.imag_in	(ifft_imag_in		),
		.real_out	(ifft_real_out		),
		.imag_out	(ifft_imag_out		),
		.counter_out(ifft_counter_out	),
		.valid_out	(ifft_valid_out		)
	);
	
	sram_1024_wrapper sr_response(
		.CK	(clk			),
		.CS	(sr_response_CS	),
		.OE	(sr_response_OE	),
		.WEB(sr_response_WEB),
		.A	(sr_response_A	),
		.DI	(sr_response_DI	),
		.DO	(sr_response_DO	)
	);
	
endmodule
	
