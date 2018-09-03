`timescale  1ns / 1ps

`include "../define/global_def.v"

module  PipelineDeliver
#(
    parameter   width = 1
)(
    input   wire                clk,
    input   wire                rst,

    // stall signals
    input   wire                stall_current_stage,
    input   wire                stall_next_stage,

    // data input & output
    input   wire[width - 1 : 0] in,
    output  reg [width - 1 : 0] out
);

    always @ (posedge clk)  begin
        if (rst == `RST_ENABLE) begin
            out <= 0;
        end else if (stall_current_stage == `STOP && stall_next_stage == `NO_STOP)  begin
            out <= 0;
        end else if (stall_current_stage == `NO_STOP)begin
            out <= in;
        end
    end

endmodule