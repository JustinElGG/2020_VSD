module Forward_unit(
output logic [1:0]Forward_rs1,
output logic [1:0]Forward_rs2,
output logic [1:0]Forward_SW,
output logic WB_rs1_hazard,WB_rs2_hazard,
input [4:0]EX_rs1_addr,
input [4:0]EX_rs2_addr,
input [4:0]ID_rs1_addr,
input [4:0]ID_rs2_addr,
input [4:0]MEM_rd_addr,
input [4:0]WB_rd_addr,
input MEM_RegWrite,WB_RegWrite,
input [6:0]EX_OP
);
logic EX_rs1_hazard,MEM_rs1_hazard,EX_rs2_hazard,MEM_rs2_hazard;

always_comb //detect hazard at EX
begin
  if((MEM_RegWrite)&(MEM_rd_addr!=5'd0))begin
    if(EX_rs1_addr==MEM_rd_addr) EX_rs1_hazard=1'b1;
    else EX_rs1_hazard=1'b0;
    if(EX_rs2_addr==MEM_rd_addr) EX_rs2_hazard=1'b1;
    else EX_rs2_hazard=1'b0;	
  end
  else begin
    EX_rs1_hazard=1'b0;
	EX_rs2_hazard=1'b0;
  end
end

always_comb //detect hazard at MEM
begin
  if((WB_RegWrite)&(WB_rd_addr!=5'd0))begin
    if((EX_rs1_addr==WB_rd_addr)&(!(EX_rs1_hazard))) MEM_rs1_hazard=1'b1;
    else MEM_rs1_hazard=1'b0;
    if((EX_rs2_addr==WB_rd_addr)&(!(EX_rs2_hazard))) MEM_rs2_hazard=1'b1;
    else MEM_rs2_hazard=1'b0;	
  end
  else begin
    MEM_rs1_hazard=1'b0;
	MEM_rs2_hazard=1'b0;
  end
end

always_comb //detect hazard at WB
begin
  if((WB_RegWrite)&(WB_rd_addr!=5'd0))begin
    if((ID_rs1_addr==WB_rd_addr)&(!(EX_rs1_hazard))) WB_rs1_hazard=1'b1;
    else WB_rs1_hazard=1'b0;
    if((ID_rs2_addr==WB_rd_addr)&(!(EX_rs2_hazard))) WB_rs2_hazard=1'b1;
    else WB_rs2_hazard=1'b0;	
  end
  else begin
    WB_rs1_hazard=1'b0;
	WB_rs2_hazard=1'b0;
  end
end


always_comb
begin
  if(EX_OP==7'd3)begin
    if((MEM_RegWrite)&&(EX_rs2_addr==MEM_rd_addr))
	  Forward_SW=2'd1;
	else if ((WB_RegWrite)&&(EX_rs2_addr==WB_rd_addr))
	  Forward_SW=2'd2;
	else 
	  Forward_SW=2'd0;
  end
  else Forward_SW=2'd0;
end

always_comb
begin
  case({EX_rs1_hazard,MEM_rs1_hazard})
  2'b00:Forward_rs1=2'b00;
  2'b01:Forward_rs1=2'b01;
  2'b10:Forward_rs1=2'b10;
  2'b11:Forward_rs1=2'b10;
  endcase
end

always_comb
begin
  case({EX_rs2_hazard,MEM_rs2_hazard})
  2'b00:Forward_rs2=2'b00;
  2'b01:Forward_rs2=2'b01;
  2'b10:Forward_rs2=2'b10;
  2'b11:Forward_rs2=2'b10;
  endcase
end



endmodule