
module re_index(
input enable,
input clk,
input rst,
input signed[31:0]real_in,
input signed[31:0]imag_in,
output logic signed[31:0]real_out,
output logic signed[31:0]imag_out,
output logic [9:0] counter,
output logic  valid
);

//logic signed[31:0]register_real[0:1023];
//logic signed[31:0]register_imag[0:1023];
logic [4:0] col_counter, row_counter;
logic [4:0] col_reverse, row_reverse;
logic [9:0] index ;
integer i ;
logic reindex_finish, reindex_finish_buf ;


logic CS , OE ,WEB ;
logic [9:0]A ;
logic [31:0]real_DI, imag_DI, real_DO, imag_DO ;
assign CS = OE | ~WEB ;

	sram_1024_wrapper real_sram_reinx(
		.CK	(clk),
		.CS	(CS),
		.OE	(OE),
		.WEB(WEB),
		.A	(A),
		.DI	(real_DI),
		.DO	(real_DO)
	);

	sram_1024_wrapper imag_sram_reinx(
		.CK	(clk),
		.CS	(CS),
		.OE	(OE),
		.WEB(WEB),
		.A	(A),
		.DI	(imag_DI),
		.DO	(imag_DO)
	);
/*
always@(posedge clk or posedge rst)
begin
	if(rst) begin
		for(i=0;i<1024;i=i+1) begin
			register_real[i] <= 32'd0 ;
			register_imag[i] <= 32'd0 ;
		end		
	end
	else begin
		if(enable) begin
			if(!reindex_finish) begin
				register_real[index] <= real_in ;
				register_imag[index] <= imag_in ;	
			end
		end
		else begin
			for(i=0;i<1024;i=i+1) begin
				register_real[i] <= 32'd0 ;
				register_imag[i] <= 32'd0 ;
			end				
		end
	end
end
*/


always_comb
begin
	if(enable)begin
		if(reindex_finish) begin
			/*
				real_out = register_real[counter];
				imag_out = register_imag[counter];	
			*/
			A 		= counter ;
			real_DI = 32'd0 ;
			imag_DI = 32'd0 ;
			WEB 	= 1'b1; 
			OE		= 1'b1;//read
			real_out = real_DO;
			imag_out = imag_DO;
		end
		/*else if(reindex_finish && (!reindex_finish_buf)) begin
			A 		= 10'd0		;
			real_DI = 32'd0     ;
			imag_DI = 32'd0     ;
			WEB 	= 1'b1; 
			OE		= 1'b0;
			real_out = 32'd0;
			imag_out = 32'd0;	
		end*/
		else begin
			/*
				real_out = 32'd0;
				imag_out = 32'd0;	
			*/
			A 		= index ;
			real_DI = real_in ;
			imag_DI = imag_in ;
			WEB 	= 1'b0; 
			OE		= 1'b0;//read
			real_out = 32'd0;
			imag_out = 32'd0;		
		end
	end
	else begin
		A 		= 10'd0		;
		real_DI = 32'd0     ;
		imag_DI = 32'd0     ;
		WEB 	= 1'b1; 
		OE		= 1'b0;//read
		real_out = 32'd0;
		imag_out = 32'd0;		
	
	end
end


logic valid_buf1,valid_buf2;
assign valid_buf1 = reindex_finish_buf & enable ;
assign valid = valid_buf1 & valid_buf2;

always@(posedge clk or posedge rst)
begin
	if(rst) begin
		reindex_finish_buf  <= 10'd0;
		valid_buf2 			<= 1'b0;
	end
	else begin
		reindex_finish_buf	<= reindex_finish;
		valid_buf2			<= valid_buf1;
	end
end




always@(posedge clk or posedge rst)
begin
	if(rst) begin
		col_counter <= 5'd0;		
		row_counter <= 5'd0;
		reindex_finish <= 1'b0;
	end
	else begin
		if(enable) begin
			col_counter <= col_counter + 5'd1;
			if(col_counter == 5'd31) begin
				if(row_counter == 5'd31) begin
					reindex_finish <= 1'b1;
				end			
				row_counter <= row_counter + 5'd1;
			end		
		end
		else begin
			col_counter <= 5'd0;		
			row_counter <= 5'd0;
			reindex_finish <= 1'b0;
		end
	end
end

always_comb
begin
	col_reverse = {col_counter[0],col_counter[1],col_counter[2],col_counter[3],col_counter[4]} + 5'd1;
	row_reverse = {row_counter[0],row_counter[1],row_counter[2],row_counter[3],row_counter[4]} + 5'd1;
	index = { col_reverse, 5'd0 } + { 5'd0, row_reverse };
end



always@(posedge clk or posedge rst)
begin
	if(rst) begin
		counter  <= 10'd0;
	end
	else begin
		if(reindex_finish_buf) begin
			counter <= counter + 10'd1;
        end		
		else begin
			counter  <= 10'd0;			
		end
	end
end





endmodule