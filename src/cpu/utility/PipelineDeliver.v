`timescale  1ns / 1ps

`include "../define/global_def.v"

module  PipelineDeliver
#(
    parameter   width = 1
)(
    input   wire                clk,
    input   wire                rst,
    input   wire[width - 1 : 0] in,
    output  reg [width - 1 : 0] out
);

    always @ (posedge clk)  begin
        if (rst == `RST_ENABLE) begin
            out <= 0;
        end else    begin
            out <= in;
        end
    end

endmodule