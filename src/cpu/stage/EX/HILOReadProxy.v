`timescale 1ns / 1ps

`include "../../define/global_def.v"

module  HILOReadProxy(
    // input from HI & LO register
    input   wire[`DATA_BUS] read_hi_data,
    input   wire[`DATA_BUS] read_lo_data,

    // input from MEM stage
    input   wire            mem_write_hilo_en,
    input   wire[`DATA_BUS] mem_write_hi_data,
    input   wire[`DATA_BUS] mem_write_lo_data,

    // input from WB stage
    input   wire            wb_write_hilo_en,
    input   wire[`DATA_BUS] wb_write_hi_data,
    input   wire[`DATA_BUS] wb_write_lo_data,

    // data output
    output  reg [`DATA_BUS] hi_val_mux_data,
    output  reg [`DATA_BUS] lo_val_mux_data
);

    // generate output
    always @ (*)    begin
        if (mem_write_hilo_en == `WRITE_ENABLE)    begin
            hi_val_mux_data <= mem_write_hi_data;
            lo_val_mux_data <= mem_write_lo_data;
        end else if (wb_write_hilo_en == `WRITE_ENABLE)     begin
            hi_val_mux_data <= wb_write_hi_data;
            lo_val_mux_data <= wb_write_lo_data;
        end else    begin
            hi_val_mux_data <= read_hi_data;
            lo_val_mux_data <= read_lo_data;
        end
    end

endmodule