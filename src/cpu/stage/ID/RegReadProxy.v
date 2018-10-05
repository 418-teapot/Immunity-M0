`timescale  1ns / 1ps

`include    "../../define/global_def.v"

module  RegReadProxy(
    // input from ID stage
    input   wire                reg_read_en_1,
    input   wire[`REG_ADDR_BUS] reg_addr_1,
    input   wire                reg_read_en_2,
    input   wire[`REG_ADDR_BUS] reg_addr_2,

    // input from RegFile
    input   wire[`DATA_BUS]     reg_data_1,
    input   wire[`DATA_BUS]     reg_data_2,

    // input from EX stage
    input   wire                ex_write_reg_en,
    input   wire[`REG_ADDR_BUS] ex_write_reg_addr,
    input   wire[`DATA_BUS]     ex_data,
    input   wire                ex_load_flag,

    // input from MEM stage
    input   wire                mem_write_reg_en,
    input   wire[`REG_ADDR_BUS] mem_write_reg_addr,
    input   wire[`DATA_BUS]     mem_data,

    // load related signals
    output  wire                load_related_1,
    output  wire                load_related_2,

    // data output
    output  reg [`DATA_BUS]     reg_val_mux_data_1,
    output  reg [`DATA_BUS]     reg_val_mux_data_2
);

    // generate reg_val_mux_data_1
    always @ (*)    begin
        if (reg_read_en_1 == `READ_ENABLE)  begin
            if (reg_addr_1 == `ZERO_REG_ADDR)   begin
                reg_val_mux_data_1  <= `ZERO_WORD;
            end else if ((ex_write_reg_en == `WRITE_ENABLE) && (reg_addr_1 == ex_write_reg_addr))   begin
                reg_val_mux_data_1  <= ex_data;
            end else if ((mem_write_reg_en == `WRITE_ENABLE) && (reg_addr_1 == mem_write_reg_addr)) begin
                reg_val_mux_data_1  <= mem_data;
            end else    begin
                reg_val_mux_data_1  <= reg_data_1;
            end
        end else    begin
            reg_val_mux_data_1  <= `ZERO_WORD;
        end
    end
    
    // generate reg_val_mux_data_2
    always @ (*)    begin
        if (reg_read_en_2 == `READ_ENABLE)  begin
            if (reg_addr_2 == `ZERO_REG_ADDR)   begin
                reg_val_mux_data_2  <= `ZERO_WORD;
            end else if ((ex_write_reg_en == `WRITE_ENABLE) && (reg_addr_2 == ex_write_reg_addr))   begin
                reg_val_mux_data_2  <= ex_data;
            end else if ((mem_write_reg_en == `WRITE_ENABLE) && (reg_addr_2 == mem_write_reg_addr)) begin
                reg_val_mux_data_2  <= mem_data;
            end else    begin
                reg_val_mux_data_2  <= reg_data_2;
            end
        end else    begin
            reg_val_mux_data_2  <= `ZERO_WORD;
        end
    end

    // generate load related signals
    assign  load_related_1  = (ex_load_flag == `TRUE &&
                               ex_write_reg_addr == reg_addr_1 &&
                               reg_read_en_1 == `READ_ENABLE) ? `STOP : `NO_STOP;
    assign  load_related_2  = (ex_load_flag == `TRUE &&
                               ex_write_reg_addr == reg_addr_2 &&
                               reg_read_en_2 == `READ_ENABLE) ? `STOP : `NO_STOP;                           

endmodule