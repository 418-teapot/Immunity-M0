`timescale 1ns / 1ps

`include "../../define/global_def.v"
`include "../../define/op_def.v"
`include "../../define/regimm_def.v"
`include "../../define/funct_def.v"
`include "../../define/segpos_def.v"

module  ID_Branch(
    input   wire                rst,
    // to ID_I
    output  reg                 inst_branch,

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
    output  reg                 write_reg_en,
    output  reg [`REG_ADDR_BUS] write_reg_addr
);

    wire[`INST_OP_BUS]  inst_op     = inst[`SEG_OPCODE];
    wire[`REG_ADDR_BUS] inst_rs     = inst[`SEG_RS];
    wire[`REG_ADDR_BUS] inst_rt     = inst[`SEG_RT];
    wire[`OFFSET_BUS]   inst_offset = inst[`SEG_OFFSET];

    wire[`ADDR_BUS] pc_plus_4   = pc + 4;
    wire[`ADDR_BUS] pc_plus_8   = pc + 8;

    wire[`DATA_BUS] link_addr = (write_reg_en == `WRITE_ENABLE) ? pc_plus_8 : `ZERO_WORD;
    assign  operand_1   = link_addr;
    assign  operand_2   = `ZERO_WORD;

    wire[`DATA_BUS] sign_extended_offset  = {{14{inst[15]}}, inst_offset, 2'b00};

    // generate inst_branch
    always @ (*)    begin
        case (inst_op)
            `OP_BEQ, `OP_BNE, `OP_BLEZ, `OP_BGTZ:
                inst_branch <= `TRUE;
            `OP_REGIMM: begin
                case (inst_rt)
                    `REGIMM_BLTZ, `REGIMM_BGEZ, 
                    `REGIMM_BLTZAL, `REGIMM_BGEZAL:
                                inst_branch <= `TRUE;
                    default:    inst_branch <= `FALSE;
                endcase
            end
            default:    inst_branch <= `FALSE;
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

                `OP_BEQ, `OP_BNE, `OP_BLEZ, `OP_BGTZ:   begin
                    reg_read_en_1   <= `READ_ENABLE;
                    reg_addr_1      <= inst_rs;
                    reg_read_en_2   <= `READ_ENABLE;
                    reg_addr_2      <= inst_rt;
                end

                `OP_REGIMM: begin
                    reg_read_en_1   <= `READ_ENABLE;
                    reg_addr_1      <= inst_rs;
                    reg_read_en_2   <= `READ_DISABLE;
                    reg_addr_2      <= `ZERO_REG_ADDR;
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

                `OP_BEQ, `OP_BNE, `OP_BGTZ, `OP_BLEZ:   begin
                    write_reg_en    <= `WRITE_DISABLE;
                    write_reg_addr  <= `ZERO_REG_ADDR;
                end

                `OP_REGIMM: begin
                    case (inst_rt)

                        `REGIMM_BGEZ, `REGIMM_BLTZ:  begin
                            write_reg_en    <= `WRITE_DISABLE;
                            write_reg_addr  <= `ZERO_REG_ADDR;
                        end 

                        `REGIMM_BGEZAL, `REGIMM_BLTZAL:  begin
                            write_reg_en    <= `WRITE_ENABLE;
                            write_reg_addr  <= 5'b11111;
                        end

                        default:    begin
                            write_reg_en    <= `WRITE_DISABLE;
                            write_reg_addr  <= `ZERO_REG_ADDR;
                        end

                    endcase
                end
                
                default:    begin
                    write_reg_en    <= `WRITE_DISABLE;
                    write_reg_addr  <= `ZERO_REG_ADDR;
                end

            endcase
        end
    end

    // generate branch information
    always @ (*)    begin
        if (rst == `RST_ENABLE) begin
            branch_flag     <= `FALSE;
            branch_addr     <= `ZERO_WORD;
        end else    begin
            branch_flag     <= `FALSE;
            branch_addr     <= `ZERO_WORD;
            case (inst_op)

                `OP_BEQ:    begin
                    if (reg_val_mux_data_1 == reg_val_mux_data_2)   begin
                        branch_flag <= `TRUE;
                        branch_addr <= pc_plus_4 + sign_extended_offset;
                    end
                end

                `OP_BNE:    begin
                    if (reg_val_mux_data_1 != reg_val_mux_data_2)   begin
                        branch_flag <= `TRUE;
                        branch_addr <= pc_plus_4 + sign_extended_offset;
                    end
                end

                `OP_BGTZ:   begin
                    if (reg_val_mux_data_1[31] == 1'b0 && reg_val_mux_data_1 != `ZERO_WORD) begin
                        branch_flag <= `TRUE;
                        branch_addr <= pc_plus_4 + sign_extended_offset;
                    end
                end

                `OP_BLEZ:   begin
                    if (reg_val_mux_data_1[31] == 1'b1 && reg_val_mux_data_1 == `ZERO_WORD) begin
                        branch_flag <= `TRUE;
                        branch_addr <= pc_plus_4 + sign_extended_offset;
                    end
                end

                `OP_REGIMM: begin
                    case (inst_rt)

                        `REGIMM_BGEZ, `REGIMM_BGEZAL:   begin
                            if (reg_val_mux_data_1[31] == 1'b0) begin
                                branch_flag <= `TRUE;
                                branch_addr <= pc_plus_4 + sign_extended_offset;
                            end
                        end
                        
                        `REGIMM_BLTZ, `REGIMM_BLTZAL:   begin
                            if (reg_val_mux_data_1[31] == 1'b1) begin
                                branch_flag <= `TRUE;
                                branch_addr <= pc_plus_4 + sign_extended_offset;
                            end
                        end

                        default:    begin
                            branch_flag <= `FALSE;
                            branch_addr <= `ZERO_REG_ADDR;
                        end

                    endcase
                end

                default:    begin
                    branch_flag <= `FALSE;
                    branch_addr <= `ZERO_REG_ADDR;
                end

            endcase
        end
    end

endmodule