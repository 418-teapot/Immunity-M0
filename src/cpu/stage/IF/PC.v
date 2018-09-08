`timescale 1ns / 1ps

`include "../../define/global_def.v"

module  PC(
    input   wire            clk,
    input   wire            rst,

    // stall signal
    input   wire            stall_pc,

    // from ID stage 
    // branch control
    input   wire            branch_flag,
    input   wire[`ADDR_BUS] branch_addr,

    // to ROM (addr is pc)
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
        end else if (stall_pc == `NO_STOP)  begin
            if (branch_flag == `TRUE)   begin
                addr    <= branch_addr;
            end else    begin
                addr    <= addr + 4'h4;
            end
        end
    end

endmodule