`timescale 1ns/10ps
`include "defines.sv"

`include "control.sv"
`include "ALU.sv"
`include "ALU_control.sv"
`include "reg_32x32.sv"
`include "imm_gen.sv"
`include "add_sum.sv"
`include "branch_pos.sv"
`include "forwarding.sv"

module CPU( input clk,
            input rst,
            output logic IM_CS, //commute w/ instruction memory
            output logic IM_OE,
            output logic [`sram_addr_size-1:0]IM_A,
            output logic [3:0]IM_WEB,
            output logic [`data_size-1:0]IM_DI,
            input [`data_size-1:0]IM_DO,
            output logic DM_CS, //commute w/ data memory
            output logic DM_OE,
            output logic [`sram_addr_size-1:0]DM_A,
            output logic [3:0]DM_WEB,
            output logic [`data_size-1:0]DM_DI,
            input [`data_size-1:0]DM_DO);

//======================IF======================//
logic [`pc_size-1:0]pc;
logic [`pc_size-1:0]pc_;
logic [`pc_size-1:0]pc_next;
logic [`pc_size-1:0]pc_add4;
logic pc_src;
logic [`data_size-1:0]branch_result;

always_ff @(posedge clk) begin
    if(rst) begin
        pc  <= 32'b0;
        pc_ <= 32'b0;
    end
    else begin
        pc  <= pc_next;
        pc_ <= pc;
    end
end

assign IM_CS = 1'b1; //always on
assign IM_OE = 1'b1; //
assign IM_A  = pc[15:2];
assign IM_WEB = 4'b1111; //instruction memory is unwritable
assign IM_DI = 32'b0; //write in data is dont care
assign pc_add4 = pc+4;
assign pc_next = pc_src ? branch_result:pc_add4;


//=====================IF/ID=====================//
logic [`pc_size-1:0]pc_ID;
logic [`instruction_size-1:0]ins_ID;
always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
        pc_ID   <= 32'b0;
        ins_ID  <= 32'b0;
    end
    else begin
        pc_ID   <= pc_;
        ins_ID  <= IM_DO;
    end
end


//======================ID======================//
////wires
//wire for control
logic [6:0]opcode;
logic mem_cs;
logic [3:0]mem_we;
logic mem_oe;
logic reg_write;
logic reg_read;
logic [1:0]sel_branch;
logic alu_src;
logic [1:0]mem2reg;
//wire for reg
logic [`addr_size-1:0]read_addr_1;
logic [`addr_size-1:0]read_addr_2;
logic [`data_size-1:0]out_1;
logic [`data_size-1:0]out_2;
logic reg_write_WB;
logic reg_read_WB;
logic reg_write_MEM;
logic [4:0]write_reg_WB;
logic [`data_size-1:0]write_data;
logic reg_read_1;
//wire for imm gen
logic [`imm_size-1:0]imm;
logic auipc_sel;

//// assign
assign opcode = ins_ID[6:0];
assign read_addr_1 = ins_ID[19:15];
assign read_addr_2 = ins_ID[24:20];
assign reg_read_1 = 1'b1;

control control(    .opcode(opcode), .mem_cs(mem_cs), .mem_we(mem_we), .mem_oe(mem_oe),
                    .reg_write(reg_write), .reg_read(reg_read), .branch(branch), .jal_flag(jal_flag), .auipc_sel(auipc_sel), 
                    .sel_branch(sel_branch), .alu_src(alu_src), .mem2reg(mem2reg) );
reg_32x32 register( .clk(clk), .rst(rst), .write(reg_write_MEM), .read(reg_read_1), .read_addr_1(read_addr_1),
                    .read_addr_2(read_addr_2), .write_addr(write_reg_WB), .data_in(write_data),
                    .out_1(out_1), .out_2(out_2));

imm_gen imm_gen(    .ins(ins_ID), .imm(imm) );
//=====================ID/EX=====================
logic mem_cs_EX;
logic [3:0]mem_we_EX;
logic mem_oe_EX;
logic reg_write_EX;
logic reg_read_EX;
logic branch_EX;
logic jal_flag_EX;
logic auipc_sel_EX;
logic [1:0]sel_branch_EX;
logic alu_src_EX;
logic [1:0]mem2reg_EX;
logic [`pc_size-1:0]pc_EX;
logic [`imm_size-1:0]imm_EX;
logic [`instruction_size-1:0]ins_EX;
logic [4:0]write_reg_EX;
logic [4:0]read_addr_1_EX;
logic [4:0]read_addr_2_EX;

