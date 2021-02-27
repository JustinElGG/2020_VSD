module FFT_32(
input enable,
input clk,
input rst,
input signed[31:0]real_in,
input signed[31:0]imag_in,
output logic signed[31:0]real_out,
output logic signed[31:0]imag_out
);
//R2SDF 32 point
logic B1_mode,B2_mode,B3_mode,B4_mode,B5_mode;
logic [5:0]counter ; 
logic signed[15:0]tf_real[0:15];
logic signed[15:0]tf_imag[0:15];
integer i, j, k, l, m, n, o, p;
logic start;

//twiddle factor
assign tf_real[0]  =  16'd16384  ;
assign tf_real[1]  =  16'd16069  ;
assign tf_real[2]  =  16'd15136  ;
assign tf_real[3]  =  16'd13622  ;
assign tf_real[4]  =  16'd11585  ;
assign tf_real[5]  =  16'd9102   ;
assign tf_real[6]  =  16'd6269   ;
assign tf_real[7]  =  16'd3196   ;
assign tf_real[8]  =  16'd0      ;
assign tf_real[9]  = -16'd3197   ;
assign tf_real[10] = -16'd6270   ;
assign tf_real[11] = -16'd9103   ;
assign tf_real[12] = -16'd11586  ;
assign tf_real[13] = -16'd13623  ;
assign tf_real[14] = -16'd15137  ;
assign tf_real[15] = -16'd16070  ;
				   
assign tf_imag[0]  =  16'd0      ;
assign tf_imag[1]  =  16'd3197   ;
assign tf_imag[2]  =  16'd6270   ;
assign tf_imag[3]  =  16'd9103   ;
assign tf_imag[4]  =  16'd11586  ;
assign tf_imag[5]  =  16'd13623  ;
assign tf_imag[6]  =  16'd15137  ;
assign tf_imag[7]  =  16'd16070  ;
assign tf_imag[8]  =  16'd16384  ;
assign tf_imag[9]  =  16'd16070  ;
assign tf_imag[10] =  16'd15137  ;
assign tf_imag[11] =  16'd13623  ;
assign tf_imag[12] =  16'd11586  ;
assign tf_imag[13] =  16'd9103   ;
assign tf_imag[14] =  16'd6270   ;
assign tf_imag[15] =  16'd3197   ;







always@(posedge clk or posedge rst)
begin
	if(rst) begin
		counter <= 6'd0 ;
		//start <= 1'b0 ;
	end
	else begin
		if(enable) begin
		//	start <= 1'b1 ;
		//	if(start) begin
				counter <= counter + 6'd1 ;
		//	end			
		end
		else begin
			counter <= 6'd0 ;	
		end
	end
end

//twiddle factor assign
logic [3:0]m1_idx,m2_idx,m3_idx,m4_idx;




logic signed [15:0]m1_in_real;
logic signed [15:0]m2_in_real;
logic signed [15:0]m3_in_real;
logic signed [15:0]m4_in_real;
logic signed [15:0]m1_in_imag;
logic signed [15:0]m2_in_imag;
logic signed [15:0]m3_in_imag;
logic signed [15:0]m4_in_imag;

logic [31:0]m1_real_out_buf,m2_real_out_buf,m3_real_out_buf,m4_real_out_buf;
logic [31:0]m1_imag_out_buf,m2_imag_out_buf,m3_imag_out_buf,m4_imag_out_buf;
logic [5:0]counter_buf1,counter_buf2,counter_buf3,counter_buf4;

