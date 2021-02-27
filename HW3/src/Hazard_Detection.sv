module Hazard_Detection(
output logic stall,
input EX_MemRead,
input[4:0]ID_rs1_addr,ID_rs2_addr,
input[4:0]EX_rd_addr
);
	
always_comb
begin
  if(EX_MemRead)begin
    if((ID_rs1_addr==EX_rd_addr)|(ID_rs2_addr==EX_rd_addr)) stall=1'b1;
	else stall=1'b0;
  end
  else stall=1'b0;
end	
	
endmodule	
	