`include	"divider_preprocess.sv"
`include	"divider_32_32.sv"
`include	"ground_truth_array.sv"

module divider_top(
	input clk,
	input rst,
	input [31:0] F_real,
	input [31:0] F_image,
	input [9:0] addr,
	input enable,
	output logic [31:0] H_real,
	output logic [31:0] H_image,
	output logic [9:0] addr_out,
	output logic enable_out
);
	
	logic [31:0] gt_real_out;
	
	ground_truth_array gta(
		.re(enable),
		.addr(addr),
		.gt_real_out(gt_real_out)
	);
	
	logic [31:0] F_real_pipe0;
	logic [31:0] F_image_pipe0;
	logic [9:0] addr_pipe0;
	logic enable_pipe0;
	logic [31:0] gt_real_out_pipe0;
	
	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			F_real_pipe0 <= 32'd0;
			F_image_pipe0 <= 32'd0;
			addr_pipe0 <= 10'd0;
			enable_pipe0 <= 1'd0;
			gt_real_out_pipe0 <= 32'd0;
		end
		else begin
			F_real_pipe0 <= F_real;
			F_image_pipe0 <= F_image;
			addr_pipe0 <= addr;
			enable_pipe0 <= enable;
			gt_real_out_pipe0 <= gt_real_out;
		end
	end
	
	logic [31:0] A_real_pipe1;
	logic [31:0] A_image_pipe1;
	logic [31:0] B_both_pipe1;
	logic [9:0] addr_pipe1;
	logic enable_pipe1;
	
	divider_preprocess dp(
		.clk(clk),
		.rst(rst),
		.a(F_real_pipe0),
		.b(F_image_pipe0),
		.c(gt_real_out_pipe0),
		.addr(addr_pipe0),
		.enable(enable_pipe0),
		.A_real(A_real_pipe1),
		.A_image(A_image_pipe1),
		.B_both(B_both_pipe1),
		.addr_out(addr_pipe1),
		.enable_out(enable_pipe1)
	);
	
	divider_32_32 div0(
		.clk(clk),
		.rst(rst),
		.A(A_real_pipe1),
		.B(B_both_pipe1),
		.enable(enable_pipe1),
		.addr(addr_pipe1),
		.C(H_real),
		.addr_out(addr_out),
		.enable_out(enable_out)
	);
	
	logic [9:0] addr_trash;
	logic enable_trash;
	
	divider_32_32 div1(
		.clk(clk),
		.rst(rst),
		.A(A_image_pipe1),
		.B(B_both_pipe1),
		.enable(enable_pipe1),
		.addr(addr_pipe1),
		.C(H_image),
		.addr_out(addr_trash),
		.enable_out(enable_trash)
	);
	

endmodule