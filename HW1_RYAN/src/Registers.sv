module Registers(
input logic clk,rst,
input logic RegWrite_ctr,
input logic [4:0]Read_Reg1,Read_Reg2,Write_Reg,
input logic [31:0]Write_Data,
output logic[31:0]Read_Data1,Read_Data2);
   
logic [31:0] Register [0:31];

///write reg 
always@(posedge clk or posedge rst)
  begin
    if(rst)begin
		Register[0]<=0;
		Register[1]<=0;
		Register[2]<=0;
		Register[3]<=0;
		Register[4]<=0;
		Register[5]<=0;
		Register[6]<=0;
		Register[7]<=0;
		Register[8]<=0;
		Register[9]<=0;
		Register[10]<=0;
		Register[11]<=0;
		Register[12]<=0;
		Register[13]<=0;
		Register[14]<=0;
		Register[15]<=0;
		Register[16]<=0;
		Register[17]<=0;
		Register[18]<=0;
		Register[19]<=0;
		Register[20]<=0;
		Register[21]<=0;
		Register[22]<=0;
		Register[23]<=0;
		Register[24]<=0;
		Register[25]<=0;
		Register[26]<=0;
		Register[27]<=0;
		Register[28]<=0;
		Register[29]<=0;
		Register[30]<=0;
		Register[31]<=0;
    end    
    else begin 
		if(RegWrite_ctr)begin
		  case(Write_Reg)
			5'd0:  Register[0]<=0;
			5'd1:  Register[1]<=Write_Data;
			5'd2:  Register[2]<=Write_Data;
			5'd3:  Register[3]<=Write_Data;
			5'd4:  Register[4]<=Write_Data;
			5'd5:  Register[5]<=Write_Data;
			5'd6:  Register[6]<=Write_Data;
			5'd7:  Register[7]<=Write_Data;
			5'd8:  Register[8]<=Write_Data;
			5'd9:  Register[9]<=Write_Data;
			5'd10: Register[10]<=Write_Data;
			5'd11: Register[11]<=Write_Data;
			5'd12: Register[12]<=Write_Data;
			5'd13: Register[13]<=Write_Data;
			5'd14: Register[14]<=Write_Data;
			5'd15: Register[15]<=Write_Data;
			5'd16: Register[16]<=Write_Data;
			5'd17: Register[17]<=Write_Data;
			5'd18: Register[18]<=Write_Data;
			5'd19: Register[19]<=Write_Data;
			5'd20: Register[20]<=Write_Data;
			5'd21: Register[21]<=Write_Data;
			5'd22: Register[22]<=Write_Data;
			5'd23: Register[23]<=Write_Data;
			5'd24: Register[24]<=Write_Data;
			5'd25: Register[25]<=Write_Data;
			5'd26: Register[26]<=Write_Data;
			5'd27: Register[27]<=Write_Data;
			5'd28: Register[28]<=Write_Data;
			5'd29: Register[29]<=Write_Data;
			5'd30: Register[30]<=Write_Data;
			5'd31: Register[31]<=Write_Data;
			/*default:begin
				Register[0] <=0;
				Register[1] <=Register[1];
				Register[2] <=Register[2];
				Register[3] <=Register[3];
				Register[4] <=Register[4];
				Register[5] <=Register[5];
				Register[6] <=Register[6];
				Register[7] <=Register[7];
				Register[8] <=Register[8];
				Register[9] <=Register[9];
				Register[10]<=Register[10];
				Register[11]<=Register[11];
				Register[12]<=Register[12];
				Register[13]<=Register[13];
				Register[14]<=Register[14];
				Register[15]<=Register[15];
				Register[16]<=Register[16];
				Register[17]<=Register[17];
				Register[18]<=Register[18];
				Register[19]<=Register[19];
				Register[20]<=Register[20];
				Register[21]<=Register[21];
				Register[22]<=Register[22];
				Register[23]<=Register[23];
				Register[24]<=Register[24];
				Register[25]<=Register[25];
				Register[26]<=Register[26];
				Register[27]<=Register[27];
				Register[28]<=Register[28];
				Register[29]<=Register[29];
				Register[30]<=Register[30];
				Register[31]<=Register[31];end  */                
		  endcase
		end
    end
  end
    
