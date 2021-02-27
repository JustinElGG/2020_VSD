module Imm_Gen(
output logic [31:0]Imm_out,
input [31:0]Instruction,
input [2:0]Imm_type_control
);

always@(*)
begin
  case(Imm_type_control)
    3'b001: Imm_out={{20{Instruction[31]}},Instruction[31:20]}; //I-type
    3'b010: Imm_out={{20{Instruction[31]}},Instruction[31:25],Instruction[11:7]}; //S-type
    3'b011: Imm_out={{20{Instruction[31]}},Instruction[7],Instruction[30:25],Instruction[11:8],1'b0}; //B-type
    3'b100: Imm_out={Instruction[31:12],{12{1'b0}}}; //U-type
    3'b101: Imm_out={{12{Instruction[31]}},Instruction[19:12],Instruction[20],Instruction[30:21],1'b0}; //J-type
	default: Imm_out=32'b0;
  endcase
end

endmodule