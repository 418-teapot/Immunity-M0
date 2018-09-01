`timescale 1ns / 1ps

`include "../../define/global_def.v"

module  WB(
    input   wire                rst,

    // from MEM stage
    input   wire[`DATA_BUS]     result_in,
    input   wire                write_reg_en_in,
    input   wire[`REG_ADDR_BUS] write_reg_addr_in,
    input   wire                write_hilo_en_in,
    input   wire[`DATA_BUS]     write_hi_data_in,
    input   wire[`DATA_BUS]     write_lo_data_in,

    // to RegFile
    output  wire[`DATA_BUS]     result_out,
    output  wire                write_reg_en_out,
    output  wire[`REG_ADDR_BUS] write_reg_addr_out,

    // to HILO
    output  wire                write_hilo_en_out,
    output  wire[`DATA_BUS]     write_hi_data_out,
    output  wire[`DATA_BUS]     write_lo_data_out
);

    assign  result_out          = (rst == `RST_ENABLE) ? `ZERO_WORD     : result_in;
    assign  write_reg_en_out    = (rst == `RST_ENABLE) ? `WRITE_DISABLE : write_reg_en_in;
    assign  write_reg_addr_out  = (rst == `RST_ENABLE) ? `ZERO_REG_ADDR : write_reg_addr_in;
    assign  write_hilo_en_out   = (rst == `RST_ENABLE) ? `WRITE_DISABLE : write_hilo_en_in;
    assign  write_hi_data_out   = (rst == `RST_ENABLE) ? `ZERO_WORD     : write_hi_data_in;
    assign  write_lo_data_out   = (rst == `RST_ENABLE) ? `ZERO_WORD     : write_lo_data_in;

endmodule