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
`include "hazard.sv"

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
logic flush;
logic flush_index;
logic stall;
logic stall_on;
logic stall_EX;
assign stall_on = stall;

logic [`pc_size-1:0]pc;
logic [`pc_size-1:0]pc_;
logic [`pc_size-1:0]pc_next;
logic [`pc_size-1:0]pc_next_;
logic [`pc_size-1:0]pc_add4;
logic pc_src;
logic [`data_size-1:0]branch_result;

always_ff @(posedge clk) begin
    if(rst) begin
        pc  <= 32'b0;
    end
    else begin
        pc  <= pc_next_;
    end
end

always_comb begin
    if(stall_on) begin
        pc_next_ = pc;
    end
    else begin
        pc_next_ = pc_next;
    end
end

assign IM_CS   = 1'b1; //always on
assign IM_OE   = 1'b1; //
assign IM_A    = pc[15:2];
assign IM_WEB  = 4'b1111;    //instruction memory is unwritable
assign IM_DI   = 32'b0;       //write in data is dont care
assign pc_add4 = pc+4;
assign pc_next = pc_src ? branch_result : pc_add4;


//=====================IF/ID=====================//
logic [`pc_size-1:0]pc_ID;
logic [`pc_size-1:0]pc_add4_ID;
logic [`instruction_size-1:0]ins_ID;
logic [`instruction_size-1:0]ins_ID_;
always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
        pc_ID       <= 32'b0;
        pc_add4_ID  <= 32'b0;
        ins_ID      <= 32'b0;
    end
    else begin
        if(stall_on) begin
            pc_ID       <= pc_ID;   //dont need to stall??????
            pc_add4_ID  <= pc_add4_ID;
            ins_ID      <= ins_ID;
            //pc_ID  <= pc_;
            //ins_ID <= IM_DO;
        end
        else if(flush) begin  //dont need to flush here?
            pc_ID       <= 32'b0;
            pc_add4_ID  <= 32'b0;
            ins_ID       <= 32'b0;
        end
        else begin
            pc_ID       <= pc; //may fault og is 'pc_'
            pc_add4_ID  <= pc_add4;
            ins_ID      <= IM_DO;
        end
    end
end


//======================ID======================//
////wires
//wire for control
logic [6:0]opcode;
logic mem_cs;
logic [3:0]mem_we;
logic mem_oe;
logic mem_oe_EX;
logic reg_write;
logic reg_read;
logic [1:0]sel_branch;
logic alu_src;
logic [1:0]mem2reg;
logic [1:0]rdsrc;
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
//bytewies load store
logic store_byte;
logic load_byte;
//wire for imm gen
logic [`imm_size-1:0]imm;
logic auipc_sel;
logic shift_op;
//// assign
assign opcode = ins_ID[6:0];
assign read_addr_1 = ins_ID[19:15];
assign read_addr_2 = ins_ID[24:20];
assign reg_read_1  = 1'b1;

control control(    .opcode(opcode), .funct3(ins_ID[14:12]), .mem_cs(mem_cs), .mem_we(mem_we), .mem_oe(mem_oe),
                    .store_byte(store_byte), .load_byte(load_byte), .rdsrc(rdsrc),
                    .reg_write(reg_write), .reg_read(reg_read), .branch(branch), .jal_flag(jal_flag), .auipc_sel(auipc_sel), 
                    .sel_branch(sel_branch), .alu_src(alu_src), .mem2reg(mem2reg), .shift_op(shift_op));
reg_32x32 register( .clk(clk), .rst(rst), .write(reg_write_WB), .read(reg_read_1), .read_addr_1(read_addr_1),
                    .read_addr_2(read_addr_2), .write_addr(write_reg_WB), .data_in(write_data),
                    .out_1(out_1), .out_2(out_2));

imm_gen imm_gen(    .ins(ins_ID), .shift_op(shift_op), .imm(imm) );

//stall------------------------------------------
logic [`instruction_size-1:0]ins_EX;
logic [`addr_size-1:0]write_reg_EX;
logic [6:0]opcode_EX;
assign opcode_EX = ins_EX[6:0];

logic [`addr_size-1:0]read_addr_1_EX;
logic [`addr_size-1:0]read_addr_2_EX;
logic [`addr_size-1:0]write_reg_MEM;
logic [6:0]opcode_MEM;

hazard hazard(  .read_addr_1(read_addr_1), .read_addr_2(read_addr_2),
                .write_reg_EX(write_reg_EX), .mem_oe_EX(mem_oe_EX), .stall(stall) );

//-----------------------------------------------

//flush unit-------------------------------------
logic flush_MEM;
logic flush_WB;
always_comb begin
    if(pc_src) flush = 1'b1;
    else flush = 1'b0;
end
assign flush_index = (flush | flush_MEM);
//-----------------------------------------------
//=====================ID/EX=====================
logic [`pc_size-1:0]pc_add4_EX;
logic mem_cs_EX;
logic [3:0]mem_we_EX;
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
logic [`data_size-1:0]out_1_EX;
logic [`data_size-1:0]out_2_EX;
logic store_byte_EX;
logic load_byte_EX;
logic [1:0]rdsrc_EX;

