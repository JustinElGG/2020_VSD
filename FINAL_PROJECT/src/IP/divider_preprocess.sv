//`include "sign_processing_unit.sv"

module divider_preprocess(
	input 				clk,
	input 				rst,
	input [31:0] 		a,
	input [31:0] 		b,
	input [31:0] 		c,
	input [9:0] 		addr,
	input 				enable,
	output logic [31:0] A_real,
	output logic [31:0] A_image,
	output logic [31:0] B_both,
	output logic [9:0] 	addr_out,
	output logic 		enable_out
);
	
	logic sign_a;
	logic sign_b;
	logic sign_c;
	logic [31:0] a_process;
	logic [31:0] b_process;
	logic [31:0] c_process;
	
	logic [63:0] a_mult_c;
	logic [63:0] b_mult_c;
	logic [63:0] a_sqr_plus_b_sqr;
	
	logic sign_A_real;
	logic sign_A_image;
	
	logic [9:0] addr_t;
	logic enable_t;
	assign addr_t = addr;
	assign enable_t = enable;
	
	sign_processing_unit spu_a(
		.D_in(a),
		.sign(sign_a),
		.D_out(a_process)
	);
	
	sign_processing_unit spu_b(
		.D_in(b),
		.sign(sign_b),
		.D_out(b_process)
	);
	
	sign_processing_unit spu_c(
		.D_in(c),
		.sign(sign_c),
		.D_out(c_process)
	);
	
	assign a_mult_c = a_process * c_process;
	assign b_mult_c = b_process * c_process;
	assign a_sqr_plus_b_sqr = (a_process * a_process) + (b_process * b_process);
	
	assign sign_A_real = sign_a ^ sign_c;
	assign sign_A_image = sign_b ^ sign_c ^ 1'b1;
	
	logic [63:0] a_mult_c_1;
	logic [63:0] b_mult_c_1;
	logic [63:0] a_sqr_plus_b_sqr_1;
	logic [9:0] addr_t_1;
	logic enable_t_1;
	logic sign_A_real_1;
	logic sign_A_image_1;
	
	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			a_mult_c_1 <= 64'd0;
			b_mult_c_1 <= 64'd0;
			a_sqr_plus_b_sqr_1 <= 64'd0;
			addr_t_1 <= 10'd0;
			enable_t_1 <= 1'd0;
			sign_A_real_1 <= 1'd0;
			sign_A_image_1 <= 1'd0;
		end
		else begin
			a_mult_c_1 <= a_mult_c;
			b_mult_c_1 <= b_mult_c;
			a_sqr_plus_b_sqr_1 <= a_sqr_plus_b_sqr;
			addr_t_1 <= addr_t;
			enable_t_1 <= enable_t;
			sign_A_real_1 <= sign_A_real;
			sign_A_image_1 <= sign_A_image;
		end
	end
	
	logic [63:0] a_mult_c_process;
	logic [63:0] b_mult_c_process;
	
	logic [31:0] A_real_w;
    logic [31:0] A_image_w;
    logic [31:0] B_w;
	
	assign a_mult_c_process = (sign_A_real_1 == 1'b1 ) ? ((a_mult_c_1 - 64'd1) ^ 64'hffffffffffffffff) : a_mult_c_1;
	assign b_mult_c_process = (sign_A_image_1 == 1'b1) ? ((b_mult_c_1 - 64'd1) ^ 64'hffffffffffffffff) : b_mult_c_1;
	
	assign A_real_w = a_mult_c_process[47:16];
	assign A_image_w = b_mult_c_process[47:16];
	assign B_w = a_sqr_plus_b_sqr_1[47:16];
	
	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			A_real <= 32'd0;
			A_image <= 32'd0;
			B_both <= 32'd0;
			addr_out <= 10'd0;
			enable_out <= 1'b0;
		end
		else begin
			A_real <= A_real_w;
			A_image <= A_image_w;
			B_both <= B_w;
			addr_out <= addr_t_1;
			enable_out <= enable_t_1;
		end
	end
	
endmodule
	
