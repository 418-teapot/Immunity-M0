`timescale 1ns / 1ps

`include "../../define/global_def.v"

module  ID_I(
    input   wire                rst,
    
    // to ID
    output  wire                inst_i,

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
    output  wire                branch_flag,
    output  wire[`ADDR_BUS]     branch_addr,

    // to RAM
    output  wire                ram_en,
    output  wire                ram_write_en,
    // to EX stage
    output  wire                ram_read_flag,
    output  reg [`DATA_BUS]     operand_1,
    output  reg [`DATA_BUS]     operand_2,
    output  reg                 write_reg_en,
    output  reg [`REG_ADDR_BUS] write_reg_addr
);

    // ID_IMM
    wire                inst_immediate;
    wire                imm_reg_read_en_1;
    wire[`REG_ADDR_BUS] imm_reg_addr_1;
    wire                imm_reg_read_en_2;
    wire[`REG_ADDR_BUS] imm_reg_addr_2;
    wire[`DATA_BUS]     imm_operand_1;
    wire[`DATA_BUS]     imm_operand_2;
    wire                imm_write_reg_en;
    wire[`REG_ADDR_BUS] imm_write_reg_addr;

    // ID_Branch
    wire                inst_branch;
    wire                branch_reg_read_en_1;
    wire[`REG_ADDR_BUS] branch_reg_addr_1;
    wire                branch_reg_read_en_2;
    wire[`REG_ADDR_BUS] branch_reg_addr_2;
    wire[`DATA_BUS]     branch_operand_1;
    wire[`DATA_BUS]     branch_operand_2;
    wire                branch_write_reg_en;
    wire[`REG_ADDR_BUS] branch_write_reg_addr;

    // ID_SL
    wire                inst_sl;
    wire                sl_reg_read_en_1;
    wire[`REG_ADDR_BUS] sl_reg_addr_1;
    wire                sl_reg_read_en_2;
    wire[`REG_ADDR_BUS] sl_reg_addr_2;
    wire[`DATA_BUS]     sl_operand_1;
    wire[`DATA_BUS]     sl_operand_2;
    wire                sl_write_reg_en;
    wire[`REG_ADDR_BUS] sl_write_reg_addr;

    assign  inst_i  = inst_immediate || inst_branch || inst_sl;

    ID_IMM  id_imm0(
        .rst                (rst),

        // to ID_I
        .inst_immediate      (inst_immediate),

        // from IF stage
        .inst               (inst),

        // from RegReadProxy
        .reg_val_mux_data_1 (reg_val_mux_data_1),
        .reg_val_mux_data_2 (reg_val_mux_data_2),

        // to RegFile
        .reg_read_en_1      (imm_reg_read_en_1),
        .reg_addr_1         (imm_reg_addr_1),
        .reg_read_en_2      (imm_reg_read_en_2),
        .reg_addr_2         (imm_reg_addr_2),

        // EX stage
        .operand_1          (imm_operand_1),
        .operand_2          (imm_operand_2),
        .write_reg_en       (imm_write_reg_en),
        .write_reg_addr     (imm_write_reg_addr)
    );

    ID_Branch   id_branch0(
        .rst                (rst),

        // to ID_I
        .inst_branch        (inst_branch),

        // from IF stage
        .pc                 (pc),
        .inst               (inst),

        // from RegReadProxy
        .reg_val_mux_data_1 (reg_val_mux_data_1),
        .reg_val_mux_data_2 (reg_val_mux_data_2),

        // to RegFile
        .reg_read_en_1      (branch_reg_read_en_1),
        .reg_addr_1         (branch_reg_addr_1),
        .reg_read_en_2      (branch_reg_read_en_2),
        .reg_addr_2         (branch_reg_addr_2),

        // to pc
        .branch_flag        (branch_flag),
        .branch_addr        (branch_addr),

        // to EX stage
        .operand_1          (branch_operand_1),
        .operand_2          (branch_operand_2),
        .write_reg_en       (branch_write_reg_en),
        .write_reg_addr     (branch_write_reg_addr)
    );

    ID_SL   id_sl0(
        .rst                (rst),
        
        // to ID_I
        .inst_sl            (inst_sl),

        // from IF stage
        .pc                 (pc),
        .inst               (inst),
        
        // from RegReadProxy
        .reg_val_mux_data_1 (reg_val_mux_data_1),
        .reg_val_mux_data_2 (reg_val_mux_data_2),
        
        // to RegFile
        .reg_read_en_1      (sl_reg_read_en_1),
        .reg_addr_1         (sl_reg_addr_1),
        .reg_read_en_2      (sl_reg_read_en_2),
        .reg_addr_2         (sl_reg_addr_2),

        // to RAM
        .ram_en             (ram_en),
        .ram_write_en       (ram_write_en),

        // to EX stage
        .ram_read_flag      (ram_read_flag),
        .operand_1          (sl_operand_1),
        .operand_2          (sl_operand_2),
        .write_reg_en       (sl_write_reg_en),
        .write_reg_addr     (sl_write_reg_addr)
    );

    wire[2:0]   inst_type   = {inst_immediate, inst_branch, inst_sl};

    always @ (*)    begin
        case (inst_type)

            `TYPE_IMM:  begin
                reg_read_en_1   <= imm_reg_read_en_1;
                reg_addr_1      <= imm_reg_addr_1;
                reg_read_en_2   <= imm_reg_read_en_2;
                reg_addr_2      <= imm_reg_addr_2;
                operand_1       <= imm_operand_1;
                operand_2       <= imm_operand_2;
                write_reg_en    <= imm_write_reg_en;
                write_reg_addr  <= imm_write_reg_addr;
            end

            `TYPE_B:    begin
                reg_read_en_1   <= branch_reg_read_en_1;
                reg_addr_1      <= branch_reg_addr_1;
                reg_read_en_2   <= branch_reg_read_en_2;
                reg_addr_2      <= branch_reg_addr_2;
                operand_1       <= branch_operand_1;
                operand_2       <= branch_operand_2;
                write_reg_en    <= branch_write_reg_en;
                write_reg_addr  <= branch_write_reg_addr;
            end

            `TYPE_SL:   begin
                reg_read_en_1   <= sl_reg_read_en_1;
                reg_addr_1      <= sl_reg_addr_1;
                reg_read_en_2   <= sl_reg_read_en_2;
                reg_addr_2      <= sl_reg_addr_2;
                operand_1       <= sl_operand_1;
                operand_2       <= sl_operand_2;
                write_reg_en    <= sl_write_reg_en;
                write_reg_addr  <= sl_write_reg_addr;
            end

            default:    begin
                reg_read_en_1   <= `READ_DISABLE;
                reg_addr_1      <= `ZERO_REG_ADDR;
                reg_read_en_2   <= `READ_DISABLE;
                reg_addr_2      <= `ZERO_REG_ADDR;
                operand_1       <= `ZERO_WORD;
                operand_2       <= `ZERO_WORD;
                write_reg_en    <= `WRITE_DISABLE;
                write_reg_addr  <= `ZERO_REG_ADDR;
            end

        endcase
    end

endmodule