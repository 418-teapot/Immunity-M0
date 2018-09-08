`timescale 1ns / 1ps

`include "../../define/global_def.v"
`include "../../define/op_def.v"
`include "../../define/funct_def.v"
`include "../../define/segpos_def.v"

module  ID_IMM(
    input   wire                rst,

    // to ID_I
    output  reg                 inst_immediate,

    // from IF stage
    input   wire[`INST_BUS]     inst,

    // from RegReadProxy
    input   wire[`DATA_BUS]     reg_val_mux_data_1,
    input   wire[`DATA_BUS]     reg_val_mux_data_2,

    // to RegFile
    output  reg                 reg_read_en_1,
    output  reg [`REG_ADDR_BUS] reg_addr_1,
    output  reg                 reg_read_en_2,
    output  reg [`REG_ADDR_BUS] reg_addr_2,

    // to EX stage
    output  wire[`DATA_BUS]     operand_1,
    output  reg [`DATA_BUS]     operand_2,
    output  reg                 write_reg_en,
    output  reg [`REG_ADDR_BUS] write_reg_addr
);

    wire[`INST_OP_BUS]  inst_op     = inst[`SEG_OPCODE];
    wire[`REG_ADDR_BUS] inst_rs     = inst[`SEG_RS];
    wire[`REG_ADDR_BUS] inst_rt     = inst[`SEG_RT];
    wire[`FUNCT_BUS]    inst_funct  = inst[`SEG_FUNCT];
    wire[`IMM_BUS]      inst_imm    = inst[`SEG_IMM];

    wire[`DATA_BUS]     zero_extended_imm       = {16'b0, inst_imm};
    wire[`DATA_BUS]     zero_extended_imm_hi    = {inst_imm, 16'b0};
    wire[`DATA_BUS]     sign_extended_imm       = {{16{inst_imm[15]}}, inst_imm};
    
    assign  operand_1   = (rst == `RST_ENABLE) ? `ZERO_WORD : reg_val_mux_data_1;

    // generate inst_i
    always @ (*)    begin
        case (inst_op)

            `OP_ANDI,`OP_ORI,`OP_XORI,
            `OP_ADDI, `OP_ADDIU, `OP_SLTI, `OP_SLTIU,
            `OP_LUI:    begin
                inst_immediate  <= `TRUE;
            end

            default:    begin
                inst_immediate  <= `FALSE;
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

                `OP_ANDI,`OP_ORI,`OP_XORI,
                `OP_ADDI, `OP_ADDIU, `OP_SLTI, `OP_SLTIU:   begin
                    reg_read_en_1   <= `READ_ENABLE;
                    reg_addr_1      <= inst_rs;
                    reg_read_en_2   <= `READ_DISABLE;
                    reg_addr_2      <= `ZERO_REG_ADDR;
                end

                default:        begin // OP_LUI
                    reg_read_en_1   <= `READ_DISABLE;
                    reg_addr_1      <= `ZERO_REG_ADDR;
                    reg_read_en_2   <= `READ_DISABLE;
                    reg_addr_2      <= `ZERO_REG_ADDR;
                end

            endcase
        end
    end

    // generate operand_2
    always @ (*)    begin
        if (rst == `READ_ENABLE)    begin
            operand_2   <= `ZERO_WORD;
        end else    begin
            case (inst_op)
                `OP_ORI, `OP_ANDI,  `OP_XORI:   
                            operand_2   <= zero_extended_imm;
                `OP_LUI:    operand_2   <= zero_extended_imm_hi;
                `OP_ADDI, `OP_ADDIU, `OP_SLTI, `OP_SLTIU:   
                            operand_2   <= sign_extended_imm;
                default:    operand_2   <= `ZERO_WORD;
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

                `OP_ANDI,`OP_ORI,`OP_XORI,
                `OP_ADDI, `OP_ADDIU, `OP_SLTI, `OP_SLTIU,
                `OP_LUI:        begin
                    write_reg_en    <= `WRITE_ENABLE;
                    write_reg_addr  <= inst_rt;
                end

                default:        begin
                    write_reg_en    <= `WRITE_DISABLE;
                    write_reg_addr  <= `ZERO_REG_ADDR;
                end

            endcase
        end
    end

endmodule