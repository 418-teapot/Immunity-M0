`timescale 1ns / 1ps

`include "../../define/global_def.v"
`include "../../define/funct_def.v"

module  EX(
    input   wire            rst,

    // from ID stage
    input   wire[`FUNCT_BUS]    funct,
    input   wire[`DATA_BUS]     operand_1,
    input   wire[`DATA_BUS]     operand_2,
    input   wire[`SHAMT_BUS]    shamt,
    input   wire                write_reg_en_in,
    input   wire[`REG_ADDR_BUS] write_reg_addr_in,

    // to MEM stage
    output  wire[`DATA_BUS]     result_out,
    output  wire                write_reg_en_out,
    output  wire[`REG_ADDR_BUS] write_reg_addr_out
);

    reg [`DATA_BUS] result;

    assign  write_reg_en_out    = (rst == `RST_ENABLE) ? `WRITE_DISABLE : write_reg_en_in;
    assign  write_reg_addr_out  = (rst == `RST_ENABLE) ? `ZERO_REG_ADDR : write_reg_addr_in;
    assign  result_out          = (rst == `RST_ENABLE) ? `ZERO_WORD     : result;

    // generate result
    always @ (*)    begin
        case (funct)

            `FUNCT_OR:  begin
                result  <= (operand_1 | operand_2);
            end

            default:    begin
                result  <= `ZERO_WORD;
            end

        endcase
    end

endmodule