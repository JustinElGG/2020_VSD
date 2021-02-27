`timescale 1ns/10ps
`include "defines.sv"

module branch_pos(  input [`instruction_size-1:0]ins,
                    input [`data_size-1:0]ALU_result,
                    output logic [`data_size-1:0]branch_out);

wire [2:0]funct3;
wire [6:0]opcode;
assign funct3 = ins[14:12];
assign opcode = ins[6:0];

always_comb begin
    case(opcode)    
        `Btype: begin
            case(funct3)
                `BEQ:  branch_out = !ALU_result;
                `BNE:  branch_out = ALU_result;
                `BLT:  branch_out = ALU_result;
                `BGE:  branch_out = !ALU_result;
                `BLTU: branch_out = ALU_result;
                `BGEU: branch_out = !ALU_result;
                default: branch_out = 32'b0;
            endcase
        end
        `IJtype: branch_out = 32'b1;
        default: branch_out = ALU_result;
    endcase
end
endmodule
