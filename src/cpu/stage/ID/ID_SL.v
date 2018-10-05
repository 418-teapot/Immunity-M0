`timescale 1ns / 1ps

`include "../../define/global_def.v"
`include "../../define/op_def.v"
`include "../../define/funct_def.v"
`include "../../define/segpos_def.v"

module  ID_SL(
    input   wire                rst,

    // to ID_I
    output  wire                inst_sl,

    // from IF stage
    input   wire[`ADDR_BUS]     pc,
    input   wire[`INST_BUS]     inst,

    // from RegReadProxy
    input   wire[`DATA_BUS]     reg_val_mux_data_1,
    input   wire[`DATA_BUS]     reg_val_mux_data_2,

    // to RegFile
    output  reg                 reg_read_en_1,
    output  reg [`REG_ADDR_BUS] reg_addr_1,
    output  reg                 reg_read_en_2,
    output  reg [`REG_ADDR_BUS] reg_addr_2,

    // to RAM
    output  wire                ram_en,
    output  wire                ram_write_en,

    // to EX stage
    output  wire                ram_read_flag,
    output  wire[`DATA_BUS]     operand_1,
    output  wire[`DATA_BUS]     operand_2,
    output  wire                write_reg_en,
    output  wire[`REG_ADDR_BUS] write_reg_addr
);

    wire[`INST_OP_BUS]  inst_op     = inst[`SEG_OPCODE];
    wire[`REG_ADDR_BUS] inst_rs     = inst[`SEG_RS];
    wire[`REG_ADDR_BUS] inst_rt     = inst[`SEG_RT];
    wire[`OFFSET_BUS]   inst_offset = inst[`SEG_OFFSET];

    wire[`DATA_BUS]     sign_extended_offset  = {{16{inst[15]}}, inst_offset};

    assign  operand_1 = (rst == `RST_ENABLE) ? `ZERO_WORD : 
                        (reg_read_en_1 == `READ_ENABLE) ? reg_val_mux_data_1:
                        `ZERO_WORD;
    
    assign  operand_2 = (rst == `RST_ENABLE) ? `ZERO_WORD : sign_extended_offset;

    // generate ram_read_flag
    assign  ram_read_flag   = ((inst_op == `OP_LB) || (inst_op == `OP_LBU) ||
                               (inst_op == `OP_LH) || (inst_op == `OP_LHU) ||
                               (inst_op == `OP_LW) || (inst_op == `OP_LWL) ||
                               (inst_op == `OP_LWR)) ? `TRUE  : `FALSE; 
   
    // generate ram_write_flag
    wire    ram_write_flag  = ((inst_op == `OP_SB) || (inst_op == `OP_SH)  ||
                               (inst_op == `OP_SW) || (inst_op == `OP_SWL) ||
                               (inst_op == `OP_SWR)) ? `TRUE : `FALSE;

    // generate inst_sl
    assign  inst_sl = ram_read_flag || ram_write_flag;                      

    // generate read information
    always @ (*)    begin
        if (rst == `RST_ENABLE) begin
            reg_read_en_1   <= `READ_DISABLE;
            reg_addr_1      <= `ZERO_REG_ADDR;
            reg_read_en_2   <= `READ_DISABLE;
            reg_addr_2      <= `ZERO_REG_ADDR;
        end else    begin
            case (inst_op)

                `OP_LB, `OP_LBU, `OP_LH, `OP_LHU, `OP_LW:   begin
                    reg_read_en_1   <= `READ_ENABLE;
                    reg_addr_1      <= inst_rs;
                    reg_read_en_2   <= `READ_DISABLE;
                    reg_addr_2      <= `ZERO_REG_ADDR;
                end

                `OP_LWL, `OP_LWR,
                `OP_SB, `OP_SH, `OP_SW, `OP_SWL, `OP_SWR:   begin
                    reg_read_en_1   <= `READ_ENABLE;
                    reg_addr_1      <= inst_rs;
                    reg_read_en_2   <= `READ_ENABLE;
                    reg_addr_2      <= inst_rt;
                end

                default:    begin
                    reg_read_en_1   <= `READ_DISABLE;
                    reg_addr_1      <= `ZERO_REG_ADDR;
                    reg_read_en_2   <= `READ_DISABLE;
                    reg_addr_2      <= `ZERO_REG_ADDR;
                end

            endcase
        end
    end

    // generate write information
    assign  write_reg_en    = (rst == `RST_ENABLE) ? `WRITE_DISABLE : 
                              (ram_read_flag == `TRUE) ? `WRITE_ENABLE  : `WRITE_DISABLE;
    assign  write_reg_addr  = (rst == `RST_ENABLE) ? `ZERO_REG_ADDR : 
                              (ram_read_flag == `TRUE) ? inst_rt        : `ZERO_REG_ADDR;    

    // generate RAM information
    assign  ram_en          = (rst == `RST_ENABLE) ? `CHIP_DISABLE :
                              (inst_sl == `TRUE) ? `CHIP_ENABLE : `CHIP_DISABLE;
    assign  ram_write_en    = (rst == `RST_ENABLE) ? `WRITE_DISABLE : 
                              (ram_write_flag == `TRUE) ? `WRITE_ENABLE : `WRITE_DISABLE;

endmodule   