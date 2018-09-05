`timescale 1ns / 1ps

`include "../../define/global_def.v"
`include "../../define/funct_def.v"

module  Divider(
    input   wire                    clk,
    input   wire                    rst,

    // from EX stage
    input   wire[`FUNCT_BUS]        funct,
    input   wire[`DATA_BUS]         operand_1,
    input   wire[`DATA_BUS]         operand_2,

    // cancel signal
    input   wire                    cancel_div,

    // data output
    output  wire                    div_stall_request,
    output  reg [`DOUBLE_DATA_BUS]  result_div
);

    // ready signal
    reg     div_ready;
    
    // div enable signal
    wire    div_en;
    assign  div_en      = (funct == `FUNCT_DIV || funct == `FUNCT_DIVU) ?
                          ((div_ready == `FALSE) ? `TRUE : `FALSE) : `FALSE;
                          
    assign  div_stall_request   = (rst == `RST_ENABLE) ? `NO_STOP : 
                                  div_en ? (div_ready ? `NO_STOP : `STOP) : `NO_STOP;

    // flag of signed or unsigned
    wire    div_signed;
    assign  div_signed  = (funct == `FUNCT_DIV);

    // div variables
    wire[`DATA_BUS_WIDTH : 0]   div_temp;
    reg [`DOUBLE_DATA_BUS_WIDTH : 0]    result_div_temp;
    wire[`DATA_BUS] dividend    = (div_signed && operand_1[31]) ? (~operand_1 + 1) : operand_1;
    wire[`DATA_BUS] divisor     = (div_signed && operand_2[31]) ? (~operand_2 + 1) : operand_2;
    
    assign  div_temp    = {1'b0, result_div_temp[63:32]} - {1'b0, divisor};

    // clk cycle count
    reg [5:0]   cycle_cnt;

    // state variables
    reg         [1:0]   state;
    parameter   [1:0]   DIV_IDLE    = 2'b00,
                        DIV_BY_ZERO = 2'b01,
                        DIV_ON      = 2'b10,
                        DIV_DONE    = 2'b11;

    // DIV FSM
    always @ (posedge clk)  begin
        if (rst == `RST_ENABLE) begin
            state       <= DIV_IDLE;
            div_ready   <= `FALSE;
            result_div  <= {`ZERO_WORD, `ZERO_WORD};
        end else    begin
            case (state)
                
                DIV_IDLE:   begin
                    if (div_en == `TRUE && cancel_div == `FALSE)    begin
                        if (operand_2 == `ZERO_WORD)    begin
                            state   <= DIV_BY_ZERO;
                        end else    begin
                            state   <= DIV_ON;
                            cycle_cnt       <= 6'b000000;
                            result_div_temp <= {`ZERO_WORD, `ZERO_WORD};
                            result_div_temp[32:1]   <= dividend;
                        end
                    end else    begin
                        div_ready   <= `FALSE;
                        result_div  <= {`ZERO_WORD, `ZERO_WORD};
                    end
                end

                DIV_BY_ZERO:    begin
                    result_div_temp <= {`ZERO_WORD, `ZERO_WORD};
                    state   <= DIV_DONE;
                end

                DIV_ON: begin
                    if (cancel_div == `FALSE)   begin
                        if (cycle_cnt != 6'b100000) begin
                            if (div_temp[32])   begin
                                result_div_temp <= {result_div_temp[63:0], 1'b0};
                            end else    begin
                                result_div_temp <= {div_temp[31:0], result_div_temp[31:0], 1'b1};
                            end
                            cycle_cnt   <= cycle_cnt + 1;
                        end else    begin
                            if (div_signed && (operand_1[31] ^ operand_2[31]))  begin
                                result_div_temp[31:0]   <= ~result_div_temp[31:0] + 1;
                            end
                            if (div_signed && (operand_1[31] ^ result_div_temp[64]))    begin
                                result_div_temp[64:33]  <= ~result_div_temp[64:33] + 1;
                            end
                            state   <= DIV_DONE;
                            cycle_cnt   <= 6'b000000;
                        end
                    end else    begin
                        state   <= DIV_IDLE;
                    end
                end

                DIV_DONE:   begin
                    result_div  <= {result_div_temp[64:33], result_div_temp[31:0]};
                    div_ready   <= `TRUE;
                    if (!div_en)    begin
                        state   <= DIV_IDLE;
                        div_ready   <= `FALSE;
                        result_div  <= {`ZERO_WORD, `ZERO_WORD};
                    end
                end

            endcase
        end
    end 

endmodule