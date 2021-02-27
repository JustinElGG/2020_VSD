`timescale 1ns/10ps
`include "defines.sv"

module imm_gen( input [`instruction_size-1:0]ins,
                input shift_op,
                output logic [`imm_size-1:0]imm);

logic [6:0]ins_type;
assign ins_type = ins[6:0];
always_comb begin
    case(ins_type)
        `Rtype: begin //R-type
            imm = 32'b0;
        end
        `Itype, `ILtype, `IJtype: begin //I-type
            if(shift_op) imm = {27'b0, ins[24:20]};
            else imm = { {20{ins[31]}}, ins[31:20] };
        end
        `Stype: begin //S-type
            imm = { {20{ins[31]}}, ins[31:25], ins[11:7] };
        end
        `Btype: begin //B-type
            imm = { {20{ins[31]}}, ins[7], ins[30:25], ins[11:8], 1'b0};
        end
        `Utype, `ULtype: begin //U-type
            imm = {ins[31:12], 12'b0};
        end
        `Jtype: begin //J-type
            imm = { {13{ins[31]}}, ins[19:12], ins[20], ins[30:21], 1'b0};
        end
        default: begin
            //imm = 32'b0;
            imm = ins;
        end
    endcase
end
endmodule
