`timescale 1ns / 1ps

`include "../../define/global_def.v"
`include "../../define/op_def.v"
`include "../../define/funct_def.v"
`include "../../define/segpos_def.v"

module  ID(
    input   wire                rst,

    // from IF stage
    input   wire[`ADDR_BUS]     addr,
    input   wire[`INST_BUS]     inst,

    // from RegReadProxy
    input   wire[`DATA_BUS]     reg_val_mux_data_1,
    input   wire[`DATA_BUS]     reg_val_mux_data_2,

    // from or to RegFile
    output  reg                 reg_read_en_1,
    output  reg [`REG_ADDR_BUS] reg_addr_1,
    output  reg                 reg_read_en_2,
    output  reg [`REG_ADDR_BUS] reg_addr_2,

    // to EX stage
    output  reg [`FUNCT_BUS]    funct,
    output  reg [`DATA_BUS]     operand_1,
    output  reg [`DATA_BUS]     operand_2,
    output  reg [`SHAMT_BUS]    shamt,
    output  reg                 write_reg_en,
    output  reg [`REG_ADDR_BUS] write_reg_addr
);

    wire                    inst_r;
    wire                    inst_i;
    wire                    inst_j = `FALSE;
    wire[`INST_OP_TYPE_BUS] op_type = {inst_r, inst_i, inst_j};

    wire                    i_reg_read_en_1;
    wire[`REG_ADDR_BUS]     i_reg_addr_1;
    wire                    i_reg_read_en_2;
    wire[`REG_ADDR_BUS]     i_reg_addr_2;
    wire[`FUNCT_BUS]        i_funct;
    wire[`DATA_BUS]         i_operand_1;
    wire[`DATA_BUS]         i_operand_2;
    wire                    i_write_reg_en;
    wire[`REG_ADDR_BUS]     i_write_reg_addr;

    wire                    r_reg_read_en_1;
    wire[`REG_ADDR_BUS]     r_reg_addr_1;
    wire                    r_reg_read_en_2;
    wire[`REG_ADDR_BUS]     r_reg_addr_2;
    wire[`FUNCT_BUS]        r_funct;
    wire[`DATA_BUS]         r_operand_1;
    wire[`DATA_BUS]         r_operand_2;
    wire[`SHAMT_BUS]        r_shamt;
    wire                    r_write_reg_en;
    wire[`REG_ADDR_BUS]     r_write_reg_addr;

    ID_I    id_i0(
        .rst                (rst),

        // to ID
        .inst_i             (inst_i),

        // from IF stage
        .inst               (inst),

        // from RegReadProxy
        .reg_val_mux_data_1 (reg_val_mux_data_1),

        // from or to RegFile
        .reg_read_en_1      (i_reg_read_en_1),
        .reg_addr_1         (i_reg_addr_1),
        .reg_read_en_2      (i_reg_read_en_2),
        .reg_addr_2         (i_reg_addr_2),

        // to EX stage
        .funct              (i_funct),
        .operand_1          (i_operand_1),
        .operand_2          (i_operand_2),
        .write_reg_en       (i_write_reg_en),
        .write_reg_addr     (i_write_reg_addr)
    );

    ID_R    id_r0(
        .rst                (rst),

        // to ID
        .inst_r             (inst_r),

        // from IF stage
        .addr               (addr),
        .inst               (inst),

        // from RegReadProxy
        .reg_val_mux_data_1 (reg_val_mux_data_1),
        .reg_val_mux_data_2 (reg_val_mux_data_2),

        // from or to RegFile
        .reg_read_en_1      (r_reg_read_en_1),
        .reg_addr_1         (r_reg_addr_1),
        .reg_read_en_2      (r_reg_read_en_2),
        .reg_addr_2         (r_reg_addr_2),

        // to EX stage
        .funct              (r_funct),
        .operand_1          (r_operand_1),
        .operand_2          (r_operand_2),
        .shamt              (r_shamt),
        .write_reg_en       (r_write_reg_en),
        .write_reg_addr     (r_write_reg_addr)
    );

    always @ (*)    begin
        case (op_type)
            
            `TYPE_R:    begin
                reg_read_en_1   <= r_reg_read_en_1;
                reg_addr_1      <= r_reg_addr_1;
                reg_read_en_2   <= r_reg_read_en_2;
                reg_addr_2      <= r_reg_addr_2;
                funct           <= r_funct;
                operand_1       <= r_operand_1;
                operand_2       <= r_operand_2;
                shamt           <= r_shamt;
                write_reg_en    <= r_write_reg_en;
                write_reg_addr  <= r_write_reg_addr;
            end

            `TYPE_I:    begin
                reg_read_en_1   <= i_reg_read_en_1;
                reg_addr_1      <= i_reg_addr_1;
                reg_read_en_2   <= i_reg_read_en_2;
                reg_addr_2      <= i_reg_addr_2;
                funct           <= i_funct;
                operand_1       <= i_operand_1;
                operand_2       <= i_operand_2;
                shamt           <= `SHAMT_BUS_WIDTH'b0;
                write_reg_en    <= i_write_reg_en;
                write_reg_addr  <= i_write_reg_addr;
            end

            default:    begin
                reg_read_en_1   <= `READ_DISABLE;
                reg_addr_1      <= `ZERO_REG_ADDR;
                reg_read_en_2   <= `READ_DISABLE;
                reg_addr_2      <= `ZERO_REG_ADDR;
                funct           <= `FUNCT_NOP;
                operand_1       <= `ZERO_WORD;
                operand_2       <= `ZERO_WORD;
                shamt           <= `SHAMT_BUS_WIDTH'b0;
                write_reg_en    <= `WRITE_DISABLE;
                write_reg_addr  <= `ZERO_REG_ADDR;
            end

        endcase
    end
    
endmodule