module Control_unit(
output logic Jump,Branch,MemRead,
output logic [3:0]MemWrite,
output logic ALUSrc,RegWrite,LB,PC_Imm_ctr,JALR,branch_inv,
output logic [2:0]Imm_type_control,
output logic [1:0]ALUOP,rdSrc,
output logic ChipSel,
output logic SB,
input [2:0]funct3,
input [6:0]opcode,
input [1:0]Imm_last2_bit
    );
	
always@(*)
  begin
    case(opcode)
	  7'b0000011:begin //LW(I-type)
	    Imm_type_control=3'b001; //Imm-type 1:I,2:S,3:B,4:U,5:J
		Jump=1'b0;                  //if jump
		Branch=1'b0;                //if branch
		JALR=1'b0;                  //if JALR
		MemRead=1'b1;               //Data mem read enable 
		MemWrite=4'b1111;         //Data mem write enable
		ALUSrc=1'b1;                 //ALU second input from 1:Imm ,0: rs2
		RegWrite=1'b1;               //write data to rd enable
		ALUOP=2'b00;              //00:LW LB SW SB ,01:B-type ,10:otherwise
		rdSrc=2'b01;                //00:AlUout, 01:memout, 10:PC+4, 11:PC+Imm/Imm(by PC_Imm_ctr)
        if(funct3==3'b000)LB=1'b1;                	  //if LoadByte
		else LB=1'b0;
		PC_Imm_ctr=1'b0;              //1:PC+Imm ,0:Imm
        ChipSel=1'b1;                 //if MEM on
        branch_inv=1'b0;              //if beq inverse	
		SB=1'b0;		
		
	  end
	  7'b0100011:begin //SW
	    Imm_type_control=3'b010; //Imm-type 1:I,2:S,3:B,4:U,5:J
		Jump=1'b0;                  //if jump
		Branch=1'b0;                //if branch
		JALR=1'b0;                  //if JALR
		MemRead=1'b0;               //Data mem read enable 		
		if(funct3==3'b000)
		  SB=1'b1;
		else SB=1'b0;  //SW	
		MemWrite=4'b0000; 
		ALUSrc=1'b1;                 //ALU second  input from 1:Imm , 0: rs2
		RegWrite=1'b0;               //write data to rd enable
		ALUOP=2'b00;               //00:LW LB SW SB ,01:B-type ,10:otherwise
		rdSrc=2'b00;                //00:AlUout, 01:memout, 10:PC+4, 11:PC+Imm/Imm(by PC_Imm_ctr)
        LB=1'b0;                	  //if LoadByte
		PC_Imm_ctr=1'b0;              //1:PC+Imm ,0:Imm
        ChipSel=1'b1;                 //if MEM on	
		branch_inv=1'b0;              //if beq inverse		
	  end
	  7'b1100011:begin //B
	    Imm_type_control=3'b011; //Imm-type 1:I,2:S,3:B,4:U,5:J
		Jump=1'b0;                  //if jump
		Branch=1'b1;                //if branch
		JALR=1'b0;                  //if JALR
		MemRead=1'b0;               //Data mem read enable  
		MemWrite=4'b1111;               //Data mem write enable
		ALUSrc=1'b0;                 //ALU second  input from 1:Imm , 0: rs2
		RegWrite=1'b0;               //write data to rd enable
		ALUOP=2'b01;               //00:LW LB SW SB ,01:B-type ,10:otherwise
		rdSrc=2'b00;                //00:AlUout, 01:memout, 10:PC+4, 11:PC+Imm/Imm(by PC_Imm_ctr)
        LB=1'b0;                	  //if LoadByte
		PC_Imm_ctr=1'b0;              //1:PC+Imm ,0:Imm
        ChipSel=1'b0;                 //if MEM on
        case(funct3)
		3'b000:branch_inv=1'b1;
		3'b001:branch_inv=1'b0;
		3'b100:branch_inv=1'b1;
		3'b101:branch_inv=1'b0;
		3'b110:branch_inv=1'b1;
		3'b111:branch_inv=1'b0;
		default:branch_inv=1'b1;
        endcase	
		SB=1'b0;
	  end
	  7'b0110011:begin //R
	    Imm_type_control=3'b111; //Imm-type 1:I,2:S,3:B,4:U,5:J
		Jump=1'b0;                  //if jump
		Branch=1'b0;                //if branch
		JALR=1'b0;                  //if JALR
		MemRead=1'b0;               //Data mem read enable  
		MemWrite=4'b1111;               //Data mem write enable
		ALUSrc=1'b0;                 //ALU second  input from 1:Imm , 0: rs2
		RegWrite=1'b1;               //write data to rd enable
		ALUOP=2'b10;               //00:LW LB SW SB ,01:B-type ,10:otherwise
		rdSrc=2'b00;                //00:AlUout, 01:memout, 10:PC+4, 11:PC+Imm/Imm(by PC_Imm_ctr)
        LB=1'b0;                	  //if LoadByte
		PC_Imm_ctr=1'b0;              //1:PC+Imm ,0:Imm
        ChipSel=1'b0;                 //if MEM on	
		branch_inv=1'b0;              //if beq inverse
		SB=1'b0;
	  end
	  7'b0010011:begin //I-type without LW LB JALR
	    Imm_type_control=3'b001; //Imm-type 1:I,2:S,3:B,4:U,5:J
		Jump=1'b0;                  //if jump
		Branch=1'b0;                //if branch
		JALR=1'b0;                  //if JALR
		MemRead=1'b0;               //Data mem read enable 
		MemWrite=4'b1111;               //Data mem write enable
		ALUSrc=1'b1;                 //ALU second  input from 1:Imm , 0: rs2
		RegWrite=1'b1;               //write data to rd enable
		ALUOP=2'b11;               //00:LW LB SW SB ,01:B-type ,10:otherwise
		rdSrc=2'b00;                //00:AlUout, 01:memout, 10:PC+4, 11:PC+Imm/Imm(by PC_Imm_ctr)
        LB=1'b0;                	  //if LoadByte
		PC_Imm_ctr=1'b0;              //1:PC+Imm ,0:Imm	
        ChipSel=1'b0;                 //if MEM on
		branch_inv=1'b0;              //if beq inverse
		SB=1'b0;
	  end
	  7'b1100111:begin //JALR (I-type)
	    Imm_type_control=3'b001; //Imm-type 1:I,2:S,3:B,4:U,5:J
		Jump=1'b0;                  //if jump
		Branch=1'b0;                //if branch
		JALR=1'b1;                  //if JALR
		MemRead=1'b0;               //Data mem read enable 
		MemWrite=4'b1111;               //Data mem write enable
		ALUSrc=1'b1;                 //ALU second  input from 1:Imm , 0: rs2
		RegWrite=1'b1;               //write data to rd enable
		ALUOP=2'b00;               //00:LW LB SW SB JALR ,01:B-type ,10:otherwise	
		rdSrc=2'b10;                //00:AlUout, 01:memout, 10:PC+4, 11:PC+Imm/Imm(by PC_Imm_ctr)
        LB=1'b0;                	  //if LoadByte
		PC_Imm_ctr=1'b0;              //1:PC+Imm ,0:Imm
        ChipSel=1'b0;                 //if MEM on	
		branch_inv=1'b0;              //if beq inverse	
		SB=1'b0;
	  end		
	  7'b0010111:begin //AUIPC (U-type)
	    Imm_type_control=3'b100; //Imm-type 1:I,2:S,3:B,4:U,5:J
		Jump=1'b0;                  //if jump
		Branch=1'b0;                //if branch
		JALR=1'b0;                  //if JALR
		MemRead=1'b0;               //Data mem read enable 
		MemWrite=4'b1111;               //Data mem write enable
		ALUSrc=1'b0;                 //ALU second  input from 1:Imm , 0: rs2
		RegWrite=1'b1;               //write data to rd enable
		ALUOP=2'b10;               //00:LW LB SW SB ,01:B-type ,10:otherwise	
		rdSrc=2'b11;                //00:AlUout, 01:memout, 10:PC+4, 11:PC+Imm/Imm(by PC_Imm_ctr)
        LB=1'b0;                	  //if LoadByte
		PC_Imm_ctr=1'b1;              //1:PC+Imm ,0:Imm
        ChipSel=1'b0;                 //if MEM on	
		branch_inv=1'b0;              //if beq inverse	
		SB=1'b0;
	  end
	  7'b0110111:begin //LUI (U-type)
	    Imm_type_control=3'b100; //Imm-type 1:I,2:S,3:B,4:U,5:J
		Jump=1'b0;                  //if jump
		Branch=1'b0;                //if branch
		JALR=1'b0;                  //if JALR
		MemRead=1'b0;               //Data mem read enable  
		MemWrite=4'b1111;               //Data mem write enable
		ALUSrc=1'b0;                 //ALU second  input from 1:Imm , 0: rs2
		RegWrite=1'b1;               //write data to rd enable
		ALUOP=2'b10;               //00:LW LB SW SB ,01:B-type ,10:otherwise	
		rdSrc=2'b11;                //00:AlUout, 01:memout, 10:PC+4, 11:PC+Imm/Imm(by PC_Imm_ctr)
        LB=1'b0;                	  //if LoadByte
		PC_Imm_ctr=1'b0;              //1:PC+Imm ,0:Imm
        ChipSel=1'b0;                 //if MEM on	
		branch_inv=1'b0;              //if beq inverse	
		SB=1'b0;
	  end
	  7'b1101111:begin //J
	    Imm_type_control=3'b101; //Imm-type 1:I,2:S,3:B,4:U,5:J
		Jump=1'b1;                  //if jump
		Branch=1'b0;                //if branch
		JALR=1'b0;                  //if JALR
		MemRead=1'b0;               //Data mem read enable  
		MemWrite=4'b1111;               //Data mem write enable
		ALUSrc=1'b0;                 //ALU second  input from 1:Imm , 0: rs2
		RegWrite=1'b1;               //write data to rd enable
		ALUOP=2'b10;               //00:LW LB SW SB ,01:B-type ,10:otherwise
		rdSrc=2'b10;                //00:AlUout, 01:memout, 10:PC+4, 11:PC+Imm/Imm(by PC_Imm_ctr)
        LB=1'b0;                	  //if LoadByte
		PC_Imm_ctr=1'b1;              //1:PC+Imm ,0:Imm
        ChipSel=1'b0;                 //if MEM on	
		branch_inv=1'b0;              //if beq inverse		
		SB=1'b0;
	  end	  
	  default:begin //
	    Imm_type_control=3'b111; //Imm-type 1:I,2:S,3:B,4:U,5:J
		Jump=1'b0;                  //if jump
		Branch=1'b0;                //if branch
		JALR=1'b0;                  //if JALR
		MemRead=1'b0;               //Data mem read enable  
		MemWrite=4'b1111;               //Data mem write enable
		ALUSrc=1'b0;                 //ALU second  input from 1:Imm , 0: rs2
		RegWrite=1'b0;               //write data to rd enable
		ALUOP=2'b11;               //00:LW LB SW SB ,01:B-type ,10:otherwise
		rdSrc=2'b00;                //00:AlUout, 01:memout, 10:PC+4, 11:PC+Imm/Imm(by PC_Imm_ctr)
        LB=1'b0;                	  //if LoadByte
		PC_Imm_ctr=1'b0;              //1:PC+Imm ,0:Imm
        ChipSel=1'b0;                 //if MEM on	
		branch_inv=1'b0;              //if beq inverse
		SB=1'b0;
	  end
	endcase
  end
endmodule  