always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
        pc_add4_EX      <= 32'b0;
        mem_cs_EX       <= 1'b0;
        mem_we_EX       <= 4'b1111;
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
        out_1_EX        <= 32'b0;
        out_2_EX        <= 32'b0;
        store_byte_EX   <= 1'b0;
        load_byte_EX    <= 1'b0;
        stall_EX        <= 1'b0;
        rdsrc_EX        <= 2'b0;
    end
    else begin
        if(flush_index) begin
            mem_cs_EX       <= 1'b0;
            mem_we_EX       <= 4'b1111;
            mem_oe_EX       <= 1'b0;
            reg_write_EX    <= 1'b0;
            reg_read_EX     <= 1'b0;
            branch_EX       <= 1'b0;
            jal_flag_EX     <= 1'b0;
            auipc_sel_EX    <= 1'b0;
            sel_branch_EX   <= 2'b00;
            alu_src_EX      <= 1'b0;
            mem2reg_EX      <= 2'b00;
            /*
            pc_EX           <= pc_ID;
            pc_add4_EX      <= pc_add4;
            imm_EX          <= imm;
            ins_EX          <= ins_ID;
            write_reg_EX    <= ins_ID[11:7];
            read_addr_1_EX  <= read_addr_1;
            read_addr_2_EX  <= read_addr_2;
            out_1_EX        <= out_1;
            out_2_EX        <= out_2;
            */
            pc_EX           <= 32'b0;
            pc_add4_EX      <= 32'b0;
            imm_EX          <= 32'b0;
            ins_EX          <= 32'b0;
            write_reg_EX    <= 5'd0;
            read_addr_1_EX  <= 5'd0;
            read_addr_2_EX  <= 5'd0;
            out_1_EX        <= 32'b0;
            out_2_EX        <= 32'b0;
            store_byte_EX   <= 1'b0;
            load_byte_EX    <= 1'b0;
            stall_EX        <= 1'b0;
            rdsrc_EX         <= 2'b0;
        end
        else if(stall_on) begin
            
            mem_cs_EX       <= 1'b0;
            mem_we_EX       <= 4'b1111;
            mem_oe_EX       <= 1'b0;
            reg_write_EX    <= 1'b0;
            reg_read_EX     <= 1'b0;
            branch_EX       <= 1'b0;
            jal_flag_EX     <= 1'b0;
            auipc_sel_EX    <= 1'b0;
            sel_branch_EX   <= 2'b00;
            alu_src_EX      <= 1'b0;
            mem2reg_EX      <= 2'b00;
            pc_EX           <= 32'b0;
            pc_add4_EX      <= 32'b0;
            imm_EX          <= 32'b0;
            ins_EX          <= 32'b0;
            write_reg_EX    <= 5'b0;
            read_addr_1_EX  <= 5'b0;
            read_addr_2_EX  <= 5'b0;
            out_1_EX        <= 32'b0;
            out_2_EX        <= 32'b0;
            store_byte_EX   <= 1'b0;
            load_byte_EX    <= 1'b0;
            stall_EX        <= stall;
            rdsrc_EX        <= 2'b0;
            /*
            mem_cs_EX       <= 1'b0;    //if stall, inst would come again next cycle,
            mem_we_EX       <= 4'b1111; //so no need to pass any control signal.
            mem_oe_EX       <= 1'b0;
            reg_write_EX    <= 1'b0;
            reg_read_EX     <= 1'b0;
            branch_EX       <= 1'b0;
            jal_flag_EX     <= 1'b0;
            auipc_sel_EX    <= 1'b0;
            sel_branch_EX   <= 2'b0;
            alu_src_EX      <= 1'b0;
            mem2reg_EX      <= 2'b0;
            pc_EX           <= pc_EX;
            imm_EX          <= imm_EX;
            ins_EX          <= ins_EX;
            write_reg_EX    <= write_reg_EX;
            read_addr_1_EX  <= read_addr_1_EX;
            read_addr_2_EX  <= read_addr_2_EX;
            out_1_EX        <= out_1_EX;
            out_2_EX        <= out_2_EX;
            store_byte_EX   <= 1'b0;
            load_byte_EX    <= 1'b0;
            */
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
            pc_add4_EX      <= pc_add4_ID;
            imm_EX          <= imm;
            ins_EX          <= ins_ID;
            write_reg_EX    <= ins_ID[11:7];
            read_addr_1_EX  <= read_addr_1;
            read_addr_2_EX  <= read_addr_2;
            out_1_EX        <= out_1;
            out_2_EX        <= out_2;
            store_byte_EX   <= store_byte;
            load_byte_EX    <= load_byte;
            stall_EX        <= stall;
            rdsrc_EX        <= rdsrc;
        end
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

