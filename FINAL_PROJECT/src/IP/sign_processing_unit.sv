module sign_processing_unit(
	input [31:0] D_in,
	output logic sign,
	output logic [31:0] D_out
);
	wire [31:0] D_inverse;
	assign D_inverse = (D_in - 32'd1) ^ 32'hffffffff;
	
	assign sign = D_in[31];
	assign D_out = (D_in[31] == 1'b0) ? D_in : D_inverse;
	
endmodule
