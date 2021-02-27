`ifndef DEFINES_V
`define DEFINES_V

`define addr_size 32'd5
`define data_size 32'd32
`define reg_size 32'd32
`define pc_size 32'd32
`define sram_addr_size 32'd14
`define instruction_size 32'd32
`define imm_size 32'd32

//OP: operations
`define ADD  4'd0
`define SUB  4'd1
`define SLL  4'd2
`define SLT  4'd3
`define SLTU 4'd4
`define XOR  4'd5
`define SRL  4'd6
`define SRA  4'd7
`define OR   4'd8
`define AND  4'd9

//funct3 for B-type
`define BEQ  3'b000
`define BNE  3'b001
`define BLT  3'b100
`define BGE  3'b101
`define BLTU 3'b110
`define BGEU 3'b111

//opcode
`define Rtype  7'b0110011
`define Itype  7'b0010011
`define ILtype 7'b0000011
`define IJtype 7'b1100111
`define Stype  7'b0100011
`define Btype  7'b1100011
`define Utype  7'b0010111 //AUIPC
`define ULtype 7'b0110111 //LUI
`define Jtype  7'b1101111






`endif
