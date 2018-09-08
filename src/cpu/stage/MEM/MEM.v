`timescale 1ns / 1ps

`include "../../define/global_def.v"

module  MEM(
    input   wire                rst,

    // from RAM
    input   wire[`DATA_BUS]     ram_read_data,

    // from EX stage
    input   wire                ram_en_in,
    input   wire                ram_write_en_in,
    input   wire[3:0]           ram_write_sel_in,
    input   wire[`DATA_BUS]     ram_write_data_in,

    input   wire[`DATA_BUS]     result_in,
    input   wire                write_reg_en_in,
    input   wire[`REG_ADDR_BUS] write_reg_addr_in,
    input   wire                write_hilo_en_in,
    input   wire[`DATA_BUS]     write_hi_data_in,
    input   wire[`DATA_BUS]     write_lo_data_in,

    // to RAM
    output  wire                ram_en_out,
    output  wire                ram_write_en_out,
    output  wire[3:0]           ram_write_sel_out,
    output  wire[`ADDR_BUS]     ram_write_addr_out,
    output  wire[`DATA_BUS]     ram_write_data_out,

    // to WB stage
    output  wire[`DATA_BUS]     result_out,
    output  wire                write_reg_en_out,
    output  wire[`REG_ADDR_BUS] write_reg_addr_out,
    output  wire                write_hilo_en_out,
    output  wire[`DATA_BUS]     write_hi_data_out,
    output  wire[`DATA_BUS]     write_lo_data_out
);

    assign  result_out          = (rst == `RST_ENABLE) ? `ZERO_WORD     :
                                  (ram_en_in == `CHIP_DISABLE) ? result_in : ram_read_data;
    assign  write_reg_en_out    = (rst == `RST_ENABLE) ? `WRITE_DISABLE : write_reg_en_in;
    assign  write_reg_addr_out  = (rst == `RST_ENABLE) ? `ZERO_REG_ADDR : write_reg_addr_in;
    assign  write_hilo_en_out   = (rst == `RST_ENABLE) ? `WRITE_DISABLE : write_hilo_en_in;
    assign  write_hi_data_out   = (rst == `RST_ENABLE) ? `ZERO_WORD     : write_hi_data_in;
    assign  write_lo_data_out   = (rst == `RST_ENABLE) ? `ZERO_WORD     : write_lo_data_in;

    assign  ram_en_out          = (rst == `RST_ENABLE) ? `CHIP_DISABLE  : ram_en_in;
    assign  ram_write_en_out    = (rst == `RST_ENABLE) ? `WRITE_DISABLE : ram_write_en_in;
    assign  ram_write_sel_out   = (rst == `RST_ENABLE) ? 4'b0000        : ram_write_sel_in;
    assign  ram_write_addr_out  = (rst == `RST_ENABLE) ? `ZERO_WORD     : result_in;
    assign  ram_write_data_out  = (rst == `RST_ENABLE) ? `ZERO_WORD     : ram_write_data_in;

endmodule