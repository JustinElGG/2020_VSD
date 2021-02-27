`timescale 1ns/10ps
`include  "defines.sv"


module reg_32x32(   input clk,
                    input rst,
                    input write,
                    input read,
                    input [`addr_size-1:0] read_addr_1,
                    input [`addr_size-1:0] read_addr_2,
                    input [`addr_size-1:0] write_addr,
                    input [`data_size-1:0] data_in,
                    output logic [`data_size-1:0] out_1,
                    output logic [`data_size-1:0] out_2);
    
    logic [`data_size-1:0] RF [`reg_size-1:0];
    integer i;
    always_ff@(posedge clk, posedge rst) begin //read reg -> flipflop
        if(rst) begin
            for(i=0; i<`reg_size; i=i+1) begin
                RF[i] <= 'd0;
            end
        end
        else begin
            if(write) begin
                if(write_addr != 5'd0)
                    RF[write_addr] <= data_in;
            end
        end
    end

    always_comb begin //write reg -> comb
        if(read) begin
            if(read_addr_1 == 5'b0) out_1 = 32'b0;
            else out_1 = RF[read_addr_1];
            if(read_addr_2 == 5'b0) out_2 = 32'b0;
            else out_2 = RF[read_addr_2];
        end
    end

endmodule
