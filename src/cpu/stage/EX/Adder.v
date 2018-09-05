`timescale 1ns / 1ps

`include "../../define/global_def.v"
`include "../../define/funct_def.v"

module  Adder(
    input   wire[`FUNCT_BUS]    funct,
    input   wire[`DATA_BUS]     operand_1,
    input   wire[`DATA_BUS]     operand_2,
    output  wire[`DATA_BUS]     result_sum,
    output  wire                overflow_sum,
    output  wire                operand_1_lt_operand_2
);

    
    // calculate the complement of operand_2
    wire[`DATA_BUS] operand_2_mux   = ((funct == `FUNCT_SUB)    ||
                                       (funct == `FUNCT_SUBU)   ||
                                       (funct == `FUNCT_SLT))   ?
                                       (~operand_2) + 1 : operand_2;
    
    // sum of operand_1 & operand_2
    assign  result_sum      = operand_1 + operand_2_mux;

    // flag of overflow
    assign  overflow_sum    = (!operand_1[31] && !operand_2_mux[31] &&  result_sum[31]) ||
                              ( operand_1[31] &&  operand_2_mux[31] && !result_sum[31]);
    
    // flag of operand_1 < operand_2
    assign  operand_1_lt_operand_2  = (funct == `FUNCT_SLT) ?
                                      (( operand_1[31] && !operand_2[31])   ||
                                       (!operand_1[31] && !operand_2[31] && result_sum[31]) ||
                                       ( operand_1[31] &&  operand_2[31] && result_sum[31]))
                                      : (operand_1 < operand_2);

endmodule