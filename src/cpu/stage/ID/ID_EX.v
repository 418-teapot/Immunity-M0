`timescale 1ns / 1ps

`include "../../define/global_def.v"

module  ID_EX(
    input   wire                clk,
    input   wire                rst,

    // stall signals
    input   wire                stall_current_stage,
    input   wire                stall_next_stage,

    // from ID stage
    input   wire                ram_en_in,
    input   wire                ram_write_en_in,
    input   wire[3:0]           ram_write_sel_in,
    input   wire[`DATA_BUS]     ram_write_data_in,
    
    input   wire                ram_read_flag_in,
    input   wire[`FUNCT_BUS]    funct_in,
    input   wire[`DATA_BUS]     operand_1_in,
    input   wire[`DATA_BUS]     operand_2_in,
    input   wire[`SHAMT_BUS]    shamt_in,
    input   wire                write_reg_en_in,
    input   wire[`REG_ADDR_BUS] write_reg_addr_in,

    // to EX stage
    output  wire                ram_en_out,
    output  wire                ram_write_en_out,
    output  wire[3:0]           ram_write_sel_out,
    output  wire[`DATA_BUS]     ram_write_data_out,

    output  wire                ram_read_flag_out,
    output  wire[`FUNCT_BUS]    funct_out,
    output  wire[`DATA_BUS]     operand_1_out,
    output  wire[`DATA_BUS]     operand_2_out,
    output  wire[`SHAMT_BUS]    shamt_out,
    output  wire                write_reg_en_out,
    output  wire[`REG_ADDR_BUS] write_reg_addr_out
);

    PipelineDeliver #(1)    ff_ram_en(
        .clk                    (clk),
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (ram_en_in),
        .out                    (ram_en_out)
    );

    PipelineDeliver #(1)    ff_ram_write_en(
        .clk                    (clk),
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (ram_write_en_in),
        .out                    (ram_write_en_out)
    );

    PipelineDeliver #(4)    ff_ram_write_sel(
        .clk                    (clk),
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (ram_write_sel_in),
        .out                    (ram_write_sel_out)
    );

    PipelineDeliver #(`DATA_BUS_WIDTH)  ff_ram_write_data(
        .clk                    (clk),
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (ram_write_data_in),
        .out                    (ram_write_data_out)
    );

    PipelineDeliver #(1)    ff_ram_read_flag(
        .clk                    (clk),
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (ram_read_flag_in),
        .out                    (ram_read_flag_out)
    );

    PipelineDeliver #(`FUNCT_BUS_WIDTH) ff_funct(
        .clk                    (clk),              
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (funct_in),          
        .out                    (funct_out)
    );

    PipelineDeliver #(`DATA_BUS_WIDTH)  ff_operand_1(
        .clk                    (clk),              
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (operand_1_in),      
        .out                    (operand_1_out)
    );

    PipelineDeliver #(`DATA_BUS_WIDTH)  ff_operand_2(
        .clk                    (clk),              
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (operand_2_in),      
        .out                    (operand_2_out)
    );

    PipelineDeliver #(`SHAMT_BUS_WIDTH) ff_shamt(
        .clk                    (clk),              
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (shamt_in),          
        .out                    (shamt_out)
    );

    PipelineDeliver #(1)    ff_write_reg_en(
        .clk                    (clk),              
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (write_reg_en_in),   
        .out                    (write_reg_en_out)
    );

    PipelineDeliver #(`REG_ADDR_BUS_WIDTH)  ff_write_reg_addr(
        .clk                    (clk),              
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (write_reg_addr_in), 
        .out                    (write_reg_addr_out)
    );

endmodule