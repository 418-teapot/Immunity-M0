`timescale 1ns / 1ps

`include "./define/global_def.v"

module  Immunity_min_sopc(
    input   wire    clk,
    input   wire    rst
);
    wire            rom_en;
    wire[`ADDR_BUS] rom_addr;
    wire[`INST_BUS] rom_inst;

    wire            ram_en;
    wire            ram_write_en;
    wire[3:0]       ram_write_sel;
    wire[`ADDR_BUS] ram_addr;
    wire[`DATA_BUS] ram_write_data;
    wire[`DATA_BUS] ram_read_data;

    Immunity    immunity0(
        .clk            (clk),
        .rst            (rst),

        .rom_inst       (rom_inst),
        .rom_addr       (rom_addr),
        .rom_en         (rom_en),

        .ram_en         (ram_en),
        .ram_write_en   (ram_write_en),
        .ram_write_sel  (ram_write_sel),
        .ram_addr       (ram_addr),
        .ram_write_data (ram_write_data),
        .ram_read_data  (ram_read_data)
    );

    inst_rom    inst_rom0(
        .en         (rom_en),
        .addr       (rom_addr),
        .inst       (rom_inst)
    );

    data_ram    data_ram0(
        .clk        (clk),
        .rst        (rst),
        .ram_en     (ram_en),
        .write_en   (ram_write_en),
        .write_sel  (ram_write_sel),
        .addr       (ram_addr),
        .write_data (ram_write_data),
        .read_data  (ram_read_data)
    );

endmodule