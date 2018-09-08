`timescale 1ns / 1ps

`include "../../define/global_def.v"

module  EX_MEM(
    input   wire                clk,
    input   wire                rst,

    // stall signals
    input   wire                stall_current_stage,
    input   wire                stall_next_stage,

    // from EX stage
    input   wire                ram_en_in,
    input   wire                ram_write_en_in,
    input   wire[3:0]           ram_write_sel_in,
    input   wire[`DATA_BUS]     ram_write_data_in,

    input   wire[`DATA_BUS]     result_in,
    input   wire                write_reg_en_in,
    input   wire[`REG_ADDR_BUS] write_reg_addr_in,
    input   wire                write_hilo_en_in,
    input   wire[`DATA_BUS]     write_hi_data_in,
    input   wire[`DATA_BUS]     write_lo_data_in,

    // to MEM stage
    output  wire                ram_en_out,
    output  wire                ram_write_en_out,
    output  wire[3:0]           ram_write_sel_out,
    output  wire[`DATA_BUS]     ram_write_data_out,

    output  wire[`DATA_BUS]     result_out,
    output  wire                write_reg_en_out,
    output  wire[`REG_ADDR_BUS] write_reg_addr_out,
    output  wire                write_hilo_en_out,
    output  wire[`DATA_BUS]     write_hi_data_out,
    output  wire[`DATA_BUS]     write_lo_data_out
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

    PipelineDeliver #(`DATA_BUS_WIDTH)    ff_result(
        .clk                    (clk),              
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (result_in),         
        .out                    (result_out)
    );

    PipelineDeliver #(1)    ff_write_reg_en(
        .clk                    (clk),              
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (write_reg_en_in),   
        .out                    (write_reg_en_out)
    );

    PipelineDeliver #(`REG_ADDR_BUS_WIDTH)    ff_write_reg_addr(
        .clk                    (clk),              
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (write_reg_addr_in), 
        .out                    (write_reg_addr_out)
    );

    PipelineDeliver #(1)    ff_write_hilo_en(
        .clk                    (clk),              
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (write_hilo_en_in),  
        .out                    (write_hilo_en_out)
    );

    PipelineDeliver #(`DATA_BUS_WIDTH)  ff_write_hi_data(
        .clk                    (clk),              
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (write_hi_data_in),  
        .out                    (write_hi_data_out)
    );

    PipelineDeliver #(`DATA_BUS_WIDTH)  ff_write_lo_data(
        .clk                    (clk),              
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (write_lo_data_in),  
        .out                    (write_lo_data_out)
    );    

endmodule