always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
        mem_cs_EX       <= 1'b0;
        mem_we_EX       <= 4'b0;
        mem_oe_EX       <= 1'b0;
        reg_write_EX    <= 1'b0;
        reg_read_EX     <= 1'b0;
        branch_EX       <= 1'b0;
        jal_flag_EX     <= 1'b0;
        auipc_sel_EX    <= 1'b0;
        sel_branch_EX   <= 2'b0;
        alu_src_EX      <= 1'b0;
        mem2reg_EX      <= 2'b00;
        pc_EX           <= 32'b0;
        imm_EX          <= 32'b0;
        ins_EX          <= 32'b0;
        write_reg_EX    <= 5'b0;
        read_addr_1_EX  <= 5'b0;
        read_addr_2_EX  <= 5'b0;
    end
    else begin
        mem_cs_EX       <= mem_cs;
        mem_we_EX       <= mem_we;
        mem_oe_EX       <= mem_oe;
        reg_write_EX    <= reg_write;
        reg_read_EX     <= reg_read;
        branch_EX       <= branch;
        jal_flag_EX     <= jal_flag;
        auipc_sel_EX    <= auipc_sel;
        sel_branch_EX   <= sel_branch;
        alu_src_EX      <= alu_src;
        mem2reg_EX      <= mem2reg;
        pc_EX           <= pc_ID;
        imm_EX          <= imm;
        ins_EX          <= ins_ID;
        write_reg_EX    <= ins_ID[11:7];
        read_addr_1_EX  <= read_addr_1;
        read_addr_2_EX  <= read_addr_2;
    end
end


//======================EX======================//
logic alu_enable;
logic [3:0]alu_op;
logic [`data_size-1:0]src2_;
logic [`data_size-1:0]alu_result;
logic [`data_size-1:0]alu_result_;
logic [`data_size-1:0]alu_result_auipc;
logic of;
logic [`pc_size-1:0]pc_4;
logic [`data_size-1:0]branch_out;
logic [1:0]reg1_sel;
logic [1:0]reg2_sel;

