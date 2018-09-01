`timescale 1ns / 1ps

`include "../../define/global_def.v"
`include "../../define/funct_def.v"

module  EX(
    input   wire                rst,

    // from ID stage
    input   wire[`FUNCT_BUS]    funct,
    input   wire[`DATA_BUS]     operand_1,
    input   wire[`DATA_BUS]     operand_2,
    input   wire[`SHAMT_BUS]    shamt,
    input   wire                write_reg_en_in,
    input   wire[`REG_ADDR_BUS] write_reg_addr_in,

    // from HILOReadProxy
    input   wire[`DATA_BUS]     hi_val_mux_data,
    input   wire[`DATA_BUS]     lo_val_mux_data,

    // to MEM stage
    output  wire[`DATA_BUS]     result_out,
    output  wire                write_reg_en_out,
    output  wire[`REG_ADDR_BUS] write_reg_addr_out,
    output  reg                 write_hilo_en_out,
    output  reg [`DATA_BUS]     write_hi_data_out,
    output  reg [`DATA_BUS]     write_lo_data_out
);

    reg [`DATA_BUS] result;
    reg             write_reg_en;

    assign  write_reg_en_out    = (rst == `RST_ENABLE) ? `WRITE_DISABLE : write_reg_en;
    assign  write_reg_addr_out  = (rst == `RST_ENABLE) ? `ZERO_REG_ADDR : write_reg_addr_in;
    assign  result_out          = (rst == `RST_ENABLE) ? `ZERO_WORD     : result;

    // sum of operand_1 & operand_2
    wire[`DATA_BUS] result_sum;
    // flag of overflow
    wire    overflow_sum;
    // flag of operand_1 < operand_2
    wire    operand_1_lt_operand_2;
    // product of operand_1 & operand_2
    wire[`DOUBLE_DATA_BUS]  result_mult;   
    // bit counts of operand_1
    wire[`DATA_BUS] result_count;

    Adder   adder0(
        .funct                  (funct),
        .operand_1              (operand_1),
        .operand_2              (operand_2),
        .result_sum             (result_sum),
        .overflow_sum           (overflow_sum),
        .operand_1_lt_operand_2 (operand_1_lt_operand_2)
    );

    Multiplier  multiplier0(
        .rst            (rst),
        .funct          (funct),
        .operand_1      (operand_1),
        .operand_2      (operand_2),
        .result_mult    (result_mult)
    );

    BitCounter  bitcounter0(
        .funct          (funct),
        .operand_1      (operand_1),
        .result_count   (result_count)
    );

    // generate result
    always @ (*)    begin
        case (funct)
            // jump with link & logic
            `FUNCT_AND:     result  <= operand_1 & operand_2;
            `FUNCT_OR:      result  <= operand_1 | operand_2;
            `FUNCT_XOR:     result  <= operand_1 ^ operand_2;
            `FUNCT_NOR:     result  <= ~(operand_1 | operand_2);
            // shift
            `FUNCT_SLL:     result  <= operand_2 << shamt;
            `FUNCT_SRL:     result  <= operand_2 >> shamt;
            `FUNCT_SRA:     result  <= ({32{operand_2[31]}} << (6'd32 - {1'b0, shamt})) | operand_2 >> shamt;
            `FUNCT_SLLV:    result <= operand_2 << operand_1[4:0];
            `FUNCT_SRLV:    result <= operand_2 >> operand_1[4:0];
            `FUNCT_SRAV:    result <= ({32{operand_2[31]}} << (6'd32 - {1'b0, operand_1[4:0]})) | operand_2 >> operand_1[4:0];
            // move
            `FUNCT_MOVN, `FUNCT_MOVZ:   
                            result  <= operand_1;
            // HI & LO
            `FUNCT_MFHI:    result <= hi_val_mux_data;
            `FUNCT_MFLO:    result <= lo_val_mux_data;
            // arithmetic
            `FUNCT_ADD, `FUNCT_ADDU, `FUNCT_SUB, `FUNCT_SUBU:
                            result  <= result_sum;
            // comparison
            `FUNCT_SLT, `FUNCT_SLTU:
                            result  <= operand_1_lt_operand_2;
            // mult
            `FUNCT2_MUL:    result  <= result_mult[31:0];
            // bit count
            `FUNCT2_CLZ, `FUNCT2_CLO:
                            result  <= result_count;
            default:        result  <= `ZERO_WORD;
        endcase
    end

    // generate write_reg_en
    always @ (*)    begin
        case (funct)
            `FUNCT_MOVN:    write_reg_en <= (operand_2 == `ZERO_WORD) ? `WRITE_DISABLE : `WRITE_ENABLE;
            `FUNCT_MOVZ:    write_reg_en <= (operand_2 == `ZERO_WORD) ? `WRITE_ENABLE : `WRITE_DISABLE;
            `FUNCT_ADD, `FUNCT_SUB:
                            write_reg_en <= !overflow_sum;
            `FUNCT_MULT, `FUNCT_MULTU:
                            write_reg_en <= `WRITE_DISABLE;
            default:        write_reg_en <= write_reg_en_in;
        endcase
    end

    // generate HI & LO write information
    always @ (*)    begin
        case (funct)
            `FUNCT_MTHI:    begin
                write_hilo_en_out   <= `WRITE_ENABLE;
                write_hi_data_out   <= operand_1;
                write_lo_data_out   <= lo_val_mux_data;
            end
            `FUNCT_MTLO:    begin
                write_hilo_en_out   <= `WRITE_ENABLE;
                write_hi_data_out   <= hi_val_mux_data;
                write_lo_data_out   <= operand_1;
            end
            `FUNCT_MULT, `FUNCT_MULTU:  begin
                write_hilo_en_out   <= `WRITE_ENABLE;
                write_hi_data_out   <= result_mult[63:32];
                write_lo_data_out   <= result_mult[31:0];
            end
            default:    begin
                write_hilo_en_out   <= `WRITE_DISABLE;
                write_hi_data_out   <= hi_val_mux_data;
                write_lo_data_out   <= lo_val_mux_data;
            end
        endcase
    end

endmodule