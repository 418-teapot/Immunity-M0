`timescale 1ns / 1ps

`include "../../define/global_def.v"
`include "../../define/op_def.v"
`include "../../define/funct_def.v"
`include "../../define/segpos_def.v"

module  ID_J(
    input   wire                rst,

    // from pc
    input   wire[`ADDR_BUS]     pc,
    
    // to ID
    output  wire                inst_j,

    // from IF stage
    input   wire[`INST_BUS]     inst,

    // to pc
    output  reg                 branch_flag,
    output  reg [`ADDR_BUS]     branch_addr,

    // to EX stage
    output  wire[`DATA_BUS]     operand_1,
    output  wire[`DATA_BUS]     operand_2,
    output  reg                 write_reg_en,
    output  reg [`REG_ADDR_BUS] write_reg_addr
);

    wire[`INST_OP_BUS]      inst_op     = inst[`SEG_OPCODE];
    wire[`INST_ADDR_BUS]    inst_addr   = inst[`SEG_ADDR];

    wire[`ADDR_BUS] pc_plus_4   = pc + 4;
    wire[`ADDR_BUS] pc_plus_8   = pc + 8;
    
    reg [`ADDR_BUS] link_addr;
    assign  operand_1   = link_addr;
    assign  operand_2   = `ZERO_WORD;

    assign  inst_j  = (inst_op == `OP_J || inst_op == `OP_JAL) ? `TRUE : `FALSE;

    // generate write & branch information
    always @ (*)    begin
        if (rst == `RST_ENABLE) begin
            link_addr       <= `ZERO_WORD;
            branch_flag     <= `FALSE;
            branch_addr     <= `ZERO_WORD;
            write_reg_en    <= `WRITE_DISABLE;
            write_reg_addr  <= `ZERO_REG_ADDR;
        end else    begin
            case (inst_op)

                `OP_J:  begin
                    link_addr       <= `ZERO_WORD;
                    branch_flag     <= `TRUE;
                    branch_addr     <= {pc_plus_4[31:28], inst_addr, 2'b00};
                    write_reg_en    <= `WRITE_DISABLE;
                    write_reg_addr  <= `ZERO_REG_ADDR;
                end

                `OP_JAL:    begin
                    link_addr       <= pc_plus_8;
                    branch_flag     <= `TRUE;
                    branch_addr     <= {pc_plus_4[31:28], inst_addr, 2'b00};
                    write_reg_en    <= `WRITE_ENABLE;
                    write_reg_addr  <= 5'b11111;
                end

                default:    begin
                    link_addr       <= `ZERO_WORD;
                    branch_flag     <= `FALSE;
                    branch_addr     <= `ZERO_WORD;
                    write_reg_en    <= `WRITE_DISABLE;
                    write_reg_addr  <= `ZERO_REG_ADDR;
                end

            endcase
        end
    end

endmodule