logic [4:0]write_reg_MEM;
logic [`data_size-1:0]alu_result_MEM;

logic [`data_size-1:0]out_1_for;
logic [`data_size-1:0]out_2_for;

assign alu_enable = 1'b1;
assign src2_ = alu_src_EX ? imm_EX : out_2_for;
assign pc_4 = pc_EX + 32'd4;

assign out_1_for = (reg1_sel == 2'b00) ? out_1 :
                   (reg1_sel == 2'b01) ? write_data :
                                         alu_result_MEM;
assign out_2_for = (reg2_sel == 2'b00) ? out_2 :
                   (reg2_sel == 2'b01) ? write_data :
                                         alu_result_MEM;
assign alu_result_auipc = (auipc_sel_EX == 1'b1) ? branch_out : alu_result_;



ALU alu( .src1(out_1_for), .src2(src2_), .OP(alu_op), .enable(alu_enable), .alu_result(alu_result), .Overflow(of) );
ALU_control alu_control( .ins(ins_ID), .OP(alu_op) );
add_sum add_sum( .pc(pc_EX), .imm(imm_EX), .rs1_imm(alu_result), .select(sel_branch), .pc_add(branch_out) );
branch_pos branch_pos( .ins(ins_EX), .ALU_result(alu_result), .branch_out(alu_result_) );
forwarding forwarding(  .read_addr_1_EX(read_addr_1_EX), .read_addr_2_EX(read_addr_2_EX), .write_reg_MEM(write_reg_MEM), .write_reg_WB(write_reg_WB),
                        .reg_write_MEM(reg_write_MEM), .reg_write_WB(reg_write_WB), .reg1_sel(reg1_sel), .reg2_sel(reg2_sel) );
//=====================EX/MEM=====================
logic mem_cs_MEM;
logic [3:0]mem_we_MEM;
logic mem_oe_MEM;
//logic reg_write_MEM;
logic reg_read_MEM;
logic branch_MEM;
logic jal_flag_MEM;
logic [`data_size-1:0]branch_out_MEM;
logic [1:0]mem2reg_MEM;
logic [`pc_size-1:0]pc_4_MEM;
//logic [`data_size-1:0]alu_result_MEM;
logic [`data_size-1:0]out_2_MEM;
//logic [4:0]write_reg_MEM;

always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
        mem_cs_MEM      <= 1'b0;
        mem_we_MEM      <= 4'b0;
        mem_oe_MEM      <= 1'b0;
        reg_write_MEM   <= 1'b0;
        reg_read_MEM    <= 1'b0;
        branch_MEM      <= 1'b0;
        jal_flag_MEM    <= 1'b0;
        branch_out_MEM  <= 32'b0;
        mem2reg_MEM     <= 2'b0;
        pc_4_MEM        <= 32'b0;
        alu_result_MEM  <= 32'b0;
        out_2_MEM       <= 32'b0;
        write_reg_MEM   <= 5'b0;
    end
    else begin
        mem_cs_MEM      <= mem_cs_EX;
        mem_we_MEM      <= mem_we_EX;
        mem_oe_MEM      <= mem_oe_EX;
        reg_write_MEM   <= reg_write_EX;
        reg_read_MEM    <= reg_read_EX;
        branch_MEM      <= branch_EX;
        jal_flag_MEM    <= jal_flag_EX;
        branch_out_MEM  <= branch_out;
        mem2reg_MEM     <= mem2reg_EX;
        pc_4_MEM        <= pc_4;
        alu_result_MEM  <= alu_result_auipc;
        out_2_MEM       <= out_2;
        write_reg_MEM   <= write_reg_EX;
    end
end

//======================MEM======================//
//logic pc_src;
logic branch_in;


assign DM_CS = mem_cs_MEM;
assign DM_OE = mem_oe_MEM;
assign DM_A  = alu_result_MEM[15:2];
assign DM_WEB = mem_we_MEM;
assign DM_DI = out_2_MEM;
assign branch_in = alu_result_MEM[0];
assign pc_src = (branch_in||jal_flag_MEM) && branch_MEM;
assign branch_result = branch_out_MEM;


//=====================MEM/WB=====================
//logic reg_write_WB;
//logic reg_read_WB;
logic [1:0]mem2reg_WB;
logic [`pc_size-1:0]pc_4_WB;
logic [`data_size-1:0]alu_result_WB;
logic [`data_size-1:0]branch_out_WB;
//logic [4:0]write_reg_WB;

always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
        reg_write_WB    <= 1'b0;
        reg_read_WB     <= 1'b0;
        mem2reg_WB      <= 1'b0;
        pc_4_WB         <= 32'b0;
        alu_result_WB   <= 32'b0;
        write_reg_WB    <= 5'b0;
        branch_out_WB   <=32'b0;
    end
    else begin
        reg_write_WB    <= reg_write_MEM;
        reg_read_WB     <= reg_read_MEM;
        mem2reg_WB      <= mem2reg_MEM;
        pc_4_WB         <= pc_4_MEM;
        alu_result_WB   <= alu_result_MEM;
        write_reg_WB    <= write_reg_MEM;
        branch_out_WB   <= branch_out_MEM;
    end
end

//======================WB======================//
//logic [`data_size-1:0]write_data;

assign write_data = (mem2reg_WB == 2'b00) ? alu_result_WB :
                    (mem2reg_WB == 2'b01) ? DM_DO :
                    (mem2reg_WB == 2'b10) ? pc_4_WB :
                                            branch_out_WB;








endmodule
