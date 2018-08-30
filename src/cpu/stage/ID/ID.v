`timescale 1ns / 1ps

`include "../../define/global_def.v"
`include "../../define/op_def.v"
`include "../../define/funct_def.v"
`include "../../define/segpos_def.v"

module  ID(
    input   wire                rst,

    // from IF stage
    input   wire[`ADDR_BUS]     addr,
    input   wire[`INST_BUS]     inst,

    // from or to RegFile
    input   wire[`DATA_BUS]     reg_data_1,
    output  reg                 reg_read_en_1,
    output  reg [`REG_ADDR_BUS] reg_addr_1,

    input   wire[`DATA_BUS]     reg_data_2,
    output  reg                 reg_read_en_2,
    output  reg [`REG_ADDR_BUS] reg_addr_2,

    // to EX stage
    output  reg [`FUNCT_BUS]    funct,
    output  reg [`DATA_BUS]     operand_1,
    output  reg [`DATA_BUS]     operand_2,
    output  reg [`SHAMT_BUS]    shamt,
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

    // generate read information
    always @ (*)    begin
        if (rst == `RST_ENABLE) begin
            reg_read_en_1   <= `READ_DISABLE;
            reg_addr_1      <= `ZERO_REG_ADDR;
            reg_read_en_2   <= `READ_DISABLE;
            reg_addr_2      <= `ZERO_REG_ADDR;
        end else    begin
            case (inst_op)

                `OP_ORI:        begin
                    reg_read_en_1   <= `READ_ENABLE;
                    reg_addr_1      <= inst_rs;
                    reg_read_en_2   <= `READ_DISABLE;
                    reg_addr_2      <= `ZERO_REG_ADDR;
                end

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

    // generate funct
    always @ (*)    begin
        case (inst_op)

            `OP_SPECIAL:    begin
                funct   <= inst_funct;
            end

            `OP_ORI:        begin
                funct   <= `FUNCT_OR;
            end

            default:        begin
                funct   <= `FUNCT_NOP;
            end

        endcase
    end

    // generate operand_1
    always @ (*)    begin
        if (rst == `RST_ENABLE) begin
            operand_1   <= `ZERO_WORD;
        end else    begin
            case (inst_op)
                
                `OP_ORI:        begin
                    operand_1   <= reg_data_1;
                end

                `OP_SPECIAL:    begin
                    operand_1   <= reg_data_1;
                end

                default:    begin
                    operand_1   <= `ZERO_WORD;
                end

            endcase
        end
    end

    // generate operand_2
    always @ (*)    begin
        if (rst == `RST_ENABLE) begin
            operand_2   <= `ZERO_WORD;
        end else    begin
            case (inst_op)

                `OP_ORI:        begin
                    operand_2   <= zero_extended_imm;
                end

                `OP_SPECIAL:    begin
                    operand_2   <= reg_data_2;
                end

                default:        begin
                    operand_2   <= `ZERO_WORD;
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

                `OP_ORI:        begin
                    write_reg_en    <= `WRITE_ENABLE;
                    write_reg_addr  <= inst_rt;
                end

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

    // generate shamt
    always @ (*)    begin
        if (rst == `RST_ENABLE) begin
            shamt   <= `SHAMT_BUS_WIDTH'b0;
        end else if (inst_op == `OP_SPECIAL)    begin
            shamt   <= inst_shamt;
        end else    begin
            shamt   <= `SHAMT_BUS_WIDTH'b0;
        end
    end

endmodule