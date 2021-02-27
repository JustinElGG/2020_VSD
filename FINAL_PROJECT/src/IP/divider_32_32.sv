//`include "sign_processing_unit.sv"
`include "divide_unit.sv"

module divider_32_32(
	input clk,
	input rst,
	// A / B = C ... D
	input [31:0] A,
	input [31:0] B,
	input enable,
	input [9:0] addr,
	output logic [31:0] C,
	//output logic [31:0] D,
	output logic [9:0] addr_out,
	output logic enable_out
);
	logic sign_A;
	logic sign_B;
	logic [31:0] A_pos_wire;
	logic [31:0] B_pos_wire;
	
	
	logic reg_sign_C_0;
	reg reg_enable_0;
	reg [31:0] reg_A_0;
	reg [31:0] reg_B_0;
	reg [9:0] reg_addr_0;

	sign_processing_unit spu_a(
		.D_in(A),
		.sign(sign_A),
		.D_out(A_pos_wire)
	);
	
	sign_processing_unit spu_b(
		.D_in(B),
		.sign(sign_B),
		.D_out(B_pos_wire)
	);
	
	logic [9:0] addr_t;
	assign addr_t = addr;
	logic enable_t;
	assign enable_t = enable;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_sign_C_0 <= 1'd0;
			reg_enable_0 <= 1'b0;
			reg_A_0 <= 32'd0;
			reg_B_0 <= 32'd0;
			reg_addr_0 <= 10'd0;
		end
		else begin
			reg_sign_C_0 <= (sign_A ^ sign_B);
			reg_enable_0 <= enable_t;
			reg_A_0 <= A_pos_wire;
			reg_B_0 <= B_pos_wire;
			reg_addr_0 <= addr_t;
		end
	end
	
	//0-th stage pipeline
	logic wire_C_0;
	logic [31:0] wire_D_0;
	
	divide_unit du0(
		.A({14'd0, reg_A_0[31:14]}),	
		.B(reg_B_0),
		.C(wire_C_0),
		.D(wire_D_0)
	);
	
	//1-th stage pipeline
	logic wire_C_1;
	logic [31:0] wire_D_1;
	logic [31:0] reg_A_1;
	logic [31:0] reg_B_1;
	logic [1:0] reg_C_1;
	logic [31:0] reg_D_1;
	logic reg_enable_1;
	logic reg_sign_C_1;
	logic [9:0] reg_addr_1;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_1 <= 32'd0;
			reg_B_1 <= 32'd0;
			reg_C_1 <= 2'd0;
			reg_D_1 <= 32'd0;
			reg_enable_1 <= 1'b0;
			reg_sign_C_1 <= 1'b0;
			reg_addr_1 <= 10'd0;
		end
		else begin
			reg_A_1 <= reg_A_0;
			reg_B_1 <= reg_B_0;
			reg_C_1 <= {1'b0, wire_C_0};
			reg_D_1 <= wire_D_0;
			reg_enable_1 <= reg_enable_0;
			reg_sign_C_1 <= reg_sign_C_0;
			reg_addr_1 <= reg_addr_0;
		end
	end

	divide_unit du1(
		.A({reg_D_1[30:0], reg_A_1[13]}),
		.B(reg_B_1),
		.C(wire_C_1),
		.D(wire_D_1)
	);

	//2-th stage pipeline
	logic wire_C_2;
	logic [31:0] wire_D_2;
	logic [31:0] reg_A_2;
	logic [31:0] reg_B_2;
	logic [2:0] reg_C_2;
	logic [31:0] reg_D_2;
	logic reg_enable_2;
	logic reg_sign_C_2;
	logic [9:0] reg_addr_2;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_2 <= 32'd0;
			reg_B_2 <= 32'd0;
			reg_C_2 <= 3'd0;
			reg_D_2 <= 32'd0;
			reg_enable_2 <= 1'b0;
			reg_sign_C_2 <= 1'b0;
			reg_addr_2 <= 10'd0;
		end
		else begin
			reg_A_2 <= reg_A_1;
			reg_B_2 <= reg_B_1;
			reg_C_2 <= {reg_C_1, wire_C_1};
			reg_D_2 <= wire_D_1;
			reg_enable_2 <= reg_enable_1;
			reg_sign_C_2 <= reg_sign_C_1;
			reg_addr_2 <= reg_addr_1;
		end
	end

	divide_unit du2(
		.A({reg_D_2[30:0], reg_A_2[12]}),
		.B(reg_B_2),
		.C(wire_C_2),
		.D(wire_D_2)
	);

	//3-th stage pipeline
	logic wire_C_3;
	logic [31:0] wire_D_3;
	logic [31:0] reg_A_3;
	logic [31:0] reg_B_3;
	logic [3:0] reg_C_3;
	logic [31:0] reg_D_3;
	logic reg_enable_3;
	logic reg_sign_C_3;
	logic [9:0] reg_addr_3;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_3 <= 32'd0;
			reg_B_3 <= 32'd0;
			reg_C_3 <= 4'd0;
			reg_D_3 <= 32'd0;
			reg_enable_3 <= 1'b0;
			reg_sign_C_3 <= 1'b0;
			reg_addr_3 <= 10'd0;
		end
		else begin
			reg_A_3 <= reg_A_2;
			reg_B_3 <= reg_B_2;
			reg_C_3 <= {reg_C_2, wire_C_2};
			reg_D_3 <= wire_D_2;
			reg_enable_3 <= reg_enable_2;
			reg_sign_C_3 <= reg_sign_C_2;
			reg_addr_3 <= reg_addr_2;
		end
	end

	divide_unit du3(
		.A({reg_D_3[30:0], reg_A_3[11]}),
		.B(reg_B_3),
		.C(wire_C_3),
		.D(wire_D_3)
	);

	//4-th stage pipeline
	logic wire_C_4;
	logic [31:0] wire_D_4;
	logic [31:0] reg_A_4;
	logic [31:0] reg_B_4;
	logic [4:0] reg_C_4;
	logic [31:0] reg_D_4;
	logic reg_enable_4;
	logic reg_sign_C_4;
	logic [9:0] reg_addr_4;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_4 <= 32'd0;
			reg_B_4 <= 32'd0;
			reg_C_4 <= 5'd0;
			reg_D_4 <= 32'd0;
			reg_enable_4 <= 1'b0;
			reg_sign_C_4 <= 1'b0;
			reg_addr_4 <= 10'd0;
		end
		else begin
			reg_A_4 <= reg_A_3;
			reg_B_4 <= reg_B_3;
			reg_C_4 <= {reg_C_3, wire_C_3};
			reg_D_4 <= wire_D_3;
			reg_enable_4 <= reg_enable_3;
			reg_sign_C_4 <= reg_sign_C_3;
			reg_addr_4 <= reg_addr_3;
		end
	end

	divide_unit du4(
		.A({reg_D_4[30:0], reg_A_4[10]}),
		.B(reg_B_4),
		.C(wire_C_4),
		.D(wire_D_4)
	);

	//5-th stage pipeline
	logic wire_C_5;
	logic [31:0] wire_D_5;
	logic [31:0] reg_A_5;
	logic [31:0] reg_B_5;
	logic [5:0] reg_C_5;
	logic [31:0] reg_D_5;
	logic reg_enable_5;
	logic reg_sign_C_5;
	logic [9:0] reg_addr_5;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_5 <= 32'd0;
			reg_B_5 <= 32'd0;
			reg_C_5 <= 6'd0;
			reg_D_5 <= 32'd0;
			reg_enable_5 <= 1'b0;
			reg_sign_C_5 <= 1'b0;
			reg_addr_5 <= 10'd0;
		end
		else begin
			reg_A_5 <= reg_A_4;
			reg_B_5 <= reg_B_4;
			reg_C_5 <= {reg_C_4, wire_C_4};
			reg_D_5 <= wire_D_4;
			reg_enable_5 <= reg_enable_4;
			reg_sign_C_5 <= reg_sign_C_4;
			reg_addr_5 <= reg_addr_4;
		end
	end

	divide_unit du5(
		.A({reg_D_5[30:0], reg_A_5[9]}),
		.B(reg_B_5),
		.C(wire_C_5),
		.D(wire_D_5)
	);

	//6-th stage pipeline
	logic wire_C_6;
	logic [31:0] wire_D_6;
	logic [31:0] reg_A_6;
	logic [31:0] reg_B_6;
	logic [6:0] reg_C_6;
	logic [31:0] reg_D_6;
	logic reg_enable_6;
	logic reg_sign_C_6;
	logic [9:0] reg_addr_6;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_6 <= 32'd0;
			reg_B_6 <= 32'd0;
			reg_C_6 <= 7'd0;
			reg_D_6 <= 32'd0;
			reg_enable_6 <= 1'b0;
			reg_sign_C_6 <= 1'b0;
			reg_addr_6 <= 10'd0;
		end
		else begin
			reg_A_6 <= reg_A_5;
			reg_B_6 <= reg_B_5;
			reg_C_6 <= {reg_C_5, wire_C_5};
			reg_D_6 <= wire_D_5;
			reg_enable_6 <= reg_enable_5;
			reg_sign_C_6 <= reg_sign_C_5;
			reg_addr_6 <= reg_addr_5;
		end
	end

	divide_unit du6(
		.A({reg_D_6[30:0], reg_A_6[8]}),
		.B(reg_B_6),
		.C(wire_C_6),
		.D(wire_D_6)
	);

	//7-th stage pipeline
	logic wire_C_7;
	logic [31:0] wire_D_7;
	logic [31:0] reg_A_7;
	logic [31:0] reg_B_7;
	logic [7:0] reg_C_7;
	logic [31:0] reg_D_7;
	logic reg_enable_7;
	logic reg_sign_C_7;
	logic [9:0] reg_addr_7;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_7 <= 32'd0;
			reg_B_7 <= 32'd0;
			reg_C_7 <= 8'd0;
			reg_D_7 <= 32'd0;
			reg_enable_7 <= 1'b0;
			reg_sign_C_7 <= 1'b0;
			reg_addr_7 <= 10'd0;
		end
		else begin
			reg_A_7 <= reg_A_6;
			reg_B_7 <= reg_B_6;
			reg_C_7 <= {reg_C_6, wire_C_6};
			reg_D_7 <= wire_D_6;
			reg_enable_7 <= reg_enable_6;
			reg_sign_C_7 <= reg_sign_C_6;
			reg_addr_7 <= reg_addr_6;
		end
	end

	divide_unit du7(
		.A({reg_D_7[30:0], reg_A_7[7]}),
		.B(reg_B_7),
		.C(wire_C_7),
		.D(wire_D_7)
	);

	//8-th stage pipeline
	logic wire_C_8;
	logic [31:0] wire_D_8;
	logic [31:0] reg_A_8;
	logic [31:0] reg_B_8;
	logic [8:0] reg_C_8;
	logic [31:0] reg_D_8;
	logic reg_enable_8;
	logic reg_sign_C_8;
	logic [9:0] reg_addr_8;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_8 <= 32'd0;
			reg_B_8 <= 32'd0;
			reg_C_8 <= 9'd0;
			reg_D_8 <= 32'd0;
			reg_enable_8 <= 1'b0;
			reg_sign_C_8 <= 1'b0;
			reg_addr_8 <= 10'd0;
		end
		else begin
			reg_A_8 <= reg_A_7;
			reg_B_8 <= reg_B_7;
			reg_C_8 <= {reg_C_7, wire_C_7};
			reg_D_8 <= wire_D_7;
			reg_enable_8 <= reg_enable_7;
			reg_sign_C_8 <= reg_sign_C_7;
			reg_addr_8 <= reg_addr_7;
		end
	end

	divide_unit du8(
		.A({reg_D_8[30:0], reg_A_8[6]}),
		.B(reg_B_8),
		.C(wire_C_8),
		.D(wire_D_8)
	);

	//9-th stage pipeline
	logic wire_C_9;
	logic [31:0] wire_D_9;
	logic [31:0] reg_A_9;
	logic [31:0] reg_B_9;
	logic [9:0] reg_C_9;
	logic [31:0] reg_D_9;
	logic reg_enable_9;
	logic reg_sign_C_9;
	logic [9:0] reg_addr_9;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_9 <= 32'd0;
			reg_B_9 <= 32'd0;
			reg_C_9 <= 10'd0;
			reg_D_9 <= 32'd0;
			reg_enable_9 <= 1'b0;
			reg_sign_C_9 <= 1'b0;
			reg_addr_9 <= 10'd0;
		end
		else begin
			reg_A_9 <= reg_A_8;
			reg_B_9 <= reg_B_8;
			reg_C_9 <= {reg_C_8, wire_C_8};
			reg_D_9 <= wire_D_8;
			reg_enable_9 <= reg_enable_8;
			reg_sign_C_9 <= reg_sign_C_8;
			reg_addr_9 <= reg_addr_8;
		end
	end

	divide_unit du9(
		.A({reg_D_9[30:0], reg_A_9[5]}),
		.B(reg_B_9),
		.C(wire_C_9),
		.D(wire_D_9)
	);

	//10-th stage pipeline
	logic wire_C_10;
	logic [31:0] wire_D_10;
	logic [31:0] reg_A_10;
	logic [31:0] reg_B_10;
	logic [10:0] reg_C_10;
	logic [31:0] reg_D_10;
	logic reg_enable_10;
	logic reg_sign_C_10;
	logic [9:0] reg_addr_10;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_10 <= 32'd0;
			reg_B_10 <= 32'd0;
			reg_C_10 <= 11'd0;
			reg_D_10 <= 32'd0;
			reg_enable_10 <= 1'b0;
			reg_sign_C_10 <= 1'b0;
			reg_addr_10 <= 10'd0;
		end
		else begin
			reg_A_10 <= reg_A_9;
			reg_B_10 <= reg_B_9;
			reg_C_10 <= {reg_C_9, wire_C_9};
			reg_D_10 <= wire_D_9;
			reg_enable_10 <= reg_enable_9;
			reg_sign_C_10 <= reg_sign_C_9;
			reg_addr_10 <= reg_addr_9;
		end
	end

	divide_unit du10(
		.A({reg_D_10[30:0], reg_A_10[4]}),
		.B(reg_B_10),
		.C(wire_C_10),
		.D(wire_D_10)
	);

	//11-th stage pipeline
	logic wire_C_11;
	logic [31:0] wire_D_11;
	logic [31:0] reg_A_11;
	logic [31:0] reg_B_11;
	logic [11:0] reg_C_11;
	logic [31:0] reg_D_11;
	logic reg_enable_11;
	logic reg_sign_C_11;
	logic [9:0] reg_addr_11;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_11 <= 32'd0;
			reg_B_11 <= 32'd0;
			reg_C_11 <= 12'd0;
			reg_D_11 <= 32'd0;
			reg_enable_11 <= 1'b0;
			reg_sign_C_11 <= 1'b0;
			reg_addr_11 <= 10'd0;
		end
		else begin
			reg_A_11 <= reg_A_10;
			reg_B_11 <= reg_B_10;
			reg_C_11 <= {reg_C_10, wire_C_10};
			reg_D_11 <= wire_D_10;
			reg_enable_11 <= reg_enable_10;
			reg_sign_C_11 <= reg_sign_C_10;
			reg_addr_11 <= reg_addr_10;
		end
	end

	divide_unit du11(
		.A({reg_D_11[30:0], reg_A_11[3]}),
		.B(reg_B_11),
		.C(wire_C_11),
		.D(wire_D_11)
	);

	//12-th stage pipeline
	logic wire_C_12;
	logic [31:0] wire_D_12;
	logic [31:0] reg_A_12;
	logic [31:0] reg_B_12;
	logic [12:0] reg_C_12;
	logic [31:0] reg_D_12;
	logic reg_enable_12;
	logic reg_sign_C_12;
	logic [9:0] reg_addr_12;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_12 <= 32'd0;
			reg_B_12 <= 32'd0;
			reg_C_12 <= 13'd0;
			reg_D_12 <= 32'd0;
			reg_enable_12 <= 1'b0;
			reg_sign_C_12 <= 1'b0;
			reg_addr_12 <= 10'd0;
		end
		else begin
			reg_A_12 <= reg_A_11;
			reg_B_12 <= reg_B_11;
			reg_C_12 <= {reg_C_11, wire_C_11};
			reg_D_12 <= wire_D_11;
			reg_enable_12 <= reg_enable_11;
			reg_sign_C_12 <= reg_sign_C_11;
			reg_addr_12 <= reg_addr_11;
		end
	end

	divide_unit du12(
		.A({reg_D_12[30:0], reg_A_12[2]}),
		.B(reg_B_12),
		.C(wire_C_12),
		.D(wire_D_12)
	);

	//13-th stage pipeline
	logic wire_C_13;
	logic [31:0] wire_D_13;
	logic [31:0] reg_A_13;
	logic [31:0] reg_B_13;
	logic [13:0] reg_C_13;
	logic [31:0] reg_D_13;
	logic reg_enable_13;
	logic reg_sign_C_13;
	logic [9:0] reg_addr_13;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_13 <= 32'd0;
			reg_B_13 <= 32'd0;
			reg_C_13 <= 14'd0;
			reg_D_13 <= 32'd0;
			reg_enable_13 <= 1'b0;
			reg_sign_C_13 <= 1'b0;
			reg_addr_13 <= 10'd0;
		end
		else begin
			reg_A_13 <= reg_A_12;
			reg_B_13 <= reg_B_12;
			reg_C_13 <= {reg_C_12, wire_C_12};
			reg_D_13 <= wire_D_12;
			reg_enable_13 <= reg_enable_12;
			reg_sign_C_13 <= reg_sign_C_12;
			reg_addr_13 <= reg_addr_12;
		end
	end

	divide_unit du13(
		.A({reg_D_13[30:0], reg_A_13[1]}),
		.B(reg_B_13),
		.C(wire_C_13),
		.D(wire_D_13)
	);

	//14-th stage pipeline
	logic wire_C_14;
	logic [31:0] wire_D_14;
	logic [31:0] reg_A_14;
	logic [31:0] reg_B_14;
	logic [14:0] reg_C_14;
	logic [31:0] reg_D_14;
	logic reg_enable_14;
	logic reg_sign_C_14;
	logic [9:0] reg_addr_14;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_14 <= 32'd0;
			reg_B_14 <= 32'd0;
			reg_C_14 <= 15'd0;
			reg_D_14 <= 32'd0;
			reg_enable_14 <= 1'b0;
			reg_sign_C_14 <= 1'b0;
			reg_addr_14 <= 10'd0;
		end
		else begin
			reg_A_14 <= reg_A_13;
			reg_B_14 <= reg_B_13;
			reg_C_14 <= {reg_C_13, wire_C_13};
			reg_D_14 <= wire_D_13;
			reg_enable_14 <= reg_enable_13;
			reg_sign_C_14 <= reg_sign_C_13;
			reg_addr_14 <= reg_addr_13;
		end
	end

	divide_unit du14(
		.A({reg_D_14[30:0], reg_A_14[0]}),
		.B(reg_B_14),
		.C(wire_C_14),
		.D(wire_D_14)
	);

	//15-th stage pipeline
	logic wire_C_15;
	logic [31:0] wire_D_15;
	logic [31:0] reg_A_15;
	logic [31:0] reg_B_15;
	logic [15:0] reg_C_15;
	logic [31:0] reg_D_15;
	logic reg_enable_15;
	logic reg_sign_C_15;
	logic [9:0] reg_addr_15;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_15 <= 32'd0;
			reg_B_15 <= 32'd0;
			reg_C_15 <= 16'd0;
			reg_D_15 <= 32'd0;
			reg_enable_15 <= 1'b0;
			reg_sign_C_15 <= 1'b0;
			reg_addr_15 <= 10'd0;
		end
		else begin
			reg_A_15 <= reg_A_14;
			reg_B_15 <= reg_B_14;
			reg_C_15 <= {reg_C_14, wire_C_14};
			reg_D_15 <= wire_D_14;
			reg_enable_15 <= reg_enable_14;
			reg_sign_C_15 <= reg_sign_C_14;
			reg_addr_15 <= reg_addr_14;
		end
	end

	divide_unit du15(
		.A({reg_D_15[30:0], 1'b0}),
		.B(reg_B_15),
		.C(wire_C_15),
		.D(wire_D_15)
	);

	//16-th stage pipeline
	logic wire_C_16;
	logic [31:0] wire_D_16;
	logic [31:0] reg_A_16;
	logic [31:0] reg_B_16;
	logic [16:0] reg_C_16;
	logic [31:0] reg_D_16;
	logic reg_enable_16;
	logic reg_sign_C_16;
	logic [9:0] reg_addr_16;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_16 <= 32'd0;
			reg_B_16 <= 32'd0;
			reg_C_16 <= 17'd0;
			reg_D_16 <= 32'd0;
			reg_enable_16 <= 1'b0;
			reg_sign_C_16 <= 1'b0;
			reg_addr_16 <= 10'd0;
		end
		else begin
			reg_A_16 <= reg_A_15;
			reg_B_16 <= reg_B_15;
			reg_C_16 <= {reg_C_15, wire_C_15};
			reg_D_16 <= wire_D_15;
			reg_enable_16 <= reg_enable_15;
			reg_sign_C_16 <= reg_sign_C_15;
			reg_addr_16 <= reg_addr_15;
		end
	end

	divide_unit du16(
		.A({reg_D_16[30:0], 1'b0}),
		.B(reg_B_16),
		.C(wire_C_16),
		.D(wire_D_16)
	);

	//17-th stage pipeline
	logic wire_C_17;
	logic [31:0] wire_D_17;
	logic [31:0] reg_A_17;
	logic [31:0] reg_B_17;
	logic [17:0] reg_C_17;
	logic [31:0] reg_D_17;
	logic reg_enable_17;
	logic reg_sign_C_17;
	logic [9:0] reg_addr_17;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_17 <= 32'd0;
			reg_B_17 <= 32'd0;
			reg_C_17 <= 18'd0;
			reg_D_17 <= 32'd0;
			reg_enable_17 <= 1'b0;
			reg_sign_C_17 <= 1'b0;
			reg_addr_17 <= 10'd0;
		end
		else begin
			reg_A_17 <= reg_A_16;
			reg_B_17 <= reg_B_16;
			reg_C_17 <= {reg_C_16, wire_C_16};
			reg_D_17 <= wire_D_16;
			reg_enable_17 <= reg_enable_16;
			reg_sign_C_17 <= reg_sign_C_16;
			reg_addr_17 <= reg_addr_16;
		end
	end

	divide_unit du17(
		.A({reg_D_17[30:0], 1'b0}),
		.B(reg_B_17),
		.C(wire_C_17),
		.D(wire_D_17)
	);

	//18-th stage pipeline
	logic wire_C_18;
	logic [31:0] wire_D_18;
	logic [31:0] reg_A_18;
	logic [31:0] reg_B_18;
	logic [18:0] reg_C_18;
	logic [31:0] reg_D_18;
	logic reg_enable_18;
	logic reg_sign_C_18;
	logic [9:0] reg_addr_18;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_18 <= 32'd0;
			reg_B_18 <= 32'd0;
			reg_C_18 <= 19'd0;
			reg_D_18 <= 32'd0;
			reg_enable_18 <= 1'b0;
			reg_sign_C_18 <= 1'b0;
			reg_addr_18 <= 10'd0;
		end
		else begin
			reg_A_18 <= reg_A_17;
			reg_B_18 <= reg_B_17;
			reg_C_18 <= {reg_C_17, wire_C_17};
			reg_D_18 <= wire_D_17;
			reg_enable_18 <= reg_enable_17;
			reg_sign_C_18 <= reg_sign_C_17;
			reg_addr_18 <= reg_addr_17;
		end
	end

	divide_unit du18(
		.A({reg_D_18[30:0], 1'b0}),
		.B(reg_B_18),
		.C(wire_C_18),
		.D(wire_D_18)
	);

	//19-th stage pipeline
	logic wire_C_19;
	logic [31:0] wire_D_19;
	logic [31:0] reg_A_19;
	logic [31:0] reg_B_19;
	logic [19:0] reg_C_19;
	logic [31:0] reg_D_19;
	logic reg_enable_19;
	logic reg_sign_C_19;
	logic [9:0] reg_addr_19;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_19 <= 32'd0;
			reg_B_19 <= 32'd0;
			reg_C_19 <= 20'd0;
			reg_D_19 <= 32'd0;
			reg_enable_19 <= 1'b0;
			reg_sign_C_19 <= 1'b0;
			reg_addr_19 <= 10'd0;
		end
		else begin
			reg_A_19 <= reg_A_18;
			reg_B_19 <= reg_B_18;
			reg_C_19 <= {reg_C_18, wire_C_18};
			reg_D_19 <= wire_D_18;
			reg_enable_19 <= reg_enable_18;
			reg_sign_C_19 <= reg_sign_C_18;
			reg_addr_19 <= reg_addr_18;
		end
	end

	divide_unit du19(
		.A({reg_D_19[30:0], 1'b0}),
		.B(reg_B_19),
		.C(wire_C_19),
		.D(wire_D_19)
	);

	//20-th stage pipeline
	logic wire_C_20;
	logic [31:0] wire_D_20;
	logic [31:0] reg_A_20;
	logic [31:0] reg_B_20;
	logic [20:0] reg_C_20;
	logic [31:0] reg_D_20;
	logic reg_enable_20;
	logic reg_sign_C_20;
	logic [9:0] reg_addr_20;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_20 <= 32'd0;
			reg_B_20 <= 32'd0;
			reg_C_20 <= 21'd0;
			reg_D_20 <= 32'd0;
			reg_enable_20 <= 1'b0;
			reg_sign_C_20 <= 1'b0;
			reg_addr_20 <= 10'd0;
		end
		else begin
			reg_A_20 <= reg_A_19;
			reg_B_20 <= reg_B_19;
			reg_C_20 <= {reg_C_19, wire_C_19};
			reg_D_20 <= wire_D_19;
			reg_enable_20 <= reg_enable_19;
			reg_sign_C_20 <= reg_sign_C_19;
			reg_addr_20 <= reg_addr_19;
		end
	end

	divide_unit du20(
		.A({reg_D_20[30:0], 1'b0}),
		.B(reg_B_20),
		.C(wire_C_20),
		.D(wire_D_20)
	);

	//21-th stage pipeline
	logic wire_C_21;
	logic [31:0] wire_D_21;
	logic [31:0] reg_A_21;
	logic [31:0] reg_B_21;
	logic [21:0] reg_C_21;
	logic [31:0] reg_D_21;
	logic reg_enable_21;
	logic reg_sign_C_21;
	logic [9:0] reg_addr_21;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_21 <= 32'd0;
			reg_B_21 <= 32'd0;
			reg_C_21 <= 22'd0;
			reg_D_21 <= 32'd0;
			reg_enable_21 <= 1'b0;
			reg_sign_C_21 <= 1'b0;
			reg_addr_21 <= 10'd0;
		end
		else begin
			reg_A_21 <= reg_A_20;
			reg_B_21 <= reg_B_20;
			reg_C_21 <= {reg_C_20, wire_C_20};
			reg_D_21 <= wire_D_20;
			reg_enable_21 <= reg_enable_20;
			reg_sign_C_21 <= reg_sign_C_20;
			reg_addr_21 <= reg_addr_20;
		end
	end

	divide_unit du21(
		.A({reg_D_21[30:0], 1'b0}),
		.B(reg_B_21),
		.C(wire_C_21),
		.D(wire_D_21)
	);

	//22-th stage pipeline
	logic wire_C_22;
	logic [31:0] wire_D_22;
	logic [31:0] reg_A_22;
	logic [31:0] reg_B_22;
	logic [22:0] reg_C_22;
	logic [31:0] reg_D_22;
	logic reg_enable_22;
	logic reg_sign_C_22;
	logic [9:0] reg_addr_22;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_22 <= 32'd0;
			reg_B_22 <= 32'd0;
			reg_C_22 <= 23'd0;
			reg_D_22 <= 32'd0;
			reg_enable_22 <= 1'b0;
			reg_sign_C_22 <= 1'b0;
			reg_addr_22 <= 10'd0;
		end
		else begin
			reg_A_22 <= reg_A_21;
			reg_B_22 <= reg_B_21;
			reg_C_22 <= {reg_C_21, wire_C_21};
			reg_D_22 <= wire_D_21;
			reg_enable_22 <= reg_enable_21;
			reg_sign_C_22 <= reg_sign_C_21;
			reg_addr_22 <= reg_addr_21;
		end
	end

	divide_unit du22(
		.A({reg_D_22[30:0], 1'b0}),
		.B(reg_B_22),
		.C(wire_C_22),
		.D(wire_D_22)
	);

	//23-th stage pipeline
	logic wire_C_23;
	logic [31:0] wire_D_23;
	logic [31:0] reg_A_23;
	logic [31:0] reg_B_23;
	logic [23:0] reg_C_23;
	logic [31:0] reg_D_23;
	logic reg_enable_23;
	logic reg_sign_C_23;
	logic [9:0] reg_addr_23;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_23 <= 32'd0;
			reg_B_23 <= 32'd0;
			reg_C_23 <= 24'd0;
			reg_D_23 <= 32'd0;
			reg_enable_23 <= 1'b0;
			reg_sign_C_23 <= 1'b0;
			reg_addr_23 <= 10'd0;
		end
		else begin
			reg_A_23 <= reg_A_22;
			reg_B_23 <= reg_B_22;
			reg_C_23 <= {reg_C_22, wire_C_22};
			reg_D_23 <= wire_D_22;
			reg_enable_23 <= reg_enable_22;
			reg_sign_C_23 <= reg_sign_C_22;
			reg_addr_23 <= reg_addr_22;
		end
	end

	divide_unit du23(
		.A({reg_D_23[30:0], 1'b0}),
		.B(reg_B_23),
		.C(wire_C_23),
		.D(wire_D_23)
	);

	//24-th stage pipeline
	logic wire_C_24;
	logic [31:0] wire_D_24;
	logic [31:0] reg_A_24;
	logic [31:0] reg_B_24;
	logic [24:0] reg_C_24;
	logic [31:0] reg_D_24;
	logic reg_enable_24;
	logic reg_sign_C_24;
	logic [9:0] reg_addr_24;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_24 <= 32'd0;
			reg_B_24 <= 32'd0;
			reg_C_24 <= 25'd0;
			reg_D_24 <= 32'd0;
			reg_enable_24 <= 1'b0;
			reg_sign_C_24 <= 1'b0;
			reg_addr_24 <= 10'd0;
		end
		else begin
			reg_A_24 <= reg_A_23;
			reg_B_24 <= reg_B_23;
			reg_C_24 <= {reg_C_23, wire_C_23};
			reg_D_24 <= wire_D_23;
			reg_enable_24 <= reg_enable_23;
			reg_sign_C_24 <= reg_sign_C_23;
			reg_addr_24 <= reg_addr_23;
		end
	end

	divide_unit du24(
		.A({reg_D_24[30:0], 1'b0}),
		.B(reg_B_24),
		.C(wire_C_24),
		.D(wire_D_24)
	);

	//25-th stage pipeline
	logic wire_C_25;
	logic [31:0] wire_D_25;
	logic [31:0] reg_A_25;
	logic [31:0] reg_B_25;
	logic [25:0] reg_C_25;
	logic [31:0] reg_D_25;
	logic reg_enable_25;
	logic reg_sign_C_25;
	logic [9:0] reg_addr_25;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_25 <= 32'd0;
			reg_B_25 <= 32'd0;
			reg_C_25 <= 26'd0;
			reg_D_25 <= 32'd0;
			reg_enable_25 <= 1'b0;
			reg_sign_C_25 <= 1'b0;
			reg_addr_25 <= 10'd0;
		end
		else begin
			reg_A_25 <= reg_A_24;
			reg_B_25 <= reg_B_24;
			reg_C_25 <= {reg_C_24, wire_C_24};
			reg_D_25 <= wire_D_24;
			reg_enable_25 <= reg_enable_24;
			reg_sign_C_25 <= reg_sign_C_24;
			reg_addr_25 <= reg_addr_24;
		end
	end

	divide_unit du25(
		.A({reg_D_25[30:0], 1'b0}),
		.B(reg_B_25),
		.C(wire_C_25),
		.D(wire_D_25)
	);

	//26-th stage pipeline
	logic wire_C_26;
	logic [31:0] wire_D_26;
	logic [31:0] reg_A_26;
	logic [31:0] reg_B_26;
	logic [26:0] reg_C_26;
	logic [31:0] reg_D_26;
	logic reg_enable_26;
	logic reg_sign_C_26;
	logic [9:0] reg_addr_26;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_26 <= 32'd0;
			reg_B_26 <= 32'd0;
			reg_C_26 <= 27'd0;
			reg_D_26 <= 32'd0;
			reg_enable_26 <= 1'b0;
			reg_sign_C_26 <= 1'b0;
			reg_addr_26 <= 10'd0;
		end
		else begin
			reg_A_26 <= reg_A_25;
			reg_B_26 <= reg_B_25;
			reg_C_26 <= {reg_C_25, wire_C_25};
			reg_D_26 <= wire_D_25;
			reg_enable_26 <= reg_enable_25;
			reg_sign_C_26 <= reg_sign_C_25;
			reg_addr_26 <= reg_addr_25;
		end
	end

	divide_unit du26(
		.A({reg_D_26[30:0], 1'b0}),
		.B(reg_B_26),
		.C(wire_C_26),
		.D(wire_D_26)
	);

	//27-th stage pipeline
	logic wire_C_27;
	logic [31:0] wire_D_27;
	logic [31:0] reg_A_27;
	logic [31:0] reg_B_27;
	logic [27:0] reg_C_27;
	logic [31:0] reg_D_27;
	logic reg_enable_27;
	logic reg_sign_C_27;
	logic [9:0] reg_addr_27;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_27 <= 32'd0;
			reg_B_27 <= 32'd0;
			reg_C_27 <= 28'd0;
			reg_D_27 <= 32'd0;
			reg_enable_27 <= 1'b0;
			reg_sign_C_27 <= 1'b0;
			reg_addr_27 <= 10'd0;
		end
		else begin
			reg_A_27 <= reg_A_26;
			reg_B_27 <= reg_B_26;
			reg_C_27 <= {reg_C_26, wire_C_26};
			reg_D_27 <= wire_D_26;
			reg_enable_27 <= reg_enable_26;
			reg_sign_C_27 <= reg_sign_C_26;
			reg_addr_27 <= reg_addr_26;
		end
	end

	divide_unit du27(
		.A({reg_D_27[30:0], 1'b0}),
		.B(reg_B_27),
		.C(wire_C_27),
		.D(wire_D_27)
	);

	//28-th stage pipeline
	logic wire_C_28;
	logic [31:0] wire_D_28;
	logic [31:0] reg_A_28;
	logic [31:0] reg_B_28;
	logic [28:0] reg_C_28;
	logic [31:0] reg_D_28;
	logic reg_enable_28;
	logic reg_sign_C_28;
	logic [9:0] reg_addr_28;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_28 <= 32'd0;
			reg_B_28 <= 32'd0;
			reg_C_28 <= 29'd0;
			reg_D_28 <= 32'd0;
			reg_enable_28 <= 1'b0;
			reg_sign_C_28 <= 1'b0;
			reg_addr_28 <= 10'd0;
		end
		else begin
			reg_A_28 <= reg_A_27;
			reg_B_28 <= reg_B_27;
			reg_C_28 <= {reg_C_27, wire_C_27};
			reg_D_28 <= wire_D_27;
			reg_enable_28 <= reg_enable_27;
			reg_sign_C_28 <= reg_sign_C_27;
			reg_addr_28 <= reg_addr_27;
		end
	end

	divide_unit du28(
		.A({reg_D_28[30:0], 1'b0}),
		.B(reg_B_28),
		.C(wire_C_28),
		.D(wire_D_28)
	);

	//29-th stage pipeline
	logic wire_C_29;
	logic [31:0] wire_D_29;
	logic [31:0] reg_A_29;
	logic [31:0] reg_B_29;
	logic [29:0] reg_C_29;
	logic [31:0] reg_D_29;
	logic reg_enable_29;
	logic reg_sign_C_29;
	logic [9:0] reg_addr_29;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_29 <= 32'd0;
			reg_B_29 <= 32'd0;
			reg_C_29 <= 30'd0;
			reg_D_29 <= 32'd0;
			reg_enable_29 <= 1'b0;
			reg_sign_C_29 <= 1'b0;
			reg_addr_29 <= 10'd0;
		end
		else begin
			reg_A_29 <= reg_A_28;
			reg_B_29 <= reg_B_28;
			reg_C_29 <= {reg_C_28, wire_C_28};
			reg_D_29 <= wire_D_28;
			reg_enable_29 <= reg_enable_28;
			reg_sign_C_29 <= reg_sign_C_28;
			reg_addr_29 <= reg_addr_28;
		end
	end

	divide_unit du29(
		.A({reg_D_29[30:0], 1'b0}),
		.B(reg_B_29),
		.C(wire_C_29),
		.D(wire_D_29)
	);

	//30-th stage pipeline
	logic wire_C_30;
	logic [31:0] wire_D_30;
	logic [31:0] reg_A_30;
	logic [31:0] reg_B_30;
	logic [30:0] reg_C_30;
	logic [31:0] reg_D_30;
	logic reg_enable_30;
	logic reg_sign_C_30;
	logic [9:0] reg_addr_30;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_30 <= 32'd0;
			reg_B_30 <= 32'd0;
			reg_C_30 <= 31'd0;
			reg_D_30 <= 32'd0;
			reg_enable_30 <= 1'b0;
			reg_sign_C_30 <= 1'b0;
			reg_addr_30 <= 10'd0;
		end
		else begin
			reg_A_30 <= reg_A_29;
			reg_B_30 <= reg_B_29;
			reg_C_30 <= {reg_C_29, wire_C_29};
			reg_D_30 <= wire_D_29;
			reg_enable_30 <= reg_enable_29;
			reg_sign_C_30 <= reg_sign_C_29;
			reg_addr_30 <= reg_addr_29;
		end
	end

	divide_unit du30(
		.A({reg_D_30[30:0], 1'b0}),
		.B(reg_B_30),
		.C(wire_C_30),
		.D(wire_D_30)
	);

	//31-th stage pipeline
	logic wire_C_31;
	logic [31:0] wire_D_31;
	logic [31:0] reg_A_31;
	logic [31:0] reg_B_31;
	logic [31:0] reg_C_31;
	logic [31:0] reg_D_31;
	logic reg_enable_31;
	logic reg_sign_C_31;
	logic [9:0] reg_addr_31;

	always_ff@(posedge clk or posedge rst)begin
		if(rst)begin
			reg_A_31 <= 32'd0;
			reg_B_31 <= 32'd0;
			reg_C_31 <= 32'd0;
			reg_D_31 <= 32'd0;
			reg_enable_31 <= 1'b0;
			reg_sign_C_31 <= 1'b0;
			reg_addr_31 <= 10'd0;
		end
		else begin
			reg_A_31 <= reg_A_30;
			reg_B_31 <= reg_B_30;
			reg_C_31 <= {reg_C_30, wire_C_30};
			reg_D_31 <= wire_D_30;
			reg_enable_31 <= reg_enable_30;
			reg_sign_C_31 <= reg_sign_C_30;
			reg_addr_31 <= reg_addr_30;
		end
	end
	
	logic [31:0] C_inverse;
	assign C_inverse = (reg_C_31 ^ 32'hffffffff) + 1;
	
	assign addr_out = reg_addr_31;
	assign enable_out = reg_enable_31;
	assign C = (reg_sign_C_31 == 1'b1) ? C_inverse : reg_C_31;
	//assign D = reg_D_31;

endmodule