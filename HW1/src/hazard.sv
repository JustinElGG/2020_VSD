`timescale 1ns/10ps
`include "defines.sv"

module hazard(  input [4:0]read_addr_1,
                input [4:0]read_addr_2,
                input [4:0]write_reg_EX,
                input mem_oe_EX,
                output logic stall);               

always_comb begin
    if(mem_oe_EX) begin
        if( (read_addr_1 == write_reg_EX) || (read_addr_2 == write_reg_EX) ) begin
            stall = 1'b1;
        end
        else begin
            stall = 1'b0;
        end
    end
    else begin
        stall = 1'b0;
    end
end
endmodule
