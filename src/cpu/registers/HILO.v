`timescale 1ns / 1ps

`include "../define/global_def.v"

module  HILO(
    input   wire            clk,
    input   wire            rst,

    // write port
    input   wire            write_hilo_en,
    input   wire[`DATA_BUS] write_hi_data,
    input   wire[`DATA_BUS] write_lo_data,

    // read port
    output  reg [`DATA_BUS] read_hi_data,
    output  reg [`DATA_BUS] read_lo_data
);

    reg [`DATA_BUS] hi_reg;
    reg [`DATA_BUS] lo_reg;

    always @ (posedge clk)  begin
        if (rst == `RST_ENABLE) begin
            hi_reg      <= `ZERO_WORD;
            lo_reg      <= `ZERO_WORD;
        end else if (write_hilo_en == `WRITE_ENABLE) begin
            hi_reg      <= write_hi_data;
            lo_reg      <= write_lo_data;
        end
    end

    always @ (*)    begin
        if (rst == `RST_ENABLE) begin
            read_hi_data    <= `ZERO_WORD;
            read_lo_data    <= `ZERO_WORD;
        end else    begin
            read_hi_data    <= hi_reg;
            read_lo_data    <= lo_reg;
        end
    end

endmodule