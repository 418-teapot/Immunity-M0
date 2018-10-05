`timescale 1ns / 1ps

`include "../../define/global_def.v"
`include "../../define/op_def.v"

module  MEM(
    input   wire                rst,

    // from RAM
    input   wire[`DATA_BUS]     ram_read_data,

    // from EX stage
    input   wire                ram_en_in,
    input   wire                ram_write_en_in,

    input   wire[`INST_OP_BUS]  inst_op,
    input   wire[`DATA_BUS]     reg_data_2,

    input   wire[`DATA_BUS]     result_in,
    input   wire                write_reg_en_in,
    input   wire[`REG_ADDR_BUS] write_reg_addr_in,
    input   wire                write_hilo_en_in,
    input   wire[`DATA_BUS]     write_hi_data_in,
    input   wire[`DATA_BUS]     write_lo_data_in,

    // to RAM
    output  wire                ram_en_out,
    output  wire                ram_write_en_out,
    output  reg [3:0]           ram_write_sel_out,
    output  wire[`ADDR_BUS]     ram_addr_out,
    output  reg [`DATA_BUS]     ram_write_data_out,

    // to WB stage
    output  reg [`DATA_BUS]     result_out,
    output  wire                write_reg_en_out,
    output  wire[`REG_ADDR_BUS] write_reg_addr_out,
    output  wire                write_hilo_en_out,
    output  wire[`DATA_BUS]     write_hi_data_out,
    output  wire[`DATA_BUS]     write_lo_data_out
);

    assign  write_reg_en_out    = (rst == `RST_ENABLE) ? `WRITE_DISABLE : write_reg_en_in;
    assign  write_reg_addr_out  = (rst == `RST_ENABLE) ? `ZERO_REG_ADDR : write_reg_addr_in;
    assign  write_hilo_en_out   = (rst == `RST_ENABLE) ? `WRITE_DISABLE : write_hilo_en_in;
    assign  write_hi_data_out   = (rst == `RST_ENABLE) ? `ZERO_WORD     : write_hi_data_in;
    assign  write_lo_data_out   = (rst == `RST_ENABLE) ? `ZERO_WORD     : write_lo_data_in;

    assign  ram_en_out          = (rst == `RST_ENABLE) ? `CHIP_DISABLE  : ram_en_in;
    assign  ram_write_en_out    = (rst == `RST_ENABLE) ? `WRITE_DISABLE : ram_write_en_in;
    assign  ram_addr_out        = (rst == `RST_ENABLE) ? `ZERO_WORD     :
                                  (ram_en_in == `CHIP_ENABLE) ? result_in   : `ZERO_WORD;

    always @ (*)    begin
        if (rst == `RST_ENABLE) begin
            ram_write_sel_out   <= 4'b0000;
            ram_write_data_out  <= `ZERO_WORD;
            result_out          <= `ZERO_WORD;
        end else    begin
            case (inst_op)

                `OP_LB:     begin
                    ram_write_sel_out   <= 4'b0000;
                    ram_write_data_out  <= `ZERO_WORD;
                    case (result_in[1:0])
                        2'b00:  result_out  <= {{24{ram_read_data[31]}}, ram_read_data[31:24]};
                        2'b01:  result_out  <= {{24{ram_read_data[23]}}, ram_read_data[23:16]};
                        2'b10:  result_out  <= {{24{ram_read_data[15]}}, ram_read_data[15: 8]};
                        2'b11:  result_out  <= {{24{ram_read_data[ 7]}}, ram_read_data[ 7: 0]};
                    endcase
                end

                `OP_LBU:    begin
                    ram_write_sel_out   <= 4'b0000;
                    ram_write_data_out  <= `ZERO_WORD;
                    case (result_in[1:0])
                        2'b00:  result_out  <= {{24{1'b0}}, ram_read_data[31:24]};
                        2'b01:  result_out  <= {{24{1'b0}}, ram_read_data[23:16]};
                        2'b10:  result_out  <= {{24{1'b0}}, ram_read_data[15: 8]};
                        2'b11:  result_out  <= {{24{1'b0}}, ram_read_data[ 7: 0]};
                    endcase
                end

                `OP_LH:     begin
                    ram_write_sel_out   <= 4'b0000;
                    ram_write_data_out  <= `ZERO_WORD;
                    case (result_in[1:0])
                        2'b00:  result_out  <= {{16{ram_read_data[31]}}, ram_read_data[31:16]};
                        2'b10:  result_out  <= {{16{ram_read_data[15]}}, ram_read_data[15: 0]};
                    endcase
                end

                `OP_LHU:    begin
                    ram_write_sel_out   <= 4'b0000;
                    ram_write_data_out  <= `ZERO_WORD;
                    case (result_in[1:0])
                        2'b00:  result_out  <= {{16{1'b0}}, ram_read_data[31:16]};
                        2'b10:  result_out  <= {{16{1'b0}}, ram_read_data[15: 0]};
                    endcase
                end

                `OP_LW:     begin
                    ram_write_sel_out   <= 4'b0000;
                    ram_write_data_out  <= `ZERO_WORD;
                    result_out          <= ram_read_data;
                end

                `OP_LWL:    begin
                    ram_write_sel_out   <= 4'b0000;
                    ram_write_data_out  <= `ZERO_WORD;
                    case (result_in[1:0])
                        2'b00:  result_out  <= ram_read_data;
                        2'b01:  result_out  <= {ram_read_data[23:0], reg_data_2[ 7:0]};
                        2'b10:  result_out  <= {ram_read_data[15:0], reg_data_2[15:0]};
                        2'b11:  result_out  <= {ram_read_data[ 7:0], reg_data_2[23:0]};
                    endcase
                end

                `OP_LWR:    begin
                    ram_write_sel_out   <= 4'b0000;
                    ram_write_data_out  <= `ZERO_WORD;
                    case (result_in[1:0])
                        2'b00:  result_out  <= {reg_data_2[31: 8], ram_read_data[31:24]};
                        2'b01:  result_out  <= {reg_data_2[31:16], ram_read_data[31:16]};
                        2'b10:  result_out  <= {reg_data_2[31:24], ram_read_data[31: 8]};
                        2'b11:  result_out  <= ram_read_data;
                    endcase 
                end

                `OP_SB:     begin
                    ram_write_data_out  <= {4{reg_data_2[7:0]}};
                    result_out          <= `ZERO_WORD;
                    case (result_in[1:0])
                        2'b00:  ram_write_sel_out   <= 4'b1000;
                        2'b01:  ram_write_sel_out   <= 4'b0100;
                        2'b10:  ram_write_sel_out   <= 4'b0010;
                        2'b11:  ram_write_sel_out   <= 4'b0001;
                    endcase
                end

                `OP_SH:     begin
                    ram_write_data_out  <= {4{reg_data_2[15:0]}};
                    result_out          <= `ZERO_WORD;
                    case (result_in[1:0])   
                        2'b00:  ram_write_sel_out   <= 4'b1100;
                        2'b10:  ram_write_sel_out   <= 4'b0011;
                        default:ram_write_sel_out   <= 4'b0000;
                    endcase
                end

                `OP_SW:     begin
                    ram_write_data_out  <= reg_data_2;
                    result_out          <= `ZERO_WORD;
                    ram_write_sel_out   <= 4'b1111;
                end

                `OP_SWL:    begin
                    result_out          <= `ZERO_WORD;
                    case (result_in[1:0])
                        2'b00:  begin
                            ram_write_sel_out   <= 4'b1111;
                            ram_write_data_out  <= reg_data_2;
                        end
                        2'b01:  begin
                            ram_write_sel_out   <= 4'b0111;
                            ram_write_data_out  <= { 8'b0, reg_data_2[31: 8]};
                        end
                        2'b10:  begin
                            ram_write_sel_out   <= 4'b0011;
                            ram_write_data_out  <= {16'b0, reg_data_2[31:16]};
                        end
                        2'b11:  begin
                            ram_write_sel_out   <= 4'b0001;
                            ram_write_data_out  <= {24'b0, reg_data_2[31:24]};
                        end
                    endcase 
                end

                `OP_SWR:    begin
                    result_out          <= `ZERO_WORD;
                    case (result_in[1:0])
                        2'b00:  begin
                            ram_write_sel_out   <= 4'b1000;
                            ram_write_data_out  <= {reg_data_2[ 7:0], 24'b0};
                        end
                        2'b01:  begin
                            ram_write_sel_out   <= 4'b1100;
                            ram_write_data_out  <= {reg_data_2[15:0], 16'b0};
                        end
                        2'b10:  begin
                            ram_write_sel_out   <= 4'b1110;
                            ram_write_data_out  <= {reg_data_2[23:0],  8'b0};
                        end
                        2'b11:  begin
                            ram_write_sel_out   <= 4'b1111;
                            ram_write_data_out  <= reg_data_2;
                        end
                    endcase
                end

                default:    begin
                    ram_write_sel_out   <= 4'b0000;
                    ram_write_data_out  <= `ZERO_WORD;
                    result_out          <= result_in;
                end

            endcase
        end
    end

endmodule