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

    // to pc
    output  reg                 branch_flag,
    output  reg [`ADDR_BUS]     branch_addr,

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
    wire[`SHAMT_BUS]    inst_shamt  = inst[`SEG_SHAMT];

    reg [`ADDR_BUS] link_addr;
    wire[`ADDR_BUS] pc_plus_8   = pc + 8;

    assign  operand_1   = (rst == `RST_ENABLE) ? `ZERO_WORD : 
                          (inst_funct == `FUNCT_JR || inst_funct == `FUNCT_JALR) ? link_addr : reg_val_mux_data_1;
    assign  operand_2   = (rst == `RST_ENABLE) ? `ZERO_WORD : reg_val_mux_data_2;

    assign  shamt       = (rst == `RST_ENABLE) ? `SHAMT_BUS_WIDTH'b0 : inst_shamt;

    // generate inst_r
    always @ (*)    begin
        case (inst_op)

            `OP_SPECIAL, `OP_SPECIAL2:    begin
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

                `OP_SPECIAL, `OP_SPECIAL2:    begin
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
                    if (inst_funct == `FUNCT_JR)    begin
                        write_reg_en    <= `WRITE_DISABLE;
                        write_reg_addr  <= `ZERO_REG_ADDR;
                    end else    begin
                        write_reg_en    <= `WRITE_ENABLE;
                        write_reg_addr  <= inst_rd;
                    end
                end

                `OP_SPECIAL2:    begin
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

    // generate branch information
    always @ (*)    begin
        if (rst == `RST_ENABLE) begin
            link_addr   <= `ZERO_WORD;
            branch_flag <= `FALSE;
            branch_addr <= `ZERO_WORD;
        end else    begin
            case (inst_funct)
                `FUNCT_JR:  begin
                    link_addr   <= `ZERO_WORD;
                    branch_flag <= `TRUE;
                    branch_addr <= reg_val_mux_data_1;
                end 
                `FUNCT_JALR:    begin
                    link_addr   <= pc_plus_8;
                    branch_flag <= `TRUE;
                    branch_addr <= reg_val_mux_data_1;
                end
                default:    begin
                    link_addr   <= `ZERO_WORD;
                    branch_flag <= `FALSE;
                    branch_addr <= `ZERO_WORD;
                end
            endcase
        end
    end

endmodule