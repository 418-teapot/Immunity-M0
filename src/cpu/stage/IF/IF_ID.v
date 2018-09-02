`timescale 1ns / 1ps

`include "../../define/global_def.v"

module  IF_ID(
    input   wire            clk,
    input   wire            rst,

    // stall signals
    input   wire            stall_current_stage,
    input   wire            stall_next_stage,

    // from IF stage
    input   wire[`ADDR_BUS] addr_i,
    input   wire[`INST_BUS] inst_i,

    // to ID stage
    output  wire[`ADDR_BUS] addr_o,
    output  wire[`INST_BUS] inst_o
);

    PipelineDeliver #(`ADDR_BUS_WIDTH)    ff_addr(
        .clk                    (clk),      
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (addr_i),    
        .out                    (addr_o)
    );

    PipelineDeliver #(`INST_BUS_WIDTH)    ff_inst(
        .clk                    (clk),      
        .rst                    (rst),
        .stall_current_stage    (stall_current_stage),
        .stall_next_stage       (stall_next_stage),
        .in                     (inst_i),    
        .out                    (inst_o)
    );

endmodule