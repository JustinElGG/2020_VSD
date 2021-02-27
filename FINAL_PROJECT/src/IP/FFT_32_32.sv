
module FFT_32_32(
input enable,
input clk,
input rst,
input signed[31:0]real_in,
input signed[31:0]imag_in,
output logic signed[31:0]real_out,
output logic signed[31:0]imag_out,
output logic [9:0] counter_out,
output logic valid_out
);

logic [11:0]counter ; 
//logic signed[31:0]register_real[0:1023];
//logic signed[31:0]register_imag[0:1023];
integer i ;
logic signed [31:0]FFT_1_real_out , FFT_1_real_in;
logic signed [31:0]FFT_1_imag_out , FFT_1_imag_in;
logic [9:0] counter2;
logic signed[31:0]real_FFT_out;
logic signed[31:0]imag_FFT_out;
logic [9:0] counter_out_idx;
logic store_finish, valid, valid_out_idx;

logic CS , OE ,WEB ;
logic [9:0]A ;
logic signed[31:0]real_DI, imag_DI, real_DO, imag_DO ;

assign CS = OE | ~WEB ;

	sram_1024_wrapper real_sram(
		.CK	(clk),
		.CS	(CS),
		.OE	(OE),
		.WEB(WEB),
		.A	(A),
		.DI	(real_DI),
		.DO	(real_DO)
	);

	sram_1024_wrapper imag_sram(
		.CK	(clk),
		.CS	(CS),
		.OE	(OE),
		.WEB(WEB),
		.A	(A),
		.DI	(imag_DI),
		.DO	(imag_DO)
	);


always@(posedge clk or posedge rst)
begin
	if(rst) begin
	    counter2 <= 10'd0; 
		store_finish <= 1'b0;
		real_FFT_out <= 32'd0;
		imag_FFT_out <= 32'd0;	
		/*
		for(i=0;i<1024;i=i+1) begin
			register_real[i] <= 32'd0 ;
			register_imag[i] <= 32'd0 ;
		end	
		*/
		valid <= 1'b0;		
	end
	else begin
		if(enable) begin 
			if(counter > 11'd35 && counter < 11'd1059) begin
				counter2 <= counter2 + 10'd1;
				/*
				register_real[counter2] <= FFT_1_real_out ;
				register_imag[counter2] <= FFT_1_imag_out ;
				*/
			end
			else if(counter == 11'd1059) begin
			/*
				register_real[counter2] <= FFT_1_real_out ;
				register_imag[counter2] <= FFT_1_imag_out ;	
			*/
				store_finish <= 1'b1;	
				counter2 <= 10'd0;
			end			
			else if (counter > 12'd1096 && counter < 12'd2121) begin
				real_FFT_out <= FFT_1_real_out;
				imag_FFT_out <= FFT_1_imag_out;
				valid <= 1'b1;
			end
			else if(counter > 2119 && counter < 12'd3147) begin
				valid <= 1'b1;		
			end
			else valid <= 1'b0;
		end
		else begin
			counter2 <= 10'd0; 
			store_finish <= 1'b0;
			real_FFT_out <= 32'd0;
			imag_FFT_out <= 32'd0;			
			valid <= 1'b0;
		end
	end
end

re_index re_index1(
.enable  (valid),
.clk     (clk),
.rst     (rst),
.real_in (real_FFT_out),
.imag_in (imag_FFT_out),
.real_out(real_out),
.imag_out(imag_out),
.counter (counter_out_idx),
.valid   (valid_out)
);



logic enable_sel;
always_comb
begin
	if(counter == 12'd1060) enable_sel = 1'b0 ;
	else enable_sel = enable ;
end


logic start;
always@(posedge clk or posedge rst)
begin
	if(rst) begin
		counter <= 6'd0 ;
	end
	else begin
		if(enable) begin
			//start <= 1'b1 ;
			//if(start) begin
				counter <= counter + 6'd1 ;
			//end			
		end
		else begin
			counter <= 6'd0 ;	
			//start <= 1'b0 ;
		end
	end
end



FFT_32 FFT_1(
.enable  (enable_sel),
.clk     (clk),
.rst     (rst),
.real_in (FFT_1_real_in),
.imag_in (FFT_1_imag_in),
.real_out(FFT_1_real_out),
.imag_out(FFT_1_imag_out)
);

logic [4:0]counter_3;
logic [4:0]row_counter;
always@(posedge clk or posedge rst)
begin
	if(rst) begin
		counter_3 <= 5'd0 ;
		row_counter <= 5'd0 ;
	end
	else begin
		if(store_finish) begin
			counter_3 <= counter_3 + 5'd1 ;
			if(counter_3 == 5'd31)
				row_counter <= row_counter +5'd1;
		end
		else begin
			counter_3 <= 5'd0 ;	
			row_counter <= 5'd0;
		end
	end
end

logic [9:0] FFT_1_idx ; //debug 
assign FFT_1_idx = {5'd0, row_counter } + { counter_3, 5'd0 } ;

always_comb
begin
	if(counter > 11'd35 && counter < 11'd1059) begin
		A 		= counter2 ;
		real_DI = FFT_1_real_out ;
		imag_DI = FFT_1_imag_out ;
		WEB 	= 1'b0; //write
		OE		= 1'b0;
		FFT_1_real_in = real_in;
		FFT_1_imag_in = imag_in;		
	end
	else if(counter == 11'd1059) begin
		A 		= counter2 ;
		real_DI = FFT_1_real_out ;
		imag_DI = FFT_1_imag_out ;
		WEB 	= 1'b0; //write
		OE		= 1'b0;
		FFT_1_real_in = real_in;
		FFT_1_imag_in = imag_in;		
	end		
	else begin
		if(!store_finish) begin
			A 		= 10'd0 ;
			real_DI = 32'd0 ;
			imag_DI = 32'd0 ;
			WEB 	= 1'b1; 
			OE		= 1'b0;			
			FFT_1_real_in = real_in;
			FFT_1_imag_in = imag_in;
		end
		else begin
			A 		= FFT_1_idx ;
			real_DI = 32'd0 ;
			imag_DI = 32'd0 ;
			WEB 	= 1'b1; 
			OE		= 1'b1;	//read		
			FFT_1_real_in = real_DO;
			FFT_1_imag_in = imag_DO;			
		end
	end
end


always@(posedge clk or posedge rst)
begin
	if(rst) begin
		counter_out <= 10'd0 ;
	end
	else begin
		counter_out <= counter_out_idx;
	end
end
	
	

	
	
	
	
	
	
	
endmodule








