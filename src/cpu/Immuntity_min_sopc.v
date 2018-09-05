`timescale 1ns / 1ps

`include "/define/global_def.v"

module  Immunity_min_sopc(
    input   wire    clk,
    input   wire    rst
);
    wire            rom_en;
    wire[`ADDR_BUS] rom_addr;
    wire[`INST_BUS] rom_inst;

    Immunity    immunity0(
        .clk        (clk),
        .rst        (rst),

        .rom_inst   (rom_inst),
        .rom_addr   (rom_addr),
        .rom_en     (rom_en)
    );

    inst_rom    inst_rom0(
        .en         (rom_en),
        .addr       (rom_addr),
        .inst       (rom_inst)
    );

endmodule