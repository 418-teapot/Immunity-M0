`timescale 1ns / 1ps

`include "../src/cpu/define/global_def.v"

module  Immunity_min_sopc_tb();

    reg     CLOCK_50;
    reg     rst;

    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        rst = `RST_ENABLE;
        #195 rst = `RST_DISABLE;
        #1000 $stop;
    end

    Immunity_min_sopc Immunity_min_sopc0(
        .clk(CLOCK_50),
        .rst(rst)
    );

endmodule