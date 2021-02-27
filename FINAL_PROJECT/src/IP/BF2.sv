module BF2(
input mode,           //0: commutation 1: operation
input signed [31:0]real_in1,
input signed [31:0]imag_in1,
input signed [31:0]real_in2,
input signed [31:0]imag_in2,
output logic signed [31:0]real_out1, 
output logic signed [31:0]imag_out1, 
output logic signed [31:0]real_out2, 
output logic signed [31:0]imag_out2 
);

always_comb
begin
	if(mode) begin //operation
		real_out1 = real_in2 + real_in1;
	    imag_out1 = imag_in2 + imag_in1;
	    real_out2 = real_in1 - real_in2;
	    imag_out2 = imag_in1 - imag_in2;		
	end
	else begin     //commutation
		real_out1 = real_in2 ;
	    imag_out1 = imag_in2 ;
	    real_out2 = real_in1 ;
	    imag_out2 = imag_in1 ;
	end
end


endmodule