always_comb 
begin
	m1_idx = counter[3:0];
	m2_idx = {counter_buf1[2:0],1'b0};
	m3_idx = {counter_buf2[1:0],2'b0};
	m4_idx = {counter_buf3[0],3'b0};
end

always_comb 
begin
	if(counter[4] == 1'b1) begin
		m1_in_real = tf_real[m1_idx];	
		m1_in_imag = tf_imag[m1_idx];	
	end
	else begin
		m1_in_real = 16'd16384;	
		m1_in_imag = 16'd0;	
	end
	if(counter_buf1[3] == 1'b1) begin
		m2_in_real = tf_real[m2_idx];
		m2_in_imag = tf_imag[m2_idx];		
	end
	else begin
		m2_in_real = 16'd16384;	
		m2_in_imag = 16'd0;	
	end	
	if(counter_buf2[2] == 1'b1) begin	
		m3_in_real = tf_real[m3_idx];
		m3_in_imag = tf_imag[m3_idx];		
	end
	else begin
		m3_in_real = 16'd16384;	
		m3_in_imag = 16'd0;	
	end	
	if(counter_buf3[1] == 1'b1) begin
		m4_in_real = tf_real[m4_idx];
		m4_in_imag = tf_imag[m4_idx];
    end	
	else begin
		m4_in_real = 16'd16384;	
		m4_in_imag = 16'd0;	
	end	
end

always_comb   //0: commutation 1: operation
begin
  if(counter[4] == 1'b1) B1_mode = 1'b1;
  else 					 B1_mode = 1'b0;
end
always_comb   //0: commutation 1: operation
begin
  if(counter_buf1[3] == 1'b1) B2_mode = 1'b1;
  else 					 B2_mode = 1'b0;
end
always_comb   //0: commutation 1: operation
begin
  if(counter_buf2[2] == 1'b1) B3_mode = 1'b1;
  else 					 B3_mode = 1'b0;
end
always_comb   //0: commutation 1: operation
begin
  if(counter_buf3[1] == 1'b1) B4_mode = 1'b1;
  else 					 B4_mode = 1'b0;
end
always_comb   //0: commutation 1: operation
begin
  if(counter_buf4[0] == 1'b1) B5_mode = 1'b1;
  else 					 B5_mode = 1'b0;
end

//-----------------stage1_16-----------------//
logic signed [31:0] real_16_reg[0:15];
logic signed [31:0] imag_16_reg[0:15];
logic signed [31:0] B1_real_out1 ;
logic signed [31:0] B1_imag_out1 ;
logic signed [31:0] B1_real_out2 ;
logic signed [31:0] B1_imag_out2 ;
BF2 B1(
//input
.mode(B1_mode),
.real_in1(real_16_reg[15]),
.imag_in1(imag_16_reg[15]),
.real_in2(real_in),
.imag_in2(imag_in),
//output
.real_out1(B1_real_out1), 
.imag_out1(B1_imag_out1), 
.real_out2(B1_real_out2), 
.imag_out2(B1_imag_out2) 
);
always@(posedge clk or posedge rst)
begin
	if(rst) begin
		for(i=0;i<16;i=i+1) begin
			real_16_reg[i] <= 32'd0 ;
			imag_16_reg[i] <= 32'd0 ;
		end
	end
	else begin
		real_16_reg[0] <= B1_real_out1 ;
		imag_16_reg[0] <= B1_imag_out1 ;
		for(j=0;j<15;j=j+1) begin
			real_16_reg[j+1] <= real_16_reg[j] ;
			imag_16_reg[j+1] <= imag_16_reg[j] ;
		end	
	end
end
//--------------------------------------------//
logic signed[31:0]m1_real_out ;
logic signed[31:0]m1_imag_out ;
complex_mul m1(
//input
.real_in1(B1_real_out2),
.imag_in1(B1_imag_out2),
.real_in2(m1_in_real),   //twinddle factor
.imag_in2(m1_in_imag),   //twinddle factor
//output
.real_out(m1_real_out), 
.imag_out(m1_imag_out) 
);



//-----------------stage2_8-----------------//
logic signed[31:0] real_8_reg[0:7];
logic signed[31:0] imag_8_reg[0:7];
logic signed[31:0] B2_real_out1 ;
logic signed[31:0] B2_imag_out1 ;
logic signed[31:0] B2_real_out2 ;
logic signed[31:0] B2_imag_out2 ;
BF2 B2(
//input
.mode(B2_mode),
.real_in1(real_8_reg[7]),
.imag_in1(imag_8_reg[7]),
.real_in2(m1_real_out_buf),
.imag_in2(m1_imag_out_buf),
//output
.real_out1(B2_real_out1), 
.imag_out1(B2_imag_out1), 
.real_out2(B2_real_out2), 
.imag_out2(B2_imag_out2) 
);
always@(posedge clk or posedge rst)
begin
	if(rst) begin
		for(k=0;k<8;k=k+1) begin
			real_8_reg[k] <= 32'd0 ;
			imag_8_reg[k] <= 32'd0 ;
		end
	end
	else begin
		real_8_reg[0] <= B2_real_out1 ;
		imag_8_reg[0] <= B2_imag_out1 ;
	    for(l=0;l<7;l=l+1) begin
			real_8_reg[l+1] <= real_8_reg[l] ;
		    imag_8_reg[l+1] <= imag_8_reg[l] ;
		end
	end
end
//--------------------------------------------//
logic signed[31:0]m2_real_out ;
logic signed[31:0]m2_imag_out ;
complex_mul m2(
//input
.real_in1(B2_real_out2),
.imag_in1(B2_imag_out2),
.real_in2(m2_in_real),   //twinddle factor
.imag_in2(m2_in_imag),   //twinddle factor
//output
.real_out(m2_real_out), 
.imag_out(m2_imag_out) 
);
//-----------------stage3_4-----------------//
logic signed[31:0] real_4_reg[0:3];
logic signed[31:0] imag_4_reg[0:3];
logic signed[31:0] B3_real_out1 ;
logic signed[31:0] B3_imag_out1 ;
logic signed[31:0] B3_real_out2 ;
logic signed[31:0] B3_imag_out2 ;
BF2 B3(
//input
.mode(B3_mode),
.real_in1(real_4_reg[3]),
.imag_in1(imag_4_reg[3]),
.real_in2(m2_real_out_buf),
.imag_in2(m2_imag_out_buf),
//output
.real_out1(B3_real_out1), 
.imag_out1(B3_imag_out1), 
.real_out2(B3_real_out2), 
.imag_out2(B3_imag_out2) 
);
always@(posedge clk or posedge rst)
begin
	if(rst) begin
		for(m=0;m<4;m=m+1) begin
			real_4_reg[m] <= 32'd0 ;
			imag_4_reg[m] <= 32'd0 ;
		end
	end
	else begin
		real_4_reg[0] <= B3_real_out1 ;
		imag_4_reg[0] <= B3_imag_out1 ;
	    for(n=0;n<3;n=n+1) begin
			real_4_reg[n+1] <= real_4_reg[n] ;
		    imag_4_reg[n+1] <= imag_4_reg[n] ;
		end
	end
end
//--------------------------------------------//
logic signed[31:0]m3_real_out ;
logic signed[31:0]m3_imag_out ;
complex_mul m3(
//input
.real_in1(B3_real_out2),
.imag_in1(B3_imag_out2),
.real_in2(m3_in_real),   //twinddle factor
.imag_in2(m3_in_imag),   //twinddle factor
//output
.real_out(m3_real_out), 
.imag_out(m3_imag_out) 
);
//-----------------stage4_2-----------------//
logic signed[31:0] real_2_reg[0:1];
logic signed[31:0] imag_2_reg[0:1];
logic signed[31:0] B4_real_out1 ;
logic signed[31:0] B4_imag_out1 ;
logic signed[31:0] B4_real_out2 ;
logic signed[31:0] B4_imag_out2 ;
BF2 B4(
//input
.mode(B4_mode),
.real_in1(real_2_reg[1]),
.imag_in1(imag_2_reg[1]),
.real_in2(m3_real_out_buf),
.imag_in2(m3_imag_out_buf),
//output
.real_out1(B4_real_out1), 
.imag_out1(B4_imag_out1), 
.real_out2(B4_real_out2), 
.imag_out2(B4_imag_out2) 
);
always@(posedge clk or posedge rst)
begin
	if(rst) begin
		for(o=0;o<2;o=o+1) begin
			real_2_reg[o] <= 32'd0 ;
			imag_2_reg[o] <= 32'd0 ;
		end
	end
	else begin
		real_2_reg[0] <= B4_real_out1 ;
		imag_2_reg[0] <= B4_imag_out1 ;
	    for(p=0;p<1;p=p+1) begin
			real_2_reg[p+1] <= real_2_reg[p] ;
		    imag_2_reg[p+1] <= imag_2_reg[p] ;
		end
	end
end
//--------------------------------------------//
logic signed[31:0]m4_real_out ;
logic signed[31:0]m4_imag_out ;
complex_mul m4(
//input
.real_in1(B4_real_out2),
.imag_in1(B4_imag_out2),
.real_in2(m4_in_real),   //twinddle factor
.imag_in2(m4_in_imag),   //twinddle factor
//output
.real_out(m4_real_out), 
.imag_out(m4_imag_out) 
);
//-----------------stage5_1-----------------//
logic signed[31:0] real_1_reg;
logic signed[31:0] imag_1_reg;
logic signed[31:0] B5_real_out1 ;
logic signed[31:0] B5_imag_out1 ;
logic signed[31:0] B5_real_out2 ;
logic signed[31:0] B5_imag_out2 ;
BF2 B5(
//input
.mode(B5_mode),
.real_in1(real_1_reg),
.imag_in1(imag_1_reg),
.real_in2(m4_real_out_buf),
.imag_in2(m4_imag_out_buf),
//output
.real_out1(B5_real_out1), 
.imag_out1(B5_imag_out1), 
.real_out2(B5_real_out2),      //system out
.imag_out2(B5_imag_out2)       //system out
);
always@(posedge clk or posedge rst)
begin
	if(rst) begin
		real_1_reg <= 32'd0 ;
		imag_1_reg <= 32'd0 ;
	end
	else begin
		real_1_reg <= B5_real_out1 ;
		imag_1_reg <= B5_imag_out1 ;
	end
end
//--------------------------------------------//

always@(posedge clk or posedge rst)
begin
	if(rst) begin
		real_out <= 32'd0 ;
		imag_out <= 32'd0 ;
	end
	else begin
		real_out <= B5_real_out2 ;
		imag_out <= B5_imag_out2 ;
	end
end

always@(posedge clk or posedge rst)
begin
	if(rst) begin
		m1_real_out_buf <= 32'd0;
		m2_real_out_buf <= 32'd0;
		m3_real_out_buf <= 32'd0;
		m4_real_out_buf <= 32'd0;
		m1_imag_out_buf <= 32'd0;
		m2_imag_out_buf <= 32'd0;
		m3_imag_out_buf <= 32'd0;
		m4_imag_out_buf <= 32'd0;
		counter_buf1    <= 6'd0;
		counter_buf2    <= 6'd0;
		counter_buf3    <= 6'd0;
		counter_buf4    <= 6'd0;
	end
	else begin
		m1_real_out_buf <= m1_real_out;
		m2_real_out_buf <= m2_real_out;
		m3_real_out_buf <= m3_real_out;
		m4_real_out_buf <= m4_real_out;
		m1_imag_out_buf <= m1_imag_out;		
		m2_imag_out_buf <= m2_imag_out;		
		m3_imag_out_buf <= m3_imag_out;		
		m4_imag_out_buf <= m4_imag_out;		
		counter_buf1    <= counter;
		counter_buf2    <= counter_buf1;
		counter_buf3    <= counter_buf2;
		counter_buf4    <= counter_buf3;		
	end
end


endmodule




