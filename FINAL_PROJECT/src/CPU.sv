`include "Registers.sv"
`include "Control_unit.sv"
`include "ALU.sv"
`include "ALU_control_unit.sv"
`include "Imm_Gen.sv"
`include "Forward_unit.sv"
`include "Hazard_Detection.sv"
`include "CSR.sv"
`define IDLE 3'b000
`define WriteAddr 3'b001
`define WriteData 3'b010
`define WriteResp 3'b011
`define ReadAddr  3'b100
`define ReadData  3'b101
`define Buffer    3'b110


module CPU(
	output logic IM_CS,IM_OE,DM_CS,DM_OE,
	output logic [3:0]IM_WEB,DM_WEB,
	output logic [31:0]IM_addr,DM_addr,
	output logic [31:0]DM_Data_in,
	input clk,rst,
	input [31:0]IM_Data_out,DM_Data_out,
	input CPU_Ready, //wait r/w data from bus
	input [2:0] CS_M0,CS_M1,NS_M0,NS_M1,
	output logic [2:0]DM_type,IM_type,
	input interrupt
);

//////////////Declaration//////////////
//////////////IF stage//////////////
logic PCSrc,PC_start;
logic [31:0]PC_in1,PC_in_,PC_add4,PC_add_Imm,PC_in,PC,Imm_add_rs1,PC_delay1,PC_add4_delay1;
logic [31:0]PC_csr;
//////////////ID stage//////////////
logic [31:0]ID_PC_add4,ID_PC,ID_Instruction;
logic [31:0]ID_Read_Data1,ID_Read_Data2;
logic [31:0]Write_Data;
logic [31:0]ID_Imm_out;
logic ID_Jimp,ID_Branch,ID_MemRead;
logic [2:0]ID_Imm_type_control;
logic ID_ALUSrc,ID_RegWrite,ID_PC_Imm_ctr,ID_JALR,ID_Chipsel,ID_branch_inv;
logic [1:0]ID_Store;
logic [2:0]ID_Load;
logic [1:0]ID_ALUOP,ID_rdSrc;
logic [3:0]ID_MemWrite;
logic [4:0]ID_rs1_addr,ID_rs2_addr;
logic stall,stall2;
logic[6:0]ID_OP,EX_OP;//debug	
//////////////EX stage//////////////
logic EX_Jump,EX_Branch,EX_MemRead;
logic EX_ALUSrc,EX_RegWrite,EX_PC_Imm_ctr,EX_JALR,EX_Chipsel,EX_branch_inv;
logic [2:0]EX_Load;
logic [1:0]EX_ALUOP,EX_rdSrc;
logic [3:0]EX_MemWrite;
logic [31:0]EX_Read_Data1,EX_Read_Data2;
logic [31:0]EX_Imm_out,EX_PC_add4,EX_PC;
logic [4:0]EX_rd_addr;
logic [31:0]EX_Instruction;
logic [2:0]EX_funct3;
logic [6:0]EX_funct7;
logic [31:0]EX_Imm_out_shift1,EX_PC_add_Imm;
logic [31:0]ALU_in1,ALU_in2,EX_ALU_result;
logic [3:0]ALU_ctr;
logic EX_ALU_zero;
logic [4:0]EX_rs1_addr,EX_rs2_addr;
logic [1:0]Forward_rs1,Forward_rs2;
logic [31:0]Imm_or_ReadData2;
logic EX_stall;
//////////////MEM stage//////////////
logic MEM_Jump,MEM_Branch,MEM_JALR,MEM_MemRead,MEM_Chipsel,MEM_branch_inv;
logic MEM_RegWrite,MEM_PC_Imm_ctr;
logic [2:0]MEM_Load;
logic [1:0]MEM_rdSrc;
logic [3:0]MEM_MemWrite;
logic [31:0]MEM_ALU_result,MEM_PC_add_Imm,MEM_PC_add4,MEM_Imm_out,MEM_Read_Data2;
logic MEM_ALU_zero;
logic [4:0]MEM_rd_addr;
logic [31:0]MEM_PC_add_Imm_or_Imm;
logic [31:0]MEM_DM_Data;
logic [31:0]MEM_forward;
logic MEM_stall;
logic [2:0]MEM_funct3;
//////////////WB stage//////////////
logic WB_RegWrite;
logic [1:0]WB_rdSrc;
logic [4:0]WB_rd_addr;
logic WB_MemRead;
logic [31:0]WB_PC_add4,WB_PC_add_Imm_or_Imm,WB_DM_Data_out,WB_ALU_result;
logic [31:0]DM_Data;
logic WB_stall;
logic stall_data;

logic wait_for_interrupt;
logic interrupt_taken, interrupt_taken1, interrupt_taken2;
logic interrupt_return, interrupt_return1, interrupt_return2;

///////////////////////////////////////
logic WB_flush,MEM_flush,flush_data;
logic flush;
logic [31:0] PC_delay2,PC_add4_delay2;

logic WAIT_MEM;
logic PC_valid;
always_comb begin
	if(~CPU_Ready || ~PC_valid) WAIT_MEM = 1'b1;
	else WAIT_MEM =1'b0;
end

//////////////IF stage//////////////

always_comb begin//mux2to1//branch or PC+4
	if(PCSrc) 
		PC_in1 = EX_PC_add_Imm;
	else  
		PC_in1 = PC_add4; 
end	
assign PC_add4 = PC + 32'd4;

always_ff @(posedge clk or posedge rst) begin
	if(rst) PC_valid<=1'b0;
	else PC_valid<=1'b1;
end

always_ff @(posedge clk or posedge rst) begin
	if(rst) interrupt_taken1<=1'b0;
	else if(CPU_Ready)interrupt_taken1<=interrupt_taken;
end

always_ff @(posedge clk or posedge rst) begin
	if(rst) interrupt_taken2<=1'b0;
	else if(CPU_Ready)interrupt_taken2<=interrupt_taken1;
end

always_ff @(posedge clk or posedge rst) begin
	if(rst) interrupt_return1<=1'b0;
	else if(CPU_Ready)interrupt_return1<=interrupt_return;
end

always_ff @(posedge clk or posedge rst) begin
	if(rst) interrupt_return2<=1'b0;
	else if(CPU_Ready)interrupt_return2<=interrupt_return1;
end

////////////////when interrupt, replace PC////////////////
/*
always_comb begin//select PC src
		case({EX_Jump,EX_JALR})   
			2'b00: PC_in_ = PC_in1;          //branch or PC+4
			2'b01: PC_in_ = Imm_add_rs1;     //JALR
			2'b10: PC_in_ = EX_PC_add_Imm;      //Jump
			default: PC_in_ = PC_in1;
		endcase
end
*/
always_comb begin//select PC src
	/*if(interrupt_return|interrupt_taken) begin
		PC_in_ = PC_csr;
	end*/
	/*else if(wait_for_interrupt) begin
		PC_in_ = PC_delay1;
	end*/
	/*else*/
	case({EX_Jump,EX_JALR})   
		2'b00: begin
			if(interrupt_return|interrupt_taken) begin
				PC_in_ = PC_csr;
			end			
			else if(wait_for_interrupt) begin
				PC_in_ = PC_delay1;
			end
			else 
				PC_in_ = PC_in1;          //branch or PC+4
		end
		2'b01: PC_in_ = Imm_add_rs1;     //JALR
		2'b10: PC_in_ = EX_PC_add_Imm;      //Jump
		default: PC_in_ = PC_in1;
	endcase
	
end

////////////////when interrupt, replace PC////////////////

logic [31:0]PC_next;
always_comb begin
	if(stall) PC_next = PC - 32'd8;
	else PC_next = PC_in_;
end

always_ff @(posedge clk or posedge rst) begin
	if(rst) PC <= 32'd0;
	else if(!PC_valid) PC <= 32'd0;  
	else if (WAIT_MEM) PC <= PC;  	
	else if (interrupt_return) PC <= PC_csr;
	else PC <= PC_next;
end

logic [31:0]Instruction;
logic [31:0]IM_Data_out_buf;

always_ff@(posedge clk or posedge rst) begin
	if(rst) IM_Data_out_buf<=32'd0;
	else IM_Data_out_buf<=IM_Data_out; 	  
end

always_comb begin
	if(flush|stall|stall_data|wait_for_interrupt|interrupt_return) Instruction=32'd0;
	//else if(interrupt_taken1 /*| interrupt_return1*/) Instruction=32'd0;
	else Instruction=IM_Data_out_buf;
end


always_comb begin//Instruction Mem
	if(PC_valid) begin
		if(wait_for_interrupt) begin
			IM_addr=32'd0;
		end
/*		else if(WAIT_MEM) begin
				IM_addr=PC_delay1;
		end*/
		/*else begin
			if(interrupt_return|interrupt_return1)
				IM_addr=PC_csr;
			else 
				IM_addr=PC_delay1;
		end*/
		else 
			IM_addr=PC_delay1 ;
	end
	else IM_addr=32'd0;
	IM_WEB=4'b1111;
	IM_CS=1'b1;
	IM_OE=1'b1;
end


//////////////IF/ID pipeline//////////////
logic WFI_stall;
always_comb begin
	if(ID_Instruction == 32'h10500073 && EX_Jump == 1'b0 && EX_JALR == 1'b0)
		WFI_stall = (interrupt==1'b1)?1'b0:1'b1;
	else
		WFI_stall = 1'b0;
end



always_ff @(posedge clk or posedge rst) begin
	if(rst)begin
		PC_delay1      <= 32'd0;
		PC_add4_delay1 <= 32'd0;
		PC_delay2      <= 32'd0;
		PC_add4_delay2 <= 32'd0;
	end
	else if (WAIT_MEM/*|WFI_stall*/) begin
		PC_delay1      <= PC_delay1;
		PC_add4_delay1 <= PC_add4_delay1;
		PC_delay2      <= PC_delay2;
		PC_add4_delay2 <= PC_add4_delay2;
	end
	else if(flush) begin
		PC_delay1      <= PC;
		PC_add4_delay1 <= PC_add4;
		PC_delay2      <= PC_delay1;
		PC_add4_delay2 <= PC_add4_delay1;
	end
	else begin
		PC_delay1      <= PC;
		PC_add4_delay1 <= PC_add4;
		PC_delay2      <= PC_delay1;
		PC_add4_delay2 <= PC_add4_delay1;
	end
end

always_ff @(posedge clk or posedge rst) begin
	if(rst)
		stall_data     <= 1'b0;
	else if (WAIT_MEM)
		stall_data 	   <= stall_data ;
	else begin
		if(stall/*|WFI_stall*/)
			stall_data <= 1'b1;
		else
			stall_data <= 1'b0;
	end
end

logic [31:0] ID_Instruction_;
always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		ID_PC_add4     <= 32'd0;
		ID_PC          <=32'd0;
		ID_Instruction_ <= 32'd0;
	end
	//else if(flush) begin
	//	ID_PC_add4     <= ID_PC_add4;
	//	ID_PC          <= ID_PC;
	//	ID_Instruction <= 32'd0;
	//end
	else if (WAIT_MEM|WFI_stall) begin
		ID_PC_add4     <= ID_PC_add4;
		ID_PC          <= ID_PC;
		ID_Instruction_ <= ID_Instruction_;
	end 
	else begin
		if (flush_data|stall/*|interrupt_return2*/) begin
			ID_PC_add4     <= 32'd0;
			ID_PC          <= 32'd0;
			ID_Instruction_ <= 32'd0;
		end
		/*else if(interrupt_return1)begin
			ID_PC_add4     <= 32'd0;
			ID_PC          <= 32'd0;
			ID_Instruction_ <= 32'd0;
		end*/
		/*
		else if (WFI_stall) begin
			ID_PC_add4     <= ID_PC_add4;
			ID_PC          <= ID_PC;
			ID_Instruction_ <= ID_Instruction_;
		end*/ 
		else begin
			ID_PC_add4     <= PC_add4_delay1;
			ID_PC          <= PC_delay1;
			ID_Instruction_ <= Instruction; 
		end
	end
end
assign ID_Instruction = (flush|interrupt_return1|interrupt_return2|interrupt_taken1|interrupt_taken2) ? 32'h00000000:ID_Instruction_;

//////////////ID stage//////////////
logic [4:0]ID_rd_addr;
logic [6:0]ID_opcode;
logic [2:0]ID_func3;
assign ID_rs1_addr=ID_Instruction[19:15];
assign ID_rs2_addr=ID_Instruction[24:20];
//assign ID_rd_addr=ID_Instruction[11:7];
assign ID_opcode=ID_Instruction[6:0];
assign ID_func3=ID_Instruction[14:12];
assign flush_data = flush|MEM_flush/*|WB_flush*/;
logic WB_rs1_hazard,WB_rs2_hazard;
logic [31:0]Write_Data_;
logic [31:0]Read_Data1,Read_Data2;
logic [31:0]WB_csr_out,WRITE_DATAAA;
logic WB_csr_enable;
assign Write_Data_=(WB_RegWrite)? WRITE_DATAAA:32'd0;

always_comb begin
	if(PCSrc|EX_JALR|EX_Jump)
		flush=1'b1;
	else 
		flush=1'b0;
end

Registers registers(
	//output
	.Read_Data1(ID_Read_Data1),.Read_Data2(ID_Read_Data2), 
	//input
	.clk(clk),.rst(rst),
	.RegWrite_ctr(WB_RegWrite),   //probably need to modify***********
	.Read_Reg1(ID_rs1_addr),.Read_Reg2(ID_rs2_addr),.Write_Reg(WB_rd_addr),.WAIT_MEM(WAIT_MEM),
	.Write_Data(Write_Data_)
);

Imm_Gen Imm_gen(
	//output
	.Imm_out(ID_Imm_out),
	//input
	.Instruction(ID_Instruction),
	.Imm_type_control(ID_Imm_type_control)
);

Control_unit control_unit(
	//output
	.Imm_type_control(ID_Imm_type_control),.Jump(ID_Jump),.Branch(ID_Branch),.MemRead(ID_MemRead),
	.MemWrite(ID_MemWrite),.ALUSrc(ID_ALUSrc),.RegWrite(ID_RegWrite),.Load(ID_Load),.PC_Imm_ctr(ID_PC_Imm_ctr),.JALR(ID_JALR),.branch_inv(ID_branch_inv),
	.ALUOP(ID_ALUOP),.rdSrc(ID_rdSrc),.ChipSel(ID_Chipsel),.Store(ID_Store),
	//input
	.funct3(ID_Instruction[14:12]),
	.opcode(ID_Instruction[6:0]),
	.Imm_last2_bit(ID_Imm_out[1:0])
);

Hazard_Detection LW_hazard_detect(
	.stall(stall),
	.EX_MemRead(EX_MemRead),
	.ID_rs1_addr(ID_rs1_addr),.ID_rs2_addr(ID_rs2_addr),
	.EX_rd_addr(EX_rd_addr)
);

///##############################################################///
//////////////CSR//////////////


logic [31:0] csr_in;  ////////////csr_in is depend on funct3
logic [31:0] csr_out;
logic [31:0] EX_csr_out;
logic [31:0] MEM_csr_out;
logic [31:0] csr_out_forwarding;
logic [11:0] csr_read_addr;
logic [11:0] EX_csr_read_addr;
logic [11:0] MEM_csr_read_addr;
logic csr_write;
logic EX_csr_write;
logic MEM_csr_write;

assign wait_for_interrupt = (ID_Instruction == 32'b0001000_00101_00000_000_00000_1110011);
assign interrupt_taken    = interrupt & wait_for_interrupt;
assign interrupt_return   = (ID_Instruction == 32'b0011000_00010_00000_000_00000_1110011);

always_comb begin //CSR forwarding
	if(MEM_csr_write==1'b1 && EX_csr_read_addr==MEM_csr_read_addr) begin
		csr_out_forwarding = MEM_csr_out;
	end
	else begin
		csr_out_forwarding = EX_csr_out;
	end
end

always_comb begin //csr_in preprocessing
	case(EX_funct3) //ALU_in1 == rs1//
		3'b001: csr_in = ALU_in1; 										//CSRRW
		3'b010: csr_in = ALU_in1|csr_out_forwarding; 					//CSRRS
		3'b011: csr_in = (~ALU_in1) & csr_out_forwarding;				//CSRRC
		3'b101: csr_in = {27'b0, EX_rs1_addr};							//CSRRWI
		3'b110: csr_in = {27'b0, EX_rs1_addr}|csr_out_forwarding;		//CSRRSI
		3'b111: csr_in = (~{27'b0, EX_rs1_addr})&csr_out_forwarding;	//CSRRCI
		default:csr_in = 32'd0;
	endcase
end

assign csr_read_addr = ID_Instruction[31:20];
assign csr_write = (EX_OP == 7'b1110011) ? 1'b1:1'b0;
CSR CSR(
	.csr_out(csr_out),
	.csr_pc(PC_csr),
	.reg_write(csr_write),
	.read_addr(csr_read_addr),
	.write_addr(EX_Instruction[31:20]),
	.csr_in(csr_in),
	.pc(PC),
	.clk(clk),
	.rst(rst),
	.interrupt_taken(interrupt_taken),
	.interrupt_return(interrupt_return),
	.interrupt(interrupt)
);

logic ID_csr_enable,EX_csr_enable,MEM_csr_enable;
always_comb
begin
	if(ID_OP == 7'b1110011) begin
		ID_csr_enable= 1'b1;	
	end
	else begin
		ID_csr_enable= 1'b0;
	end
end

always@(posedge clk or posedge rst ) //control signal
begin
  if(rst) begin
	EX_csr_enable  <= 1'b0 ;
	MEM_csr_enable <= 1'b0 ;
	WB_csr_enable  <= 1'b0 ;
  end
  else if(WAIT_MEM) begin
	EX_csr_enable  <= EX_csr_enable  ;
	MEM_csr_enable <= MEM_csr_enable ;
	WB_csr_enable  <= WB_csr_enable  ;
  end
  else begin
   if(flush|stall)begin
	EX_csr_enable <= 1'b0 ;
	MEM_csr_enable<= 1'b0 ;
	WB_csr_enable <= 1'b0 ;     
   end
	else begin
	EX_csr_enable  <= ID_csr_enable  ;
	MEM_csr_enable <= EX_csr_enable  ;
	WB_csr_enable  <= MEM_csr_enable  ;
	end
  end
end

///##############################################################///


//////////////ID/EX pipeline//////////////
logic [1:0]EX_Store;
logic EX_Jump_delay1           ;
logic EX_Branch_delay1         ;
logic EX_JALR_delay1           ;
logic EX_MemRead_delay1        ;
logic [3:0]EX_MemWrite_delay1  ;
logic EX_ALUSrc_delay1         ;
logic EX_RegWrite_delay1       ;
logic [1:0]EX_ALUOP_delay1     ;
logic [1:0]EX_rdSrc_delay1     ;
logic EX_Load_delay1           ;
logic EX_Store_delay1          ;
logic EX_PC_Imm_ctr_delay1     ;
logic EX_Chipsel_delay1        ;
logic EX_branch_inv_delay1     ;
logic EX_stall_delay1          ;

assign ID_OP=ID_Instruction[6:0];
always@(posedge clk or posedge rst ) //control signal
begin
  if(rst) begin
	EX_Jump			<=1'b0;                 
	EX_Branch		<=1'b0;               
	EX_JALR			<=1'b0;                 
	EX_MemRead		<=1'b0;              
	EX_MemWrite		<=4'b1111;             
	EX_ALUSrc		<=1'b0;               
	EX_RegWrite		<=1'b0;             
	EX_ALUOP		<=2'b00;            
	EX_rdSrc		<=2'b00;            
	EX_Load			<=3'd0;  
    EX_Store		<=2'd0;	
	EX_PC_Imm_ctr	<=1'b0;
    EX_Chipsel		<=1'b0;
    EX_branch_inv	<=1'b0;	
	EX_stall		<=1'b0;
  end
  else if(WAIT_MEM) begin
		EX_Jump        <=EX_Jump         ;       
		EX_Branch      <=EX_Branch       ;       
		EX_JALR        <=EX_JALR         ;       
		EX_MemRead     <=EX_MemRead      ;       
		EX_MemWrite    <=EX_MemWrite     ;       
		EX_ALUSrc      <=EX_ALUSrc       ;       
		//EX_RegWrite    <=1'b0     ;  
		EX_RegWrite    <=EX_RegWrite     ;       
		EX_ALUOP       <=EX_ALUOP        ;   
		EX_rdSrc       <=EX_rdSrc        ;   
		EX_Load        <=EX_Load         ;
        EX_Store       <=EX_Store        ;
		EX_PC_Imm_ctr  <=EX_PC_Imm_ctr   ;
		EX_Chipsel     <=EX_Chipsel      ;
	    EX_branch_inv  <=EX_branch_inv   ;
		EX_stall       <=EX_stall        ;
  end
  else begin
   if(flush|stall)begin
		EX_Jump			<=1'b0;                 
		EX_Branch		<=1'b0;               
		EX_JALR			<=1'b0;                 
		EX_MemRead		<=1'b0;              
		EX_MemWrite		<=4'b1111;             
		EX_ALUSrc		<=1'b0;               
		EX_RegWrite		<=1'b0;             
		EX_ALUOP		<=2'b00;            
		EX_rdSrc		<=2'b00;            
		EX_Load			<=3'd0;  
		EX_Store		<=2'd0;	
		EX_PC_Imm_ctr	<=1'b0;
		EX_Chipsel		<=1'b0;
		EX_branch_inv	<=1'b0;	
		EX_stall		<=1'b0;
   end
	else begin
		EX_Jump			<=ID_Jump;                 
		EX_Branch		<=ID_Branch;               
		EX_JALR			<=ID_JALR;                 
		EX_MemRead		<=ID_MemRead;              
		EX_MemWrite		<=ID_MemWrite;             
		EX_ALUSrc		<=ID_ALUSrc;               
		EX_RegWrite		<=ID_RegWrite;             
		EX_ALUOP		<=ID_ALUOP;            
		EX_rdSrc		<=ID_rdSrc;            
		EX_Load			<=ID_Load; 
        EX_Store		<=ID_Store;		
		EX_PC_Imm_ctr	<=ID_PC_Imm_ctr;  
		EX_Chipsel		<=ID_Chipsel;	
	    EX_branch_inv	<=ID_branch_inv;
		EX_stall		<=stall;
	end
  end
end

logic [31:0]EX_Read_Data1_delay1;
logic [31:0]EX_Read_Data2_delay1;
logic [31:0]EX_Imm_out_delay1   ;
logic [4:0]EX_rd_addr_delay1    ;
logic [31:0]EX_PC_add4_delay1   ;
logic [31:0]EX_PC_delay1        ;
logic [2:0]EX_funct3_delay1     ;
logic [6:0]EX_funct7_delay1     ;
logic [4:0]EX_rs1_addr_delay1   ;
logic [4:0]EX_rs2_addr_delay1   ;
logic [6:0]EX_OP_delay1         ;

always@(posedge clk or posedge rst ) begin//registers and add4 and funct3,funct7
	if(rst)begin
		EX_Read_Data1    <=32'd0; 
		EX_Read_Data2    <=32'd0;
		EX_Imm_out       <=32'd0;	
		EX_rd_addr       <=5'd0;
		EX_PC_add4       <=32'd0;
		EX_PC            <=32'd0;
		EX_funct3        <=3'd0;
		EX_funct7        <=7'd0;
		EX_rs1_addr      <=5'd0;
		EX_rs2_addr      <=5'd0;
		EX_OP            <=7'd0;//debug		
		EX_Instruction   <=32'd0;
		EX_csr_out		 <=32'd0;
		EX_csr_read_addr <=12'd0;
		EX_csr_write     <=1'd0;
	end
	else if (WAIT_MEM) begin
		EX_Read_Data1    <=EX_Read_Data1   ;
		EX_Read_Data2    <=EX_Read_Data2   ;
		EX_Imm_out       <=EX_Imm_out      ;
		EX_rd_addr       <=EX_rd_addr      ;
		EX_PC_add4       <=EX_PC_add4      ;
		EX_PC            <=EX_PC           ;
		EX_funct3        <=EX_funct3       ;
		EX_funct7        <=EX_funct7       ;
		EX_rs1_addr      <=EX_rs1_addr     ;
		EX_rs2_addr      <=EX_rs2_addr     ;
		EX_OP            <=EX_OP           ;
		EX_Instruction   <=EX_Instruction  ;
		EX_csr_out		 <=EX_csr_out	   ;
		EX_csr_read_addr <=EX_csr_read_addr;
		EX_csr_write     <=EX_csr_write    ;
	end
	else if(flush|stall)begin
		EX_Read_Data1    <=32'd0; 
		EX_Read_Data2    <=32'd0;
		EX_Imm_out       <=32'd0;	
		EX_rd_addr       <=5'd0;
		EX_PC_add4       <=32'd0;
		EX_PC            <=32'd0;
		EX_funct3        <=3'd0;
		EX_funct7        <=7'd0;
		EX_rs1_addr      <=5'd0;
		EX_rs2_addr      <=5'd0;
		EX_OP            <=7'd0;//debug
		EX_Instruction   <=32'd0;
		EX_csr_out		 <=32'd0;
		EX_csr_read_addr <=12'd0;
		EX_csr_write     <=1'd0;
	end	
	else begin
		EX_Read_Data1    <=ID_Read_Data1; 
		EX_Read_Data2    <=ID_Read_Data2;
		EX_Imm_out       <=ID_Imm_out;    
		EX_rd_addr       <=ID_Instruction[11:7];
		EX_PC_add4       <=ID_PC_add4;
		EX_PC            <=ID_PC;
		EX_funct3        <=ID_Instruction[14:12];
		EX_funct7        <=ID_Instruction[31:25];
		EX_rs1_addr      <=ID_rs1_addr;
		EX_rs2_addr      <=ID_rs2_addr;
		EX_OP            <=ID_OP; //debug	
		EX_Instruction   <=ID_Instruction;
		EX_csr_out		 <=csr_out;
		EX_csr_read_addr <=csr_read_addr;
		EX_csr_write     <=csr_write;
	end
end

//////////////EX stage//////////////
logic[31:0]MEM_PC;
assign EX_Imm_out_shift1=EX_Imm_out;//{EX_Imm_out[30:0],1'b0}; 
assign EX_PC_add_Imm=EX_Imm_out_shift1+EX_PC; //PC_add_Imm= PC+ Imm*** 

ALU_control_unit alu_control_unit(
	//output
	.ALU_ctr(ALU_ctr),
	//input
	.ALUop(EX_ALUOP),
	.funct3(EX_funct3),
	.funct7(EX_funct7)
);

logic [31:0]MEM_forward2;
always_comb begin
	case(Forward_rs1)
		2'b00:ALU_in1   = EX_Read_Data1;
		2'b01:ALU_in1   = WRITE_DATAAA;
		2'b10:ALU_in1   = MEM_forward;
		default:ALU_in1 = EX_Read_Data1;
	endcase
end
logic [31:0]ALU_in2_fw;
always_comb begin
	case(Forward_rs2)
		2'b00:ALU_in2_fw   = EX_Read_Data2;
		2'b01:ALU_in2_fw   = WRITE_DATAAA;
		2'b10:ALU_in2_fw   = MEM_forward2;
		default:ALU_in2_fw = EX_Read_Data2;  
	endcase
end
assign ALU_in2 = (EX_ALUSrc) ? EX_Imm_out:ALU_in2_fw;

ALU alu(
	.ALU_result(EX_ALU_result),
	.ALU_zero(EX_ALU_zero),
	.ALU_in1(ALU_in1),.ALU_in2(ALU_in2),
	.ALU_ctr(ALU_ctr)
);

logic [1:0]Forward_SW;
Forward_unit forward_unit(
	//output
	.Forward_rs1(Forward_rs1),
	.Forward_rs2(Forward_rs2),
	.Forward_SW(Forward_SW),
	.WB_rs1_hazard(WB_rs1_hazard),
	.WB_rs2_hazard(WB_rs2_hazard),
	//input    
	.EX_rs1_addr(EX_rs1_addr),
	.EX_rs2_addr(EX_rs2_addr),
	.ID_rs1_addr(ID_rs1_addr),
	.ID_rs2_addr(ID_rs2_addr),
	.MEM_rd_addr(MEM_rd_addr),
	.WB_rd_addr(WB_rd_addr),
	.MEM_RegWrite(MEM_RegWrite),
	.WB_RegWrite(WB_RegWrite),
	.EX_OP(EX_OP)
);


//////////////EX/MEM pipeline//////////////
logic [31:0]MEM_ALU_in2;
logic [1:0]MEM_Store;
always@(posedge clk or posedge rst ) begin //control signal
	if(rst)begin
		MEM_Jump<=1'b0;
		MEM_Branch<=1'b0;
		MEM_JALR<=1'b0;                 
		MEM_MemRead<=1'b0;              
		MEM_MemWrite<=4'b1111;                         
		MEM_RegWrite<=1'b0;                        
		MEM_rdSrc<=2'b00;            
		MEM_Load<=3'd0;    
		MEM_Store<=2'd0;      	
		MEM_PC_Imm_ctr<=1'b0;
		MEM_Chipsel<=1'b0;	
		MEM_flush<=1'b0;	
		MEM_stall<=1'b0;	
	end
	else if (WAIT_MEM)begin
		MEM_Jump<=MEM_Jump;                 
		MEM_Branch<=MEM_Branch;               
		MEM_JALR<=MEM_JALR; 
		MEM_MemRead<=MEM_MemRead;
		if(CS_M0==`WriteResp ||CS_M1==`WriteResp)		
			MEM_MemWrite<=4'b1111;   
		else
			MEM_MemWrite<=MEM_MemWrite;
		//MEM_RegWrite<=1'b0;    
		MEM_RegWrite<=MEM_RegWrite;                       
		MEM_rdSrc<=MEM_rdSrc;            
		MEM_Load<=MEM_Load;
		MEM_Store<=MEM_Store;		
		MEM_PC_Imm_ctr<=MEM_PC_Imm_ctr;
		MEM_Chipsel<=MEM_Chipsel;
		MEM_flush<=MEM_flush;
		MEM_stall<=MEM_stall;   
	end
	else begin
		MEM_Jump<=EX_Jump;                 
		MEM_Branch<=EX_Branch;               
		MEM_JALR<=EX_JALR;                 
		MEM_MemRead<=EX_MemRead;              
		MEM_MemWrite<=EX_MemWrite;                         
		MEM_RegWrite<=EX_RegWrite;                       
		MEM_rdSrc<=EX_rdSrc;            
		MEM_Load<=EX_Load;
		MEM_Store<=EX_Store;		
		MEM_PC_Imm_ctr<=EX_PC_Imm_ctr;
		MEM_Chipsel<=EX_Chipsel;	
		MEM_flush<=flush;
		MEM_stall<=EX_stall;		
	end
end


always_ff@(posedge clk or posedge rst) begin //otherwise
	if(rst)begin
		MEM_ALU_result   <= 32'd0;
		MEM_ALU_zero     <= 1'b0;
		MEM_PC_add_Imm   <= 32'd0;
		MEM_PC_add4      <= 32'd0;
		MEM_Imm_out      <= 32'd0;
		MEM_Read_Data2   <= 32'd0;
		MEM_rd_addr	     <= 5'd0;
		MEM_ALU_in2      <= 32'd0;	
		MEM_PC           <= 32'd0;
		MEM_funct3       <= 3'd0; 
		MEM_csr_out		 <= 32'd0;
		MEM_csr_read_addr<= 12'd0;
		MEM_csr_write    <= 1'd0;
	end
	else if(WAIT_MEM)begin
		MEM_ALU_result   <= MEM_ALU_result   ;
		MEM_ALU_zero     <= MEM_ALU_zero     ;
		MEM_PC_add_Imm   <= MEM_PC_add_Imm   ;
		MEM_PC_add4      <= MEM_PC_add4      ;
		MEM_Imm_out      <= MEM_Imm_out      ;
		MEM_Read_Data2   <= MEM_Read_Data2   ;
		MEM_rd_addr	     <= MEM_rd_addr	     ;
		MEM_ALU_in2      <= MEM_ALU_in2      ;
		MEM_PC           <= MEM_PC           ;
		MEM_funct3       <= MEM_funct3       ; 
		MEM_csr_out		 <= MEM_csr_out		 ;
		MEM_csr_read_addr<= MEM_csr_read_addr;
		MEM_csr_write    <= MEM_csr_write    ;
	end
	else begin
		MEM_ALU_result   <= EX_ALU_result;
		MEM_ALU_zero     <= EX_ALU_zero  ;
		MEM_PC_add_Imm   <= EX_PC_add_Imm;
		MEM_PC_add4      <= EX_PC_add4   ;
		MEM_Imm_out      <= EX_Imm_out   ;
		MEM_Read_Data2   <= EX_Read_Data2;
		MEM_rd_addr	     <= EX_rd_addr   ;  
		if(Forward_SW==2'd1) MEM_ALU_in2 <= MEM_ALU_result;
		//else if (Forward_SW==2'd2) MEM_ALU_in2 <= Write_Data;
		else if (Forward_SW==2'd2) MEM_ALU_in2 <= WRITE_DATAAA;
		else MEM_ALU_in2 <= ALU_in2_fw;/////////
		MEM_PC           <= EX_PC;
		MEM_funct3       <= EX_funct3;
		MEM_csr_out      <= EX_csr_out;
		MEM_csr_read_addr<= EX_csr_read_addr;
		MEM_csr_write    <= EX_csr_write;
	end
end

//////////////MEM stage//////////////

logic condition_satisfy;
assign condition_satisfy     = (EX_branch_inv)  ? (!EX_ALU_zero):EX_ALU_zero;
assign MEM_PC_add_Imm_or_Imm = (MEM_PC_Imm_ctr) ? MEM_PC_add_Imm:MEM_Imm_out ;
assign PCSrc       = EX_Branch & condition_satisfy; //branch or not
assign PC_add_Imm  = MEM_PC_add_Imm;
assign Imm_add_rs1 = EX_ALU_result;

logic [3:0]MEM_Store_MemWrite;
logic [31:0]DM_SB_in; //store back
always_comb begin
	if(MEM_Store == 2'b01) begin //SB
		case(MEM_ALU_result[1:0])
			2'b00:begin
				DM_SB_in = {24'd0, MEM_ALU_in2[7:0]};
				MEM_Store_MemWrite = 4'b1110;
			end
			2'b01:begin
				DM_SB_in = {16'd0, MEM_ALU_in2[7:0], 8'd0};
				MEM_Store_MemWrite = 4'b1101;
			end
			2'b10:begin
				DM_SB_in = {8'd0, MEM_ALU_in2[7:0], 16'd0};
				MEM_Store_MemWrite = 4'b1011;
			end
			2'b11:begin
				DM_SB_in = {MEM_ALU_in2[7:0], 24'd0};
				MEM_Store_MemWrite = 4'b0111;
			end
		endcase
	end
	else if(MEM_Store == 2'b10) begin //SH
		case(MEM_ALU_result[1:0])
			2'b00:begin
				DM_SB_in = {16'd0, MEM_ALU_in2[15:0]};
				MEM_Store_MemWrite = 4'b1100;
			end
			2'b01:begin
				DM_SB_in = {8'd0, MEM_ALU_in2[15:0], 8'd0};
				MEM_Store_MemWrite = 4'b1001;
			end
			2'b10:begin
				DM_SB_in = {MEM_ALU_in2[15:0], 16'd0};
				MEM_Store_MemWrite = 4'b0011;
			end
			default:begin
				DM_SB_in = 32'd0;
				MEM_Store_MemWrite = 4'b1111;			  
			end 
		endcase
	end
	else if(MEM_Store == 2'b11) begin //SW
		DM_SB_in = MEM_ALU_in2;
		MEM_Store_MemWrite = MEM_MemWrite;
	end
	else begin
		DM_SB_in = MEM_ALU_in2;
		MEM_Store_MemWrite = 4'b1111;
	end
end



always_comb begin //Data_Mem
	DM_CS = 1'b1;
	DM_WEB = MEM_Store_MemWrite;
	if(DM_CS) DM_addr = MEM_ALU_result;
	else DM_addr = 32'd0;
	DM_Data_in = DM_SB_in;
	DM_OE = MEM_MemRead; 
end

always_comb begin
	if(MEM_Load == 3'b101) begin //LW
		MEM_DM_Data = DM_Data_out;
	end
	else if(MEM_Load == 3'b001) begin //LB
		case(MEM_ALU_result[1:0])
			2'b00: MEM_DM_Data = {{24{DM_Data_out[7]}}, DM_Data_out[7:0]};
			2'b01: MEM_DM_Data = {{24{DM_Data_out[15]}}, DM_Data_out[15:8]};
			2'b10: MEM_DM_Data = {{24{DM_Data_out[23]}}, DM_Data_out[23:16]};
			2'b11: MEM_DM_Data = {{24{DM_Data_out[31]}}, DM_Data_out[31:24]};
		endcase
	end
	else if(MEM_Load == 3'b010) begin //LH
		case(MEM_ALU_result[1:0])
			2'b00: MEM_DM_Data = {{16{DM_Data_out[15]}}, DM_Data_out[15:0]};
			2'b01: MEM_DM_Data = {{16{DM_Data_out[23]}}, DM_Data_out[23:8]};
			2'b10: MEM_DM_Data = {{16{DM_Data_out[31]}}, DM_Data_out[31:16]};
			2'b11: MEM_DM_Data = 32'd0;
		endcase
	end
	else if(MEM_Load == 3'b011) begin //LBU
		case(MEM_ALU_result[1:0])
			2'b00: MEM_DM_Data = {24'd0, DM_Data_out[7:0]};
			2'b01: MEM_DM_Data = {24'd0, DM_Data_out[15:8]};
			2'b10: MEM_DM_Data = {24'd0, DM_Data_out[23:16]};
			2'b11: MEM_DM_Data = {24'd0, DM_Data_out[31:24]};
		endcase
	end
	else if(MEM_Load == 3'b100)begin //LHU
		case(MEM_ALU_result[1:0])
			2'b00: MEM_DM_Data = {16'd0, DM_Data_out[15:0]};
			2'b01: MEM_DM_Data = {16'd0, DM_Data_out[23:8]};
			2'b10: MEM_DM_Data = {16'd0, DM_Data_out[31:16]};
			2'b11: MEM_DM_Data = 32'd0;
		endcase
	end
	else begin
		MEM_DM_Data = 32'b0;
	end
end

logic [31:0]MEM_DM_Data_buf;
always_ff @(posedge clk or posedge rst) begin
	if(rst) MEM_DM_Data_buf           <= 32'd0;
	else if(WAIT_MEM) MEM_DM_Data_buf <= MEM_DM_Data_buf;
	else MEM_DM_Data_buf              <= MEM_DM_Data;
end


always_comb begin
	case(MEM_rdSrc)
		2'b00:MEM_forward = MEM_ALU_result;
		//2'b01:MEM_forward=MEM_DM_Data;
		2'b10:MEM_forward = MEM_PC_add4;
		2'b11:MEM_forward = MEM_PC_add_Imm_or_Imm;
		default:MEM_forward = MEM_ALU_result;
	endcase
end


always_comb begin
	if(MEM_csr_enable) MEM_forward2 = MEM_csr_out ; 
	else MEM_forward2 = MEM_forward ; 
end


//////////////MEM/WB pipeline//////////////
always_ff@(posedge clk or posedge rst) begin //control signal
	if(rst)begin                                                                                               
		WB_rdSrc	<=2'b00;            
		WB_RegWrite	<=1'b0;
		WB_flush	<=1'b0;
		WB_MemRead	<=1'b0;
		WB_stall	<=1'b0;
	end
	else if (WAIT_MEM)begin
		WB_rdSrc	<=WB_rdSrc;            
		WB_RegWrite	<=WB_RegWrite;
		WB_flush	<=WB_flush;	
		WB_MemRead	<=WB_MemRead;
		WB_stall	<=WB_stall;	 
	end
	else begin      
		WB_rdSrc	<=MEM_rdSrc;            
		WB_RegWrite	<=MEM_RegWrite;
		WB_flush	<=MEM_flush;	
		WB_MemRead	<=MEM_MemRead;
		WB_stall	<=MEM_stall;
	end
end

logic[31:0] WB_DM_Data;
always@(posedge clk or posedge rst) begin //otherwise
	if(rst) begin	
		WB_PC_add4          <= 32'd0;
		WB_PC_add_Imm_or_Imm<= 32'd0;
		WB_rd_addr	        <= 5'd0; 
		WB_DM_Data_out      <= 32'd0; 
		WB_ALU_result 	    <= 32'd0;
		WB_DM_Data         	<= 32'd0;
		WB_csr_out          <= 32'd0;
	end
	else if(WAIT_MEM) begin
		WB_PC_add4          <= WB_PC_add4;          
		WB_PC_add_Imm_or_Imm<= WB_PC_add_Imm_or_Imm;    
		WB_rd_addr	        <= WB_rd_addr; 
		WB_DM_Data_out      <= WB_DM_Data_out;
		WB_ALU_result 	    <= WB_ALU_result;	
		WB_DM_Data          <= WB_DM_Data;  
		WB_csr_out          <= WB_csr_out;
	end
	else begin
		WB_PC_add4          <= MEM_PC_add4;          
		WB_PC_add_Imm_or_Imm<= MEM_PC_add_Imm_or_Imm;    
		WB_rd_addr	        <= MEM_rd_addr; 
		WB_DM_Data_out      <= DM_Data_out;
		WB_ALU_result 	    <= MEM_ALU_result;	
		WB_DM_Data          <= MEM_DM_Data;
		WB_csr_out          <= MEM_csr_out;
	end
end

//////////////WB stage//////////////
always_comb begin
	case(WB_rdSrc)
		2'b00:Write_Data = WB_ALU_result;
		2'b01:Write_Data = WB_DM_Data;
		//2'b01:Write_Data = MEM_DM_Data_buf;
		2'b10:Write_Data = WB_PC_add4;
		2'b11:Write_Data = WB_PC_add_Imm_or_Imm;
	endcase
end

always_comb begin
	if(WB_csr_enable) WRITE_DATAAA = WB_csr_out ; 
	else WRITE_DATAAA = Write_Data ; 
end

assign DM_type = MEM_funct3 ;
assign IM_type = 3'b010;


endmodule


