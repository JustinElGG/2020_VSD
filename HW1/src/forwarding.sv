`timescale 1ns/10ps
`include "defines.sv"

module forwarding(  input [4:0]read_addr_1_EX,
                    input [4:0]read_addr_2_EX,
                    input [4:0]write_reg_MEM,
                    input [4:0]write_reg_WB,
                    input [4:0]write_reg_buf,
                    input reg_write_MEM,
                    input reg_write_WB,
                    input reg_write_buf,
                    output logic [1:0]reg1_sel,
                    output logic [1:0]reg2_sel);

always_comb begin
    if(reg_write_MEM == 1'b1 && write_reg_MEM == read_addr_1_EX && write_reg_MEM != 5'b0) begin
        reg1_sel = 2'b11;
    end
    else if(reg_write_WB == 1'b1 && write_reg_WB == read_addr_1_EX && write_reg_WB != 5'b0) begin
        reg1_sel = 2'b10;
    end
    else if(reg_write_buf == 1'b1 && write_reg_buf == read_addr_1_EX && write_reg_buf != 5'b0) begin
        reg1_sel = 2'b01;
    end
    else begin  //default case. no frowarding
        reg1_sel = 2'b00;
    end
    ////---------------------------------------------------------------------////
    if(reg_write_MEM == 1'b1 && write_reg_MEM == read_addr_2_EX && write_reg_MEM != 5'b0) begin
        reg2_sel = 2'b11;
    end
    else if(reg_write_WB == 1'b1 && write_reg_WB == read_addr_2_EX && write_reg_WB != 5'b0) begin
        reg2_sel = 2'b10;
    end
    else if(reg_write_buf == 1'b1 && write_reg_buf == read_addr_2_EX && write_reg_buf != 5'b0) begin
        reg2_sel = 2'b01;
    end
    else begin  //default case. no frowarding
        reg2_sel = 2'b00;
    end
end
endmodule
