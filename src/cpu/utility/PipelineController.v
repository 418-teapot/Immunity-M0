`timescale  1ns / 1ps

`include "../define/global_def.v"

module  PipelineController(
    input   wire            rst,

    // stall request signals
    input   wire            id_stall_request,
    input   wire            ex_stall_request,

    // stall signals for each middle-stage
    output  wire            stall_pc,
    output  wire            stall_if,
    output  wire            stall_id,
    output  wire            stall_ex,
    output  wire            stall_mem,
    output  wire            stall_wb
);

    reg [`STALL_BUS]    stall;

    assign  {stall_wb, stall_mem, stall_ex,
             stall_id, stall_if,  stall_pc} = stall;
    
    // generate the stall signal
    always @ (*)    begin
        if (rst == `RST_ENABLE) begin
            stall   <= 6'b000000;
        end else if (ex_stall_request == `STOP) begin
            stall   <= 6'b001111;
        end else if (id_stall_request == `STOP) begin
            stall   <= 6'b000111;
        end else    begin
            stall   <= 6'b000000;
        end
    end

endmodule