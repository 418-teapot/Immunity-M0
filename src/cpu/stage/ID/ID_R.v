`timescale 1ns / 1ps

`include "../../define/global_def.v"
`include "../../define/op_def.v"
`include "../../define/funct_def.v"
`include "../../define/segpos_def.v"

module  ID_R(
    input   wire                rst,

    // to ID
    output  reg                 inst_r,
    
    // from IF stage
    input   wire[`ADDR_BUS]     addr,
    input   wire[`INST_BUS]     inst,

    // from RegReadProxy
    input   wire[`DATA_BUS]     reg_val_mux_data_1,
    input   wire[`DATA_BUS]     reg_val_mux_data_2,

    // from or to RegFile
    output  reg                 reg_read_en_1,
    output  reg [`REG_ADDR_BUS] reg_addr_1,
    output  reg                 reg_read_en_2,
    output  reg [`REG_ADDR_BUS] reg_addr_2,

    // to EX stage
    output  wire[`DATA_BUS]     operand_1,
    output  wire[`DATA_BUS]     operand_2,
    output  wire[`SHAMT_BUS]    shamt,
    output  reg                 write_reg_en,
    output  reg [`REG_ADDR_BUS] write_reg_addr
);

    wire[`INST_OP_BUS]  inst_op     = inst[`SEG_OPCODE];
    wire[`REG_ADDR_BUS] inst_rs     = inst[`SEG_RS];
    wire[`REG_ADDR_BUS] inst_rt     = inst[`SEG_RT];
    wire[`REG_ADDR_BUS] inst_rd     = inst[`SEG_RD];
    wire[`FUNCT_BUS]    inst_funct  = inst[`SEG_FUNCT];
    wire[`IMM_BUS]      inst_imm    = inst[`SEG_IMM];
    wire[`SHAMT_BUS]    inst_shamt  = inst[`SEG_SHAMT];

    wire[`DATA_BUS]     zero_extended_imm = {16'b0, inst_imm};

    assign  operand_1   = (rst == `RST_ENABLE) ? `ZERO_WORD : reg_val_mux_data_1;
    assign  operand_2   = (rst == `RST_ENABLE) ? `ZERO_WORD : reg_val_mux_data_2;

    assign  shamt       = (rst == `RST_ENABLE) ? `SHAMT_BUS_WIDTH'b0 : inst_shamt;

    // generate inst_r
    always @ (*)    begin
        case (inst_op)

            `OP_SPECIAL:    begin
                inst_r  <= `TRUE;
            end

            default:        begin
                inst_r  <= `FALSE;
            end

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

                `OP_SPECIAL:    begin
                    reg_read_en_1   <= `READ_ENABLE;
                    reg_addr_1      <= inst_rs;
                    reg_read_en_2   <= `READ_ENABLE;
                    reg_addr_2      <= inst_rt;
                end

                default:        begin
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

                `OP_SPECIAL:    begin
                    write_reg_en    <= `WRITE_ENABLE;
                    write_reg_addr  <= inst_rd;
                end

                default:        begin
                    write_reg_en    <= `WRITE_DISABLE;
                    write_reg_addr  <= `ZERO_REG_ADDR;
                end

            endcase
        end
    end

endmodule