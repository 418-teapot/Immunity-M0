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

    // from RegReadProxy
    input   wire[`DATA_BUS]     reg_val_mux_data_1,
    input   wire[`DATA_BUS]     reg_val_mux_data_2,

    // stall request
    output  wire                id_stall_request,

    // to RegFile
    output  reg                 reg_read_en_1,
    output  reg [`REG_ADDR_BUS] reg_addr_1,
    output  reg                 reg_read_en_2,
    output  reg [`REG_ADDR_BUS] reg_addr_2,
    
    // to pc
    output  reg                 branch_flag,
    output  reg [`ADDR_BUS]     branch_addr,

    // to EX stage
    output  wire[`FUNCT_BUS]    funct,
    output  reg [`DATA_BUS]     operand_1,
    output  reg [`DATA_BUS]     operand_2,
    output  reg [`SHAMT_BUS]    shamt,
    output  reg                 write_reg_en,
    output  reg [`REG_ADDR_BUS] write_reg_addr
);

    assign  id_stall_request    = `NO_STOP;

    wire                    inst_r;
    wire                    inst_i;
    wire                    inst_j;
    wire[`INST_OP_TYPE_BUS] op_type = {inst_r, inst_i, inst_j};

    wire[`INST_OP_BUS]      inst_op     = inst[`SEG_OPCODE];
    wire[`REG_ADDR_BUS]     inst_rt     = inst[`SEG_RT];
    wire[`FUNCT_BUS]        inst_funct  = inst[`SEG_FUNCT];

    wire                    i_reg_read_en_1;
    wire[`REG_ADDR_BUS]     i_reg_addr_1;
    wire                    i_reg_read_en_2;
    wire[`REG_ADDR_BUS]     i_reg_addr_2;
    wire                    i_branch_flag;
    wire[`ADDR_BUS]         i_branch_addr;
    wire[`DATA_BUS]         i_operand_1;
    wire[`DATA_BUS]         i_operand_2;
    wire                    i_write_reg_en;
    wire[`REG_ADDR_BUS]     i_write_reg_addr;

    wire                    r_reg_read_en_1;
    wire[`REG_ADDR_BUS]     r_reg_addr_1;
    wire                    r_reg_read_en_2;
    wire[`REG_ADDR_BUS]     r_reg_addr_2;
    wire                    r_branch_flag;
    wire[`ADDR_BUS]         r_branch_addr;
    wire[`DATA_BUS]         r_operand_1;
    wire[`DATA_BUS]         r_operand_2;
    wire[`SHAMT_BUS]        r_shamt;
    wire                    r_write_reg_en;
    wire[`REG_ADDR_BUS]     r_write_reg_addr;

    wire                    j_branch_flag;
    wire[`ADDR_BUS]         j_branch_addr;
    wire[`DATA_BUS]         j_operand_1;
    wire[`DATA_BUS]         j_operand_2;
    wire                    j_write_reg_en;
    wire[`REG_ADDR_BUS]     j_write_reg_addr;

    ID_I    id_i0(
        .rst                (rst),

        // to ID
        .inst_i             (inst_i),

        // from IF stage
        .pc                 (addr),
        .inst               (inst),

        // from RegReadProxy
        .reg_val_mux_data_1 (reg_val_mux_data_1),
        .reg_val_mux_data_2 (reg_val_mux_data_2),

        // to RegFile
        .reg_read_en_1      (i_reg_read_en_1),
        .reg_addr_1         (i_reg_addr_1),
        .reg_read_en_2      (i_reg_read_en_2),
        .reg_addr_2         (i_reg_addr_2),

        // to pc
        .branch_flag        (i_branch_flag),
        .branch_addr        (i_branch_addr),

        // to EX stage
        .operand_1          (i_operand_1),
        .operand_2          (i_operand_2),
        .write_reg_en       (i_write_reg_en),
        .write_reg_addr     (i_write_reg_addr)
    );

    ID_R    id_r0(
        .rst                (rst),

        // to ID
        .inst_r             (inst_r),

        // from IF stage
        .pc                 (addr),
        .inst               (inst),

        // from RegReadProxy
        .reg_val_mux_data_1 (reg_val_mux_data_1),
        .reg_val_mux_data_2 (reg_val_mux_data_2),

        // to RegFile
        .reg_read_en_1      (r_reg_read_en_1),
        .reg_addr_1         (r_reg_addr_1),
        .reg_read_en_2      (r_reg_read_en_2),
        .reg_addr_2         (r_reg_addr_2),

        // to pc
        .branch_flag        (r_branch_flag),
        .branch_addr        (r_branch_addr),

        // to EX stage
        .operand_1          (r_operand_1),
        .operand_2          (r_operand_2),
        .shamt              (r_shamt),
        .write_reg_en       (r_write_reg_en),
        .write_reg_addr     (r_write_reg_addr)
    );

    ID_J    id_j0(
        .rst                (rst),
      
        // to ID
        .inst_j             (inst_j),
        
        // from IF stage
        .pc                 (addr),
        .inst               (inst),

        // to pc
        .branch_flag        (j_branch_flag),
        .branch_addr        (j_branch_addr),

        // to EX stage
        .operand_1          (j_operand_1),
        .operand_2          (j_operand_2),
        .write_reg_en       (j_write_reg_en),
        .write_reg_addr     (j_write_reg_addr)
    );

    FunctGen    functgen0(
        .op                 (inst_op),
        .funct_in           (inst_funct),
        .rt                 (inst_rt),
        .funct              (funct)
    );

    always @ (*)    begin
        case (op_type)
            
            `TYPE_R:    begin
                reg_read_en_1   <= r_reg_read_en_1;
                reg_addr_1      <= r_reg_addr_1;
                reg_read_en_2   <= r_reg_read_en_2;
                reg_addr_2      <= r_reg_addr_2;
                branch_flag     <= r_branch_flag;
                branch_addr     <= r_branch_addr;
                operand_1       <= r_operand_1;
                operand_2       <= r_operand_2;
                shamt           <= r_shamt;
                write_reg_en    <= r_write_reg_en;
                write_reg_addr  <= r_write_reg_addr;
            end

            `TYPE_I:    begin
                reg_read_en_1   <= i_reg_read_en_1;
                reg_addr_1      <= i_reg_addr_1;
                reg_read_en_2   <= i_reg_read_en_2;
                reg_addr_2      <= i_reg_addr_2;
                branch_flag     <= i_branch_flag;
                branch_addr     <= i_branch_addr;
                operand_1       <= i_operand_1;
                operand_2       <= i_operand_2;
                shamt           <= `SHAMT_BUS_WIDTH'b0;
                write_reg_en    <= i_write_reg_en;
                write_reg_addr  <= i_write_reg_addr;
            end

            `TYPE_J:    begin
                reg_read_en_1   <= `READ_DISABLE;
                reg_addr_1      <= `ZERO_REG_ADDR;
                reg_read_en_2   <= `READ_DISABLE;
                reg_addr_2      <= `ZERO_REG_ADDR;
                branch_flag     <= j_branch_flag;
                branch_addr     <= j_branch_addr;
                operand_1       <= j_operand_1;
                operand_2       <= j_operand_2;
                shamt           <= `SHAMT_BUS_WIDTH'b0;
                write_reg_en    <= j_write_reg_en;
                write_reg_addr  <= j_write_reg_addr;
            end

            default:    begin
                reg_read_en_1   <= `READ_DISABLE;
                reg_addr_1      <= `ZERO_REG_ADDR;
                reg_read_en_2   <= `READ_DISABLE;
                reg_addr_2      <= `ZERO_REG_ADDR;
                branch_flag     <= `FALSE;
                branch_addr     <= `ZERO_WORD;
                operand_1       <= `ZERO_WORD;
                operand_2       <= `ZERO_WORD;
                shamt           <= `SHAMT_BUS_WIDTH'b0;
                write_reg_en    <= `WRITE_DISABLE;
                write_reg_addr  <= `ZERO_REG_ADDR;
            end

        endcase
    end
    
endmodule