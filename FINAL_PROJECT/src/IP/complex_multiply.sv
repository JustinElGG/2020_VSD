module complex_multiply(
	input clk,
	input rst,
	input [31:0] a,
	input [31:0] b,
	input [31:0] c,
	input [31:0] d,
	// (a+bi)*(c+di)
	input [9:0] addr,
	input enable,
	output logic [31:0] real_out,
	output logic [31:0] imag_out,
	output logic [9:0] addr_out,
	output logic enable_out
);

	logic sign_a;
	logic sign_b;
	logic sign_c;
	logic sign_d;
	
	logic [31:0] a_process;
	logic [31:0] b_process;
	logic [31:0] c_process;
	logic [31:0] d_process;
	
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
	
	sign_processing_unit spu_d(
		.D_in(d),
		.sign(sign_d),
		.D_out(d_process)
	);
	
	logic [63:0] a_mult_c;
	logic [63:0] b_mult_d;
	logic [63:0] a_mult_d;
	logic [63:0] b_mult_c;
	
	assign a_mult_c = a_process * c_process;
	assign b_mult_d = b_process * d_process;
	assign a_mult_d = a_process * d_process;
	assign b_mult_c = b_process * c_process;
	
	logic [63:0] a_mult_c_pipe0;
	logic [63:0] b_mult_d_pipe0;
	logic [63:0] a_mult_d_pipe0;
	logic [63:0] b_mult_c_pipe0;
	logic sign_a_pipe0;
	logic sign_b_pipe0;
	logic sign_c_pipe0;
	logic sign_d_pipe0;
	logic [9:0] addr_pipe0;
	logic enable_pipe0;
	
	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			a_mult_c_pipe0 <= 64'd0;
			b_mult_d_pipe0 <= 64'd0;
			a_mult_d_pipe0 <= 64'd0;
			b_mult_c_pipe0 <= 64'd0;
			sign_a_pipe0 <= 1'd0;
			sign_b_pipe0 <= 1'd0;
			sign_c_pipe0 <= 1'd0;
			sign_d_pipe0 <= 1'd0;
			addr_pipe0 <= 10'd0;
			enable_pipe0 <= 1'd0;
		end
		else begin
			a_mult_c_pipe0 <= a_mult_c;
			b_mult_d_pipe0 <= b_mult_d;
			a_mult_d_pipe0 <= a_mult_d;
			b_mult_c_pipe0 <= b_mult_c;
			sign_a_pipe0 <= sign_a;
			sign_b_pipe0 <= sign_b;
			sign_c_pipe0 <= sign_c;
			sign_d_pipe0 <= sign_d;
			addr_pipe0 <= addr;
			enable_pipe0 <= enable;
		end
	end
	
	logic [63:0] a_mult_c_process;
	logic [63:0] b_mult_d_process;
	logic [63:0] a_mult_d_process;
	logic [63:0] b_mult_c_process;
	
	assign a_mult_c_process = (sign_a_pipe0 ^ sign_c_pipe0) ? ((a_mult_c_pipe0 - 64'd1) ^ 64'hffffffffffffffff) : a_mult_c_pipe0;
	assign b_mult_d_process = (sign_b_pipe0 ^ sign_d_pipe0) ? ((b_mult_d_pipe0 - 64'd1) ^ 64'hffffffffffffffff) : b_mult_d_pipe0;
	assign a_mult_d_process = (sign_a_pipe0 ^ sign_d_pipe0) ? ((a_mult_d_pipe0 - 64'd1) ^ 64'hffffffffffffffff) : a_mult_d_pipe0;
	assign b_mult_c_process = (sign_b_pipe0 ^ sign_c_pipe0) ? ((b_mult_c_pipe0 - 64'd1) ^ 64'hffffffffffffffff) : b_mult_c_pipe0;
	
	logic [31:0] real_w;
	logic [31:0] imag_w;
	
	assign real_w = a_mult_c_process[47:16] - b_mult_d_process[47:16];
	assign imag_w = a_mult_d_process[47:16] + b_mult_c_process[47:16];
	
	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			real_out <= 32'd0;
			imag_out <= 32'd0;
			addr_out <= 10'd0;
			enable_out <= 1'd0;
		end
		else begin
			real_out <= real_w;
			imag_out <= imag_w;
			addr_out <= addr_pipe0;
			enable_out <= enable_pipe0;
		end
	end
	
	

endmodule