logic [`data_size-1:0]alu_result_MEM;
logic [`data_size-1:0]out_1_for;
logic [`data_size-1:0]out_2_for;

assign alu_enable = 1'b1;
assign src2_ = alu_src_EX ? imm_EX : out_2_for;
assign alu_result_auipc = (auipc_sel_EX == 1'b1) ? branch_out : alu_result;

//// do PC jump a cycle earlier
logic branch_in;
//assign branch_in = alu_result_[0];
assign branch_in = |alu_result_;
assign pc_src = (branch_in||jal_flag_EX) && branch_EX;
assign branch_result = branch_out;

////forwarding
logic [`data_size-1:0]write_data_buf;
logic [4:0]write_reg_buf;
logic reg_write_buf;

always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
        write_data_buf <= 32'b0;
        write_reg_buf  <= 5'b0;
        reg_write_buf  <= 1'b0;
    end
    else begin
        if(stall) begin
            write_data_buf <= write_data_buf;
            write_reg_buf  <= write_reg_buf;
            reg_write_buf  <= reg_write_buf;
        end
        else begin
            write_data_buf <= write_data;
            write_reg_buf  <= write_reg_WB;
            reg_write_buf  <= reg_write_WB;
        end
    end
end

logic [`data_size-1:0]alu_result__MEM;
logic [`data_size-1:0]forward_MEM;
assign out_1_for = (reg1_sel == 2'b01) ? write_data_buf :
                   (reg1_sel == 2'b10) ? write_data :
                   (reg1_sel == 2'b11) ? forward_MEM :
                                         out_1_EX;

assign out_2_for = (reg2_sel == 2'b01) ? write_data_buf :
                   (reg2_sel == 2'b10) ? write_data :
                   (reg2_sel == 2'b11) ? forward_MEM :
                                         out_2_EX;
////

ALU alu( .src1(out_1_for), .src2(src2_), .OP(alu_op), .enable(alu_enable), .alu_result(alu_result), .Overflow(of) );
ALU_control alu_control( .ins(ins_EX), .OP(alu_op) );


add_sum add_sum( .pc(pc_EX), .imm(imm_EX), .rs1_imm(alu_result), .select(sel_branch_EX), .pc_add(branch_out) );
branch_pos branch_pos( .ins(ins_EX), .ALU_result(alu_result_auipc), .branch_out(alu_result_) );

forwarding forwarding(  .read_addr_1_EX(read_addr_1_EX), .read_addr_2_EX(read_addr_2_EX),
                        .write_reg_MEM(write_reg_MEM), .write_reg_WB(write_reg_WB), .write_reg_buf(write_reg_buf),
                        .reg_write_MEM(reg_write_MEM), .reg_write_WB(reg_write_WB), .reg_write_buf(reg_write_buf),
                        .reg1_sel(reg1_sel), .reg2_sel(reg2_sel) );

//=====================EX/MEM=====================
logic mem_cs_MEM;
logic [3:0]mem_we_MEM;
logic mem_oe_MEM;
logic reg_read_MEM;
logic jal_flag_MEM;
logic [`data_size-1:0]branch_out_MEM;
logic [1:0]mem2reg_MEM;
logic [`pc_size-1:0]pc_add4_MEM;
logic [`data_size-1:0]out_2_MEM;
logic store_byte_MEM;
logic load_byte_MEM;
logic [`data_size-1:0]out_1_for_MEM;
logic [`data_size-1:0]out_2_for_MEM;
logic [1:0]rdsrc_MEM;

always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
        mem_cs_MEM      <= 1'b0;
        mem_we_MEM      <= 4'b1111;
        mem_oe_MEM      <= 1'b0;
        reg_write_MEM   <= 1'b0;
        reg_read_MEM    <= 1'b0;
        jal_flag_MEM    <= 1'b0;
        branch_out_MEM  <= 32'b0;
        mem2reg_MEM     <= 2'b0;
        pc_add4_MEM     <= 32'b0;
        alu_result_MEM  <= 32'b0;
        out_2_MEM       <= 32'b0;
        write_reg_MEM   <= 5'b0;
        flush_MEM       <= 1'b0;
        store_byte_MEM  <= 1'b0;
        load_byte_MEM   <= 1'b0;
        out_1_for_MEM   <= 32'b0;
        out_2_for_MEM   <= 32'b0;
        opcode_MEM      <= 7'b0;
        alu_result__MEM <= 32'b0;
        rdsrc_MEM       <= 2'b0;
    end
    else begin
        mem_cs_MEM      <= mem_cs_EX;
        mem_we_MEM      <= mem_we_EX;
        mem_oe_MEM      <= mem_oe_EX;
        reg_write_MEM   <= reg_write_EX;
        reg_read_MEM    <= reg_read_EX;
        jal_flag_MEM    <= jal_flag_EX;
        branch_out_MEM  <= branch_out;
        mem2reg_MEM     <= mem2reg_EX;
        pc_add4_MEM     <= pc_add4_EX;
        alu_result_MEM  <= alu_result_;
        out_2_MEM       <= out_2_EX;
        write_reg_MEM   <= write_reg_EX;
        flush_MEM       <= flush;
        store_byte_MEM  <= store_byte_EX;
        load_byte_MEM   <= load_byte_EX;
        out_1_for_MEM   <= out_1_for;
        out_2_for_MEM   <= out_2_for;
        opcode_MEM      <= opcode_EX;
        alu_result__MEM <= alu_result_auipc;
        rdsrc_MEM       <= rdsrc_EX;
    end
end

//======================MEM======================//
assign DM_CS  = mem_cs_MEM;
assign DM_OE  = mem_oe_MEM;
assign DM_A   = (mem_cs_MEM) ? alu_result_MEM[15:2] : 14'b0;

always_comb begin
    if(store_byte_MEM) begin        
        case(alu_result_MEM[1:0])
            
            2'b00: begin
                DM_WEB = 4'b1110;
                DM_DI  = {24'b0, out_2_for_MEM[7:0]};
            end
            2'b01: begin
                DM_WEB = 4'b1101;
                DM_DI  = {16'b0, out_2_for_MEM[7:0], 8'b0};
            end
            2'b10: begin
                DM_WEB = 4'b1011;
                DM_DI  = {8'b0, out_2_for_MEM[7:0], 16'b0};
            end
            2'b11: begin
                DM_WEB = 4'b0111;
                DM_DI  = {out_2_for_MEM[7:0], 24'b0};
            end
            /*
            2'b00: begin
                DM_WEB = 4'b1110;
                DM_DI  = {24'b0, out_2_for_MEM[7:0]};
            end
            2'b01: begin
                DM_WEB = 4'b1101;
                DM_DI  = {24'b0, out_2_for_MEM[15:8]};
            end
            2'b10: begin
                DM_WEB = 4'b1011;
                DM_DI  = {24'b0, out_2_for_MEM[23:9]};
            end
            2'b11: begin
                DM_WEB = 4'b0111;
                DM_DI  = {24'b0, out_2_for_MEM[31:24]};
            end
            */
        endcase
    end
    else begin
        DM_WEB = mem_we_MEM;
        DM_DI  = out_2_for_MEM;
    end
end
logic [`data_size-1:0]read_data;
always_comb begin
    if(load_byte_MEM) read_data = { {24{DM_DO[7]}}, DM_DO[7:0] };
    else read_data = DM_DO;
end

always_comb begin
    case(rdsrc_MEM) 
        2'b00:  forward_MEM = alu_result_MEM;
        2'b01:  forward_MEM = read_data;
        2'b10:  forward_MEM = pc_add4_MEM;
        2'b11:  forward_MEM = branch_out_MEM;
    endcase
end

//=====================MEM/WB=====================
logic [1:0]mem2reg_WB;
logic [`pc_size-1:0]pc_add4_WB;
logic [`data_size-1:0]alu_result_WB;
logic [`data_size-1:0]branch_out_WB;
logic [`data_size-1:0]read_data_WB;

always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
        reg_write_WB    <= 1'b0;
        reg_read_WB     <= 1'b0;
        mem2reg_WB      <= 2'b0;
        pc_add4_WB      <= 32'b0;
        alu_result_WB   <= 32'b0;
        write_reg_WB    <= 5'b0;
        branch_out_WB   <= 32'b0;
        flush_WB        <= 1'b0;
        read_data_WB    <= 32'b0;
    end
    else begin
        reg_write_WB    <= reg_write_MEM;
        reg_read_WB     <= reg_read_MEM;
        mem2reg_WB      <= mem2reg_MEM;
        pc_add4_WB      <= pc_add4_MEM;
        alu_result_WB   <= alu_result_MEM;
        write_reg_WB    <= write_reg_MEM;
        branch_out_WB   <= branch_out_MEM;
        flush_WB        <= flush_MEM;
        read_data_WB    <= read_data;
    end
end

//======================WB======================//
assign write_data = (mem2reg_WB == 2'b00) ? alu_result_WB :
                    (mem2reg_WB == 2'b01) ? read_data_WB :
                    (mem2reg_WB == 2'b10) ? pc_add4_WB :
                                            branch_out_WB;





endmodule
