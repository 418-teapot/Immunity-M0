`timescale 1ns / 1ps

`include "../../define/global_def.v"

module  PC(
    input   wire            clk,
    input   wire            rst,
    output  reg             rom_en,
    output  reg [`ADDR_BUS] addr
);

    always @ (posedge clk)  begin
        if (rst == `RST_ENABLE) begin
            rom_en  <= `CHIP_DISABLE;
        end else    begin
            rom_en  <= `CHIP_ENABLE;
        end
    end

    always @ (posedge clk)  begin
        if (rom_en == `CHIP_DISABLE)    begin
            addr    <= `ZERO_WORD;
        end else    begin
            addr    <= addr + 4'h4;
        end
    end

endmodule