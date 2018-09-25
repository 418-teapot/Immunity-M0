`timescale 1ns / 1ps

`include "../../define/global_def.v"
`include "../../define/op_def.v"
`include "../../define/funct_def.v"
`include "../../define/segpos_def.v"

module  ID_SL(
    input   wire                rst,

    // to ID_I
    output  reg                 inst_sl,

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
    output  reg                 ram_write_en,
    output  reg [3:0]           ram_write_sel,
    output  reg [`DATA_BUS]     ram_write_data,

    // to EX stage
    output  wire                ram_read_flag,
    output  wire[`DATA_BUS]     operand_1,
    output  wire[`DATA_BUS]     operand_2,
    output  reg                 write_reg_en,
    output  reg [`REG_ADDR_BUS] write_reg_addr
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

    // generate inst_sl
    always @ (*)    begin
        case (inst_op)
            `OP_LW, `OP_SW: 
                inst_sl <= `TRUE;
            default:
                inst_sl <= `FALSE;
        endcase
    end

    // generate read information
    always @ (*)    begin
        if (rst == `RST_ENABLE) begin
            reg_read_en_1   <= `READ_DISABLE;
            reg_addr_1      <= `ZERO_REG_ADDR;
            reg_read_en_2   <= `READ_DISABLE;
            reg_addr_2      <= `ZERO_REG_ADDR;
        end else    begin
            case (inst_op)

                `OP_LW: begin
                    reg_read_en_1   <= `READ_ENABLE;
                    reg_addr_1      <= inst_rs;
                    reg_read_en_2   <= `READ_DISABLE;
                    reg_addr_2      <= `ZERO_REG_ADDR;
                end

                `OP_SW: begin
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
    always @ (*)    begin
        if (rst == `RST_ENABLE) begin
            write_reg_en    <= `WRITE_DISABLE;
            write_reg_addr  <= `ZERO_REG_ADDR;
        end else    begin
            case (inst_op)  

                `OP_LW: begin
                    write_reg_en    <= `WRITE_ENABLE;
                    write_reg_addr  <= inst_rt;
                end

                `OP_SW: begin
                    write_reg_en    <= `WRITE_DISABLE;
                    write_reg_addr  <= `ZERO_REG_ADDR;
                end

                default:    begin
                    write_reg_en    <= `WRITE_DISABLE;
                    write_reg_addr  <= `ZERO_REG_ADDR;
                end

            endcase
        end
    end
    // generate ram_read_flag
    assign  ram_read_flag   = (rst == `RST_ENABLE) ? `FALSE :
                              (inst_op == `OP_LW) ? `TRUE : `FALSE;

    // generate RAM information
    assign  ram_en  = (rst == `RST_ENABLE) ? `CHIP_DISABLE :
                      (inst_sl == `TRUE) ? `CHIP_ENABLE : `CHIP_DISABLE;
    always @ (*)    begin
        if (rst == `RST_ENABLE) begin
            ram_write_en    <= `WRITE_DISABLE;
            ram_write_sel   <= 4'b0000;
            ram_write_data  <= `ZERO_WORD;
        end else    begin
            case (inst_op)

                `OP_LW: begin
                    ram_write_en    <= `WRITE_DISABLE;
                    ram_write_sel   <= 4'b0000;
                    ram_write_data  <= `ZERO_WORD;
                end

                `OP_SW: begin
                    ram_write_en    <= `WRITE_ENABLE;
                    ram_write_sel   <= 4'b1111;
                    ram_write_data  <= reg_val_mux_data_2;
                end

                default:    begin
                    ram_write_en    <= `WRITE_DISABLE;
                    ram_write_sel   <= 4'b0000;
                    ram_write_data  <= `ZERO_WORD;
                end
            endcase
        end
    end

endmodule   