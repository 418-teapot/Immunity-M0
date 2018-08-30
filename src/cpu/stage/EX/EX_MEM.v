`timescale 1ns / 1ps

`include "../../define/global_def.v"

module  EX_MEM(
    input   wire                clk,
    input   wire                rst,

    // from EX stage
    input   wire[`DATA_BUS]     result_in,
    input   wire                write_reg_en_in,
    input   wire[`REG_ADDR_BUS] write_reg_addr_in,

    // to MEM stage
    output  wire[`DATA_BUS]     result_out,
    output  wire                write_reg_en_out,
    output  wire[`REG_ADDR_BUS] write_reg_addr_out
);

    PipelineDeliver #(`DATA_BUS_WIDTH)    ff_result(
        .clk(clk),              .rst(rst),
        .in(result_in),         .out(result_out)
    );

    PipelineDeliver #(1)    ff_write_reg_en(
        .clk(clk),              .rst(rst),
        .in(write_reg_en_in),   .out(write_reg_en_out)
    );

    PipelineDeliver #(`REG_ADDR_BUS_WIDTH)    ff_write_reg_addr(
        .clk(clk),              .rst(rst),
        .in(write_reg_addr_in), .out(write_reg_addr_out)
    );

endmodule