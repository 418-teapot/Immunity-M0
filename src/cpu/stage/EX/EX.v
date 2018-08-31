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
            // jump with link & logic
            `FUNCT_AND: result  <= operand_1 & operand_2;
            `FUNCT_OR:  result  <= operand_1 | operand_2;
            `FUNCT_XOR: result  <= operand_1 ^ operand_2;
            `FUNCT_NOR: result  <= ~(operand_1 | operand_2);

            // shift
            `FUNCT_SLL: result  <= operand_2 << shamt;
            `FUNCT_SRL: result  <= operand_2 >> shamt;
            `FUNCT_SRA: result  <= ({32{operand_2[31]}} << (6'd32 - {1'b0, shamt})) | operand_2 >> shamt;
            `FUNCT_SLLV: result <= operand_2 << operand_1[4:0];
            `FUNCT_SRLV: result <= operand_2 >> operand_1[4:0];
            `FUNCT_SRAV: result <= ({32{operand_2[31]}} << (6'd32 - {1'b0, operand_1[4:0]})) | operand_2 >> operand_1[4:0];

            default:    result  <= `ZERO_WORD;

        endcase
    end

endmodule