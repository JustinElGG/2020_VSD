module complex_mul(
input signed [31:0]real_in1,
input signed [31:0]imag_in1,
input signed [15:0]real_in2,   //twinddle factor
input signed [15:0]imag_in2,   //twinddle factor
output logic signed [31:0]real_out, 
output logic signed [31:0]imag_out
);
//  ( a + bi ) * ( c + di )= ac - bd + i*( bc + ad )

logic signed [47:0]real1_real2_mul_tmp ; 
logic signed [47:0]imag1_imag2_mul_tmp ;
logic signed [47:0]real1_imag2_mul_tmp ; 
logic signed [47:0]imag1_real2_mul_tmp ; 
logic signed [47:0]real_out_tmp ; 
logic signed [47:0]imag_out_tmp ; 

always_comb
begin
	real1_real2_mul_tmp = real_in1 * real_in2 ; //ac
	imag1_imag2_mul_tmp = imag_in1 * imag_in2 ; //bd
	real1_imag2_mul_tmp = real_in1 * imag_in2 ; //ad
	imag1_real2_mul_tmp = imag_in1 * real_in2 ; //bc
	
	real_out_tmp = real1_real2_mul_tmp - imag1_imag2_mul_tmp ; //ac - bd
	imag_out_tmp = real1_imag2_mul_tmp + imag1_real2_mul_tmp ; //ad + bc
	
	real_out = {real_out_tmp[47],real_out_tmp[44:14]} ; //(s15.16) s[44-30] , [29-14]
	imag_out = {imag_out_tmp[47],imag_out_tmp[44:14]} ; //(s15.16) s[44-30] , [29-14]
end


endmodule