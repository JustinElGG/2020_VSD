`timescale 1ns/10ps
`include "defines.sv"

module ALU( input [`data_size-1:0]src1,
			input [`data_size-1:0]src2,
			input [3:0]OP, 
			input enable,
            output logic [`data_size-1:0]alu_result,
			output logic Overflow);
			
always_comb begin
    if(enable == 1'b1) begin
        case(OP)
		    `ADD: begin	//ADD
			    alu_result = src1+src2;
			    if((alu_result[31]==1 && src1[31]==0 && src2[31]==0) || (alu_result[31]==0 && src1[31]==1 && src2[31]==1)) Overflow = 1'b1;
			    else Overflow = 1'b0;
		    end

	    	`SUB: begin	//SUB
	    		alu_result = src1-src2;
	    		if((alu_result[31]==1 && src1[31]==0 && src2[31]==1) || (alu_result[31]==0 && src1[31]==1 && src2[31]==0)) Overflow = 1'b1;
	    		else Overflow = 1'b0;
	    	end
	    			
            `SLL: begin	//SLL
	    		alu_result = src1<<src2[4:0];
	    		Overflow = 1'b0;
	    	end
	    	
	    	`SLT: begin	//SLT
	    		alu_result = ($signed(src1)<$signed(src2)) ? 32'b1:32'b0;
	    		Overflow = 1'b0;
	    	end
            
	    	`SLTU: begin	//SLTU
	    		alu_result = (src1<src2) ? 32'b1:32'b0;
	    		Overflow = 1'b0;
	    	end
            
	    	`XOR: begin	//XOR
	    		alu_result = src1^src2;
	    		Overflow = 1'b0;
	    	end
            
	    	`SRL: begin	//SRL
	    		alu_result = src1>>src2[4:0];
	    		Overflow = 1'b0;
	    	end
            
	    	`SRA: begin	//SRA
	    		alu_result = $signed(src1)>>>src2[4:0];
	    		Overflow = 1'b0;
	    	end
            
	    	`OR: begin	//OR
	    		alu_result = src1|src2;
	    		Overflow = 1'b0;
	    	end
           
            `AND: begin	//AND
	    		alu_result = src1&src2;
	    		Overflow = 1'b0;
	    	end

	    	/*
            `ROTATE: begin	//ROTATE
	    		alu_result = {src1, src1}>>src2;
	    		Overflow = 1'b0;
	    	end
            */    

	    	default: begin
	    		alu_result = 32'b0;
	    		Overflow = 1'b0;
	    	end
        endcase
    end
    else begin
        alu_result = 32'b0;
        Overflow = 1'b0;
    end
end
endmodule
