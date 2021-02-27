
module ALU(
output logic [31:0]ALU_result,
output logic ALU_zero,
input [31:0]ALU_in1,ALU_in2,
input [3:0]ALU_ctr
    );
    
always@(*)  
  begin
    case(ALU_ctr)
      4'b0000:ALU_result=ALU_in1+ALU_in2; //add
      4'b0001:ALU_result=ALU_in1-ALU_in2; //sub
	  4'b0010:ALU_result=ALU_in1<<ALU_in2[4:0]; //sll 
      4'b0011:begin                      //SLT
          if($signed(ALU_in1)<$signed(ALU_in2)) ALU_result=1;
          else ALU_result=32'd0;end              	
      4'b0100:begin                      //SLTU
          if(ALU_in1<ALU_in2) ALU_result=1;
          else ALU_result=32'd0;end              	     		  
      4'b0101:ALU_result=ALU_in1^ALU_in2;    //XOR
      4'b0110:ALU_result=ALU_in1>>ALU_in2[4:0]; //SRL
      4'b0111:ALU_result=$signed(ALU_in1)>>>ALU_in2[4:0]; //SRA	  
      4'b1000:ALU_result=ALU_in1|ALU_in2;    //OR
      4'b1001:ALU_result=ALU_in1&ALU_in2; //AND  
	  4'b1010:begin                       //equl
          if(ALU_in1==ALU_in2) ALU_result=1;
          else ALU_result=32'd0;end 	  
      default:ALU_result=32'd0;      
    endcase
  end
    
always@(*)
  begin
    if(ALU_result==32'd0)
      ALU_zero=1'b1;
    else
      ALU_zero=1'b0;
  end  
    
    
    
    
    
    
    
    
    
    
    
    
    
    
endmodule
