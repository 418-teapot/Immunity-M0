`timescale 1ns / 1ps

`include "../define/global_def.v"

module  inst_rom(
    input   wire            en,
    input   wire[`ADDR_BUS] addr,
    output  wire[`INST_BUS] inst
);

    reg [`BYTE_BUS] inst_mem    [0 : `INST_MEM_NUM - 1];

    initial $readmemh ("inst_rom.bin", inst_mem);

    assign  inst[7 : 0] = (en == `CHIP_ENABLE) ? inst_mem[addr[`INST_MEM_NUM_LOG2 -1 : 0] + 3] : `ZERO_BYTE;
    assign  inst[15: 8] = (en == `CHIP_ENABLE) ? inst_mem[addr[`INST_MEM_NUM_LOG2 -1 : 0] + 2] : `ZERO_BYTE;
    assign  inst[23:16] = (en == `CHIP_ENABLE) ? inst_mem[addr[`INST_MEM_NUM_LOG2 -1 : 0] + 1] : `ZERO_BYTE;
    assign  inst[31:24] = (en == `CHIP_ENABLE) ? inst_mem[addr[`INST_MEM_NUM_LOG2 -1 : 0] + 0] : `ZERO_BYTE;

endmodule