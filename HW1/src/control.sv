`timescale 1ns/10ps
`include "defines.sv"

module control( input [6:0]opcode,
                input [2:0]funct3,
                output logic mem_cs,
                output logic [3:0]mem_we,
                output logic mem_oe,
                output logic store_byte,
                output logic load_byte,
                output logic [1:0]rdsrc,
                output logic reg_write,
                output logic reg_read,
                output logic branch,
                output logic jal_flag,
                output logic auipc_sel,
                output logic [1:0]sel_branch,
                output logic alu_src,
                output logic [1:0]mem2reg,
                output logic shift_op);

//mem_cs:       0->mem off 1->mem on
//mem_we:       0000->write 1111->read
//mem_oe:       0->mem output off 1->mem output on
//reg_write:    0->reg write off 1->reg write on
//reg_read:     0->reg read off 1->reg read on
//branch:       0->disable branch 1->enable branch, there may be a pc jump
//jal_flag:     0->disable 1->jalr detect, open the branch road
//auipc_sel:    0->disable 1->auipc, add_sum result overwrite alu_result
//sel_branch:   10->imm 01->rs1+imm 00->pc+imm
//alu_src:      0->rs2 1->imm
//mem2reg:      00->alu to reg 01->mem to reg 10->pc+4 to reg 11->pc+imm to reg

always_comb begin
    case(opcode)
        `Rtype: begin
            mem_cs      = 1'b0;
            mem_we      = 4'b1111;
            mem_oe      = 1'b0;
            store_byte  = 1'b0;
            load_byte   = 1'b0;
            rdsrc       = 2'b00;
            reg_write   = 1'b1;
            reg_read    = 1'b1;
            branch      = 1'b0;
            jal_flag    = 1'b0;
            auipc_sel   = 1'b0;
            sel_branch  = 2'b00;
            alu_src     = 1'b0;
            mem2reg     = 2'b00;
            shift_op    = 1'b0;
        end
        `Itype: begin
            mem_cs      = 1'b0;
            mem_we      = 4'b1111;
            mem_oe      = 1'b0;
            store_byte  = 1'b0;
            load_byte   = 1'b0;
            rdsrc       = 2'b00;
            reg_write   = 1'b1;
            reg_read    = 1'b1;
            branch      = 1'b0;
            jal_flag    = 1'b0;
            auipc_sel   = 1'b0;
            sel_branch  = 2'b00;
            alu_src     = 1'b1;
            mem2reg     = 2'b00;
            if((funct3 == 3'b001) || (funct3 == 3'b101)) shift_op = 1'b1;
            else shift_op = 1'b0;

        end
        `ILtype: begin
            mem_cs      = 1'b1;
            mem_we      = 4'b1111;
            mem_oe      = 1'b1;
            store_byte  = 1'b0;
            if(funct3 == 3'b010)    load_byte = 1'b0; //LW
            else                    load_byte = 1'b1; //LB
            rdsrc       = 2'b01;
            reg_write   = 1'b1;
            reg_read    = 1'b1;
            branch      = 1'b0;
            jal_flag    = 1'b0;
            auipc_sel   = 1'b0;
            sel_branch  = 2'b00;
            alu_src     = 1'b1;
            mem2reg     = 2'b01;
            shift_op    = 1'b0;
        end

        `IJtype: begin
            mem_cs      = 1'b0;
            mem_we      = 4'b1111;
            mem_oe      = 1'b0;
            store_byte  = 1'b0;
            load_byte   = 1'b0;
            reg_write   = 1'b1;
            reg_read    = 1'b1;
            rdsrc       = 2'b10;
            branch      = 1'b1;
            jal_flag    = 1'b1;
            auipc_sel   = 1'b0;
            sel_branch  = 2'b01; //JALR: PC=imm+rs1
            alu_src     = 1'b1;
            mem2reg     = 2'b10;
            shift_op    = 1'b0;
        end

        `Stype: begin
            mem_cs      = 1'b1;
            mem_we      = 4'b0000;  //Store
            mem_oe      = 1'b0;
            if(funct3 == 3'b010)    store_byte = 1'b0; //SW
            else                    store_byte = 1'b1; //SB
            load_byte   = 1'b0;
            reg_write   = 1'b0;
            reg_read    = 1'b1;
            rdsrc       = 2'b00;
            branch      = 1'b0;
            jal_flag    = 1'b0;
            auipc_sel   = 1'b0;
            sel_branch  = 2'b01;
            alu_src     = 1'b1;
            mem2reg     = 2'b00;
            shift_op    = 1'b0;

        end
        `Btype: begin
            mem_cs      = 1'b0;
            mem_we      = 4'b1111;
            mem_oe      = 1'b0;
            store_byte  = 1'b0;
            load_byte   = 1'b0;
            reg_write   = 1'b0;
            reg_read    = 1'b1;
            rdsrc       = 2'b00;
            branch      = 1'b1;
            jal_flag    = 1'b0;
            auipc_sel   = 1'b0;
            sel_branch  = 2'b00;
            alu_src     = 1'b0;
            mem2reg     = 2'b00;
            shift_op    = 1'b0;

        end
        `Utype: begin
            mem_cs      = 1'b0;
            mem_we      = 4'b1111;
            mem_oe      = 1'b0;
            store_byte  = 1'b0;
            load_byte   = 1'b0;
            rdsrc       = 2'b11;
            reg_write   = 1'b1;
            reg_read    = 1'b0;
            branch      = 1'b0;
            jal_flag    = 1'b0;
            auipc_sel   = 1'b1;
            sel_branch  = 2'b00;
            alu_src     = 1'b0;
            mem2reg     = 2'b11;
            shift_op    = 1'b0;

        end
        `ULtype: begin
            mem_cs      = 1'b0;
            mem_we      = 4'b1111;
            mem_oe      = 1'b0;
            store_byte  = 1'b0;
            load_byte   = 1'b0;
            rdsrc       = 2'b11;
            reg_write   = 1'b1;
            reg_read    = 1'b0;
            branch      = 1'b0;
            jal_flag    = 1'b0;
            auipc_sel   = 1'b1;
            sel_branch  = 2'b10;
            alu_src     = 1'b0;
            mem2reg     = 2'b00;
            shift_op    = 1'b0;

        end
        `Jtype: begin
            mem_cs      = 1'b0;
            mem_we      = 4'b1111;
            mem_oe      = 1'b0;
            store_byte  = 1'b0;
            load_byte   = 1'b0;
            reg_write   = 1'b1;
            reg_read    = 1'b0;
            rdsrc       = 2'b10;
            branch      = 1'b1;
            jal_flag    = 1'b1;
            auipc_sel   = 1'b0;
            sel_branch  = 2'b00;
            alu_src     = 1'b0;
            mem2reg     = 2'b10;
            shift_op    = 1'b0;

        end
        default: begin
            mem_cs      = 1'b0;
            mem_we      = 4'b1111;
            mem_oe      = 1'b0;
            store_byte  = 1'b0;
            load_byte   = 1'b0;
            rdsrc       = 2'b00;
            reg_write   = 1'b0;
            reg_read    = 1'b0;
            branch      = 1'b0;
            jal_flag    = 1'b0;
            auipc_sel   = 1'b0;
            sel_branch  = 2'b00;
            alu_src     = 1'b0;
            mem2reg     = 2'b00;
            shift_op    = 1'b0;
        
        end
    endcase

end
endmodule
