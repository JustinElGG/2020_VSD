`timescale 1ns/10ps
`include "defines.sv"
`include "CPU.sv"
`include "SRAM_wrapper.sv"


module top( input clk,
            input rst );

logic IM_CS;
logic IM_OE;
logic [`sram_addr_size-1:0]IM_A;
logic [3:0]IM_WEB;
logic [`data_size-1:0]IM_DI;
logic [`data_size-1:0]IM_DO;
logic DM_CS;
logic DM_OE;
logic [`sram_addr_size-1:0]DM_A;
logic [3:0]DM_WEB;
logic [`data_size-1:0]DM_DI;
logic [`data_size-1:0]DM_DO;

logic clk_;
assign clk_ = ~clk;

CPU cpu(.clk(clk),
        .rst(rst),
        .IM_CS(IM_CS),
        .IM_OE(IM_OE),
        .IM_A(IM_A),
        .IM_WEB(IM_WEB),
        .IM_DI(IM_DI),
        .IM_DO(IM_DO),
        .DM_CS(DM_CS),
        .DM_OE(DM_OE),
        .DM_A(DM_A),
        .DM_WEB(DM_WEB),
        .DM_DI(DM_DI),
        .DM_DO(DM_DO)
        );

SRAM_wrapper IM1(.CK(clk_),
                 .CS(IM_CS),
                 .OE(IM_OE),
                 .WEB(IM_WEB),
                 .A(IM_A),
                 .DI(IM_DI),
                 .DO(IM_DO)
                 );


SRAM_wrapper DM1(.CK(clk_),
                 .CS(DM_CS),
                 .OE(DM_OE),
                 .WEB(DM_WEB),
                 .A(DM_A),
                 .DI(DM_DI),
                 .DO(DM_DO)
                 );


endmodule