/////read reg

always@(*)///reg1
  begin
	/*case(Read_Reg1)
		5'd0:  Read_Data1=Register[0];
		5'd1:  Read_Data1=Register[1];
		5'd2:  Read_Data1=Register[2];
		5'd3:  Read_Data1=Register[3];
		5'd4:  Read_Data1=Register[4];
		5'd5:  Read_Data1=Register[5];
		5'd6:  Read_Data1=Register[6];
		5'd7:  Read_Data1=Register[7];
		5'd8:  Read_Data1=Register[8];
		5'd9:  Read_Data1=Register[9];
		5'd10: Read_Data1=Register[10];
		5'd11: Read_Data1=Register[11];
		5'd12: Read_Data1=Register[12];
		5'd13: Read_Data1=Register[13];
		5'd14: Read_Data1=Register[14];
		5'd15: Read_Data1=Register[15];
		5'd16: Read_Data1=Register[16];
		5'd17: Read_Data1=Register[17];
		5'd18: Read_Data1=Register[18];
		5'd19: Read_Data1=Register[19];
		5'd20: Read_Data1=Register[20];
		5'd21: Read_Data1=Register[21];
		5'd22: Read_Data1=Register[22];
		5'd23: Read_Data1=Register[23];
		5'd24: Read_Data1=Register[24];
		5'd25: Read_Data1=Register[25];
		5'd26: Read_Data1=Register[26];
		5'd27: Read_Data1=Register[27];
		5'd28: Read_Data1=Register[28];
		5'd29: Read_Data1=Register[29];
		5'd30: Read_Data1=Register[30];
		5'd31: Read_Data1=Register[31];
        //default:Read_Data1=32'd0;
    endcase*/
	  if((Read_Reg1 == Write_Reg )&& RegWrite_ctr)
	    Read_Data1=Write_Data;
	  else
		Read_Data1=Register[Read_Reg1];
  end
always@(*)///reg2
    begin
      /*case(Read_Reg2)
		5'd0:  Read_Data2=Register[0];
		5'd1:  Read_Data2=Register[1];
		5'd2:  Read_Data2=Register[2];
		5'd3:  Read_Data2=Register[3];
		5'd4:  Read_Data2=Register[4];
		5'd5:  Read_Data2=Register[5];
		5'd6:  Read_Data2=Register[6];
		5'd7:  Read_Data2=Register[7];
		5'd8:  Read_Data2=Register[8];
		5'd9:  Read_Data2=Register[9];
		5'd10: Read_Data2=Register[10];
		5'd11: Read_Data2=Register[11];
		5'd12: Read_Data2=Register[12];
		5'd13: Read_Data2=Register[13];
		5'd14: Read_Data2=Register[14];
		5'd15: Read_Data2=Register[15];
		5'd16: Read_Data2=Register[16];
		5'd17: Read_Data2=Register[17];
		5'd18: Read_Data2=Register[18];
		5'd19: Read_Data2=Register[19];
		5'd20: Read_Data2=Register[20];
		5'd21: Read_Data2=Register[21];
		5'd22: Read_Data2=Register[22];
		5'd23: Read_Data2=Register[23];
		5'd24: Read_Data2=Register[24];
		5'd25: Read_Data2=Register[25];
		5'd26: Read_Data2=Register[26];
		5'd27: Read_Data2=Register[27];
		5'd28: Read_Data2=Register[28];
		5'd29: Read_Data2=Register[29];
		5'd30: Read_Data2=Register[30];
		5'd31: Read_Data2=Register[31];
        //default:Read_Data2=32'd0;
      endcase*/
	  
	  if((Read_Reg2 == Write_Reg )&& RegWrite_ctr)
	    Read_Data2=Write_Data;
	  else
		Read_Data2=Register[Read_Reg2];
    end

endmodule
