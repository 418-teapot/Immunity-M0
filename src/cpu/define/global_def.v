// global
`define RST_ENABLE              1'b1
`define RST_DISABLE             1'b0
`define READ_ENABLE             1'b1
`define READ_DISABLE            1'b0
`define WRITE_ENABLE            1'b1
`define WRITE_DISABLE           1'b0
`define CHIP_ENABLE             1'b1
`define CHIP_DISABLE            1'b0

`define TRUE                    1'b1
`define FALSE                   1'b0

`define STOP                    1'b1
`define NO_STOP                 1'b0

`define ZERO_WORD               32'h0

// address bus
`define ADDR_BUS                31:0
`define ADDR_BUS_WIDTH          32

// instruction bus
`define INST_BUS                31:0
`define INST_BUS_WIDTH          32

// data bus
`define DATA_BUS                31:0
`define DATA_BUS_WIDTH          32

// double size data bus
`define DOUBLE_DATA_BUS         63:0
`define DOUBLE_DATA_BUS_WIDTH   64

// byte lane bus
`define BYTE_BUS                7:0
`define BYTE_BUS_WIDTH          8
`define ZERO_BYTE               8'h0

// RegFile
`define REG_ADDR_BUS            4:0
`define REG_ADDR_BUS_WIDTH      5
`define REG_NUM                 32
`define ZERO_REG_ADDR           5'h0

// coprocessor address bus
`define CP0_ADDR_BUS            4:0
`define CP0_ADDR_BUS_WIDTH      5

// instruction information bus
`define INST_OP_TYPE_BUS        2:0
`define INST_OP_TYPE_BUS_WIDTH  3
`define INST_OP_BUS             5:0
`define INST_OP_BUS_WIDTH       6
`define INST_ADDR_BUS           25:0
`define INST_ADDR_BUS_WIDTH     26
`define FUNCT_BUS               5:0
`define FUNCT_BUS_WIDTH         6
`define SHAMT_BUS               4:0
`define SHAMT_BUS_WIDTH         5
`define IMM_BUS                 15:0
`define IMM_BUS_WIDTH           16
`define OFFSET_BUS              15:0
`define OFFSET_BUS_WIDTH        16

// instruction type
`define TYPE_R                  3'b100
`define TYPE_I                  3'b010
`define TYPE_J                  3'b001

`define TYPE_IMM                3'b100
`define TYPE_B                  3'b010
`define TYPE_SL                 3'b001

// stall signal bus
`define STALL_BUS               5:0
`define STALL_BUS_WIDTH         6

// exception type bus
`define EXC_TYPE_BUS            7:0
`define EXC_TYPE_BUS_WIDTH      8

// inst_rom
`define INST_MEM_NUM            512
`define INST_MEM_NUM_LOG2       9

// data_ram
`define DATA_MEM_NUM            131071
`define DATA_MEM_NUM_LOG2       17
`define DATA_MEM_BUS            0:16