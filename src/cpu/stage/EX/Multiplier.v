`timescale 1ns / 1ps

`include "../../define/global_def.v"
`include "../../define/funct_def.v"

module  Multiplier(
    input   wire                    rst,

    // from ID stage
    input   wire[`FUNCT_BUS]        funct,
    input   wire[`DATA_BUS]         operand_1,
    input   wire[`DATA_BUS]         operand_2,

    // from HILOReadProxy
    input   wire[`DATA_BUS]         hi_val_mux_data,
    input   wire[`DATA_BUS]         lo_val_mux_data,

    // data output
    output  reg [`DOUBLE_DATA_BUS]  result_mult
);

    wire[`DATA_BUS] multiplicand    = (((funct == `FUNCT2_MUL)  || (funct == `FUNCT_MULT)   ||
                                        (funct == `FUNCT2_MADD) || (funct == `FUNCT2_MSUB)) && operand_1[31]) ? (~operand_1 + 1) : operand_1;
    wire[`DATA_BUS] multiplicator   = (((funct == `FUNCT2_MUL) || (funct == `FUNCT_MULT)    ||
                                        (funct == `FUNCT2_MADD) || (funct == `FUNCT2_MSUB)) && operand_2[31]) ? (~operand_2 + 1) : operand_2;

    wire[`DOUBLE_DATA_BUS]  result_mult_temp = multiplicand * multiplicator;

    always @ (*)    begin
        if (rst == `RST_ENABLE) begin
            result_mult         <= {`ZERO_WORD, `ZERO_WORD};
        end else    begin
            case (funct)

                `FUNCT2_MUL, `FUNCT_MULT:    begin
                    if (operand_1[31] ^ operand_2[31])
                            result_mult <= ~result_mult_temp + 1;
                    else    result_mult <= result_mult_temp;
                end

                `FUNCT2_MADD: begin
                    if (operand_1[31] ^ operand_2[31])
                            result_mult <= ~result_mult_temp + 1 + {hi_val_mux_data, lo_val_mux_data};
                    else    result_mult <= result_mult_temp + {hi_val_mux_data, lo_val_mux_data};
                end

                `FUNCT2_MADDU:  begin
                    result_mult         <= result_mult_temp + {hi_val_mux_data, lo_val_mux_data};
                end

                `FUNCT2_MSUB:    begin
                    if (operand_1[31] ^ operand_2[31])
                            result_mult <= result_mult_temp + {hi_val_mux_data, lo_val_mux_data};
                    else    result_mult <= ~result_mult_temp + 1 + {hi_val_mux_data, lo_val_mux_data};
                end

                `FUNCT2_MSUBU:  begin
                    result_mult         <= ~result_mult_temp + 1 + {hi_val_mux_data, lo_val_mux_data};
                end

                default:    begin   // `FUNCT_MULTU
                    result_mult         <= result_mult_temp;
                end
            
            endcase
        end
    end

endmodule