`timescale 1ns/10ps
`include "defines.sv"

module ALU_control( input [`instruction_size-1:0]ins,
                    output logic [3:0]OP);

logic [6:0]funct7;
logic [2:0]funct3;
logic [6:0]opcode;
assign funct7 = ins[31:25];
assign funct3 = ins[14:12];
assign opcode = ins[6:0];

always_comb begin
    case(opcode)
        `Rtype: begin //R-type I-type
            case(funct3)
                3'b000: begin
                    if(funct7==7'b0) OP = `ADD;
                    else OP = `SUB;
                end
                3'b001:     OP = `SLL;
                3'b010:     OP = `SLT;
                3'b011:     OP = `SLTU;
                3'b100:     OP = `XOR;
                3'b101: begin
                    if(funct7 == 7'b0) OP = `SRL;
                    else OP = `SRA;
                end
                3'b110:     OP = `OR;
                3'b111:     OP = `AND;
            endcase
        end
        `Itype: begin
            case(funct3)
                3'b000:     OP = `ADD;
                3'b010:     OP = `SLT;
                3'b011:     OP = `SLTU;
                3'b100:     OP = `XOR;
                3'b110:     OP = `OR;
                3'b111:     OP = `AND;
                3'b001:     OP = `SLL;
                3'b101: begin
                    if(funct7 == 7'b0) OP = `SRL;
                    else OP = `SRA;
                end
            endcase
        end
        `Stype, `ILtype: begin //store & load
            OP = `ADD;
        end
        `Btype: begin //B-type
            case(funct3)
                3'b000:     OP = `XOR;
                3'b001:     OP = `XOR;  //!XOR
                3'b100:     OP = `SLT;
                3'b101:     OP = `SLT;  //!SLT
                3'b110:     OP = `SLTU;
                3'b111:     OP = `SLTU; //!SLTU
                default:    OP = `AND;
            endcase
        end
        default: begin //U-type J-type
            OP = `ADD;
        end
    endcase
end
endmodule
