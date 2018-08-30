`timescale 1ns / 1ps

`include "/define/global_def.v"

module  Immunity(
    input   wire            clk,
    input   wire            rst,

    input   wire[`INST_BUS] rom_inst,
    output  wire[`ADDR_BUS] rom_addr,
    output  wire            rom_en
);

    wire[`ADDR_BUS]     pc_addr;
    
    assign  rom_addr =  pc_addr;

    // ID stage
    wire[`ADDR_BUS]     id_addr_i;
    wire[`INST_BUS]     id_inst_i;

    wire[`FUNCT_BUS]    id_funct_o;
    wire[`DATA_BUS]     id_operand_1_o;
    wire[`DATA_BUS]     id_operand_2_o;
    wire[`SHAMT_BUS]    id_shamt_o;
    wire                id_write_reg_en_o;
    wire[`REG_ADDR_BUS] id_write_reg_addr_o;

    // EX stage
    wire[`FUNCT_BUS]    ex_funct_i;
    wire[`DATA_BUS]     ex_operand_1_i;
    wire[`DATA_BUS]     ex_operand_2_i;
    wire[`SHAMT_BUS]    ex_shamt_i;
    wire                ex_write_reg_en_i;
    wire[`REG_ADDR_BUS] ex_write_reg_addr_i;

    wire[`DATA_BUS]     ex_result_o;
    wire                ex_write_reg_en_o;
    wire[`REG_ADDR_BUS] ex_write_reg_addr_o;

    // MEM stage
    wire[`DATA_BUS]     mem_result_i;
    wire                mem_write_reg_en_i;
    wire[`REG_ADDR_BUS] mem_write_reg_addr_i;

    wire[`DATA_BUS]     mem_result_o;
    wire                mem_write_reg_en_o;
    wire[`REG_ADDR_BUS] mem_write_reg_addr_o;

    // WB stage
    wire[`DATA_BUS]     wb_result_i;
    wire                wb_write_reg_en_i;
    wire[`REG_ADDR_BUS] wb_write_reg_addr_i;

    // RegReadProxy
    wire[`DATA_BUS]     reg_val_mux_data_1;
    wire[`DATA_BUS]     reg_val_mux_data_2;

    // RegFile
    wire                read_en_1;
    wire[`REG_ADDR_BUS] read_addr_1;
    wire[`DATA_BUS]     read_data_1;
    wire                read_en_2;
    wire[`REG_ADDR_BUS] read_addr_2;
    wire[`DATA_BUS]     read_data_2;

    wire                write_en;
    wire[`REG_ADDR_BUS] write_addr;
    wire[`DATA_BUS]     write_data;

    PC  pc0(
        .clk                (clk),                  
        .rst                (rst),
        .rom_en             (rom_en),            
        .addr               (pc_addr)
    );

    IF_ID   if_id0(
        .clk                (clk),                  
        .rst                (rst),

        // from IF stage
        .addr_i             (pc_addr),          
        .inst_i             (rom_inst),

        // to ID stage
        .addr_o             (id_addr_i),         
        .inst_o             (id_inst_i)
    );

    ID  id0(
        .rst                (rst),

        // from IF stage
        .addr               (id_addr_i),           
        .inst               (id_inst_i),

        // from RegReadProxy
        .reg_val_mux_data_1 (reg_val_mux_data_1),
        .reg_val_mux_data_2 (reg_val_mux_data_2),

        // from or to RegFile
        .reg_read_en_1      (read_en_1),
        .reg_addr_1         (read_addr_1), 
        .reg_read_en_2      (read_en_2),
        .reg_addr_2         (read_addr_2),

        // to EX stage
        .funct              (id_funct_o),
        .operand_1          (id_operand_1_o),
        .operand_2          (id_operand_2_o),
        .shamt              (id_shamt_o),
        .write_reg_en       (id_write_reg_en_o),
        .write_reg_addr     (id_write_reg_addr_o)
    );

    ID_EX   id_ex0(
        .clk                (clk),
        .rst                (rst),

        // from ID stage
        .funct_in           (id_funct_o),
        .operand_1_in       (id_operand_1_o),
        .operand_2_in       (id_operand_2_o),
        .shamt_in           (id_shamt_o),
        .write_reg_en_in    (id_write_reg_en_o),
        .write_reg_addr_in  (id_write_reg_addr_o),

        // to EX stage
        .funct_out          (ex_funct_i),
        .operand_1_out      (ex_operand_1_i),
        .operand_2_out      (ex_operand_2_i),
        .shamt_out          (ex_shamt_i),
        .write_reg_en_out   (ex_write_reg_en_i),
        .write_reg_addr_out (ex_write_reg_addr_i)
    );

    EX  ex0(
        .rst                (rst),

        // from ID stage
        .funct              (ex_funct_i),
        .operand_1          (ex_operand_1_i),
        .operand_2          (ex_operand_2_i),
        .shamt              (ex_shamt_i),
        .write_reg_en_in    (ex_write_reg_en_i),
        .write_reg_addr_in  (ex_write_reg_addr_i),

        // to MEM stage
        .result_out         (ex_result_o),
        .write_reg_en_out   (ex_write_reg_en_o),
        .write_reg_addr_out (ex_write_reg_addr_o)
    );

    EX_MEM  ex_mem0(
        .clk                (clk),
        .rst                (rst),

        // from EX stage
        .result_in          (ex_result_o),
        .write_reg_en_in    (ex_write_reg_en_o),
        .write_reg_addr_in  (ex_write_reg_addr_o),

        // to MEM stage
        .result_out         (mem_result_i),
        .write_reg_en_out   (mem_write_reg_en_i),
        .write_reg_addr_out (mem_write_reg_addr_i)
    );

    MEM mem0(
        .rst                (rst),

        // from EX stage
        .result_in          (mem_result_i),
        .write_reg_en_in    (mem_write_reg_en_i),
        .write_reg_addr_in  (mem_write_reg_addr_i),

        // to WB stage
        .result_out         (mem_result_o),
        .write_reg_en_out   (mem_write_reg_en_o),
        .write_reg_addr_out (mem_write_reg_addr_o)
    );

    MEM_WB  mem_wb0(
        .clk                (clk),
        .rst                (rst),

        // from MEM stage
        .result_in          (mem_result_o),
        .write_reg_en_in    (mem_write_reg_en_o),
        .write_reg_addr_in  (mem_write_reg_addr_o),

        // to WB stage
        .result_out         (wb_result_i),
        .write_reg_en_out   (wb_write_reg_en_i),
        .write_reg_addr_out (wb_write_reg_addr_i)
    );

    WB  wb0(
        .rst                (rst),

        // from MEM stage
        .result_in          (wb_result_i),
        .write_reg_en_in    (wb_write_reg_en_i),
        .write_reg_addr_in  (wb_write_reg_addr_i),

        // to RegFile
        .result_out         (write_data),
        .write_reg_en_out   (write_en),
        .write_reg_addr_out (write_addr)
    );

    RegReadProxy    regreadproxy0(
        // input from ID stage
        .reg_read_en_1      (read_en_1),
        .reg_addr_1         (read_addr_1),
        .reg_read_en_2      (read_en_2),
        .reg_addr_2         (read_addr_2),

        // input from RegFile
        .reg_data_1         (read_data_1),
        .reg_data_2         (read_data_2),

        // input from EX stage
        .ex_write_reg_en    (ex_write_reg_en_o),
        .ex_write_reg_addr  (ex_write_reg_addr_o),
        .ex_data            (ex_result_o),

        // input from MEM stage
        .mem_write_reg_en   (mem_write_reg_en_o),
        .mem_write_reg_addr (mem_write_reg_addr_o),
        .mem_data           (mem_result_o),

        // data output
        .reg_val_mux_data_1 (reg_val_mux_data_1),
        .reg_val_mux_data_2 (reg_val_mux_data_2)
    );

    RegFile regfile0(
        .clk                (clk),
        .rst                (rst),

        // read port 1
        .read_en_1          (read_en_1),
        .read_addr_1        (read_addr_1),
        .read_data_1        (read_data_1),

        // read port 2
        .read_en_2          (read_en_2),
        .read_addr_2        (read_addr_2),
        .read_data_2        (read_data_2),

        // write port
        .write_en           (write_en),
        .write_addr         (write_addr),
        .write_data         (write_data)
    );

endmodule