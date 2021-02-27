`timescale 1ns/10ps
`include "defines.sv"

module add_sum( input [`pc_size-1:0]pc,
				input [`imm_size-1:0]imm,
                input [`pc_size-1:0]rs1_imm,
                input [1:0]select,
                output logic [`pc_size-1:0]pc_add);
				
logic [`imm_size-1:0]imm_shift;
logic [`pc_size-1:0]pc_add_imm;

assign pc_add_imm = imm + pc;
assign pc_add = (select == 2'b10) ? imm : 
                (select == 2'b01) ? rs1_imm :
                                    pc_add_imm;

endmodule
