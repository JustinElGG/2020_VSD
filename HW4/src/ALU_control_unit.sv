module ALU_control_unit(
output logic [3:0]ALU_ctr,
input [1:0]ALUop,
input [2:0]funct3,
input [6:0]funct7
    );

always@(*)
  begin
   if(ALUop==2'b00)
     begin
       ALU_ctr=4'b0000; //LW LB SW SB by add
     end
   else if(ALUop==2'b01)
     begin
       case(funct3)
	     3'b000: ALU_ctr=4'b1010; //BEQ by equl
		 3'b001: ALU_ctr=4'b1010; //BNE by equl
		 3'b100: ALU_ctr=4'b0011; //BLT by slt
		 3'b101: ALU_ctr=4'b0011; //BGE by slt
		 3'b110: ALU_ctr=4'b0100; //BLT by sltu
		 3'b111: ALU_ctr=4'b0100; //BGE by sltu
		 default:ALU_ctr=4'b1111;
	   endcase
     end
   else if(ALUop==2'b10) //R-type
     begin
       case(funct3)
	     3'b000: begin
		   if(funct7==7'b0000000) ALU_ctr=4'b0000; //add
		   else ALU_ctr=4'b0001; end //sub
		 3'b001: ALU_ctr=4'b0010; //sll
		 3'b010: ALU_ctr=4'b0011; //slt
		 3'b011: ALU_ctr=4'b0100; //sltu
		 3'b100: ALU_ctr=4'b0101; //xor
		 3'b101: begin
		   if(funct7==7'b0000000) ALU_ctr=4'b0110; //srl
		   else ALU_ctr=4'b0111; end //sra
		 3'b110: ALU_ctr=4'b1000; //or
		 3'b111: ALU_ctr=4'b1001; //and		
		 //default:ALU_ctr=4'b1111;
	   endcase      
     end
	else if(ALUop==2'b11) //I-type
     begin
       case(funct3)
	     3'b000: ALU_ctr=4'b0000; //add	   
		 3'b001: ALU_ctr=4'b0010; //sll
		 3'b010: ALU_ctr=4'b0011; //slt
		 3'b011: ALU_ctr=4'b0100; //sltu
		 3'b100: ALU_ctr=4'b0101; //xor
		 3'b101: begin
		   if(funct7==7'b0000000) ALU_ctr=4'b0110; //srl
		   else ALU_ctr=4'b0111; end //sra
		 3'b110: ALU_ctr=4'b1000; //or
		 3'b111: ALU_ctr=4'b1001; //and	
		// default:ALU_ctr=4'b1111;
	   endcase      
     end 
   else ALU_ctr=4'b1111;
  end
  endmodule