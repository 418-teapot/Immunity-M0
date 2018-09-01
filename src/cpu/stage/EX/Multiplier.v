`timescale 1ns / 1ps

`include "../../define/global_def.v"
`include "../../define/funct_def.v"

module  Multiplier(
    input   wire                    rst,
    input   wire[`FUNCT_BUS]        funct,
    input   wire[`DATA_BUS]         operand_1,
    input   wire[`DATA_BUS]         operand_2,
    output  reg [`DOUBLE_DATA_BUS]  result_mult
);

    wire[`DATA_BUS] multiplicand    = (((funct == `FUNCT2_MUL) || (funct == `FUNCT_MULT)) && operand_1[31]) ? (~operand_1 + 1) : operand_1;
    wire[`DATA_BUS] multiplicator   = (((funct == `FUNCT2_MUL) || (funct == `FUNCT_MULT)) && operand_2[31]) ? (~operand_2 + 1) : operand_2;

    wire[`DOUBLE_DATA_BUS]  result_mult_temp = multiplicand * multiplicator;

    always @ (*)    begin
        if (rst == `RST_ENABLE) begin
            result_mult <= {`ZERO_WORD, `ZERO_WORD};
        end else if (funct == `FUNCT2_MUL || funct == `FUNCT_MULT)  begin
            if (operand_1[31] ^ operand_2[31])  begin
                result_mult <= ~result_mult_temp + 1;
            end else    begin
                result_mult <= result_mult_temp;
            end
        end else    begin // `FUNCT_MULTU
            result_mult <= result_mult_temp;
        end
    end

endmodule