`timescale 1ns / 1ps

`include "/define/global_def.v"

module  Immunity(
    input   wire            clk,
    input   wire            rst,

    input   wire[`INST_BUS] rom_inst,
    output  wire[`ADDR_BUS] rom_addr,
    output  wire            rom_en,

    output  wire            ram_en,
    output  wire            ram_write_en,
    output  wire[3:0]       ram_write_sel,
    output  wire[`ADDR_BUS] ram_addr,
    output  wire[`DATA_BUS] ram_write_data,
    input   wire[`DATA_BUS] ram_read_data
);

    wire[`ADDR_BUS]     pc_addr;
    
    assign  rom_addr =  pc_addr;

    // ID stage
    wire[`ADDR_BUS]     id_addr_i;
    wire[`INST_BUS]     id_inst_i;

    wire                branch_flag;
    wire[`ADDR_BUS]     branch_addr;

    wire                id_ram_en_o;
    wire                id_ram_write_en_o;
    wire                id_ram_read_flag_o;

    wire[`INST_OP_BUS]  id_inst_op_o;
    wire[`DATA_BUS]     id_reg_data_2_o;
    wire[`FUNCT_BUS]    id_funct_o;
    wire[`DATA_BUS]     id_operand_1_o;
    wire[`DATA_BUS]     id_operand_2_o;
    wire[`SHAMT_BUS]    id_shamt_o;
    wire                id_write_reg_en_o;
    wire[`REG_ADDR_BUS] id_write_reg_addr_o;

    // EX stage
    wire                ex_ram_en_i;
    wire                ex_ram_write_en_i;

    wire                ex_ram_read_flag_i;
    wire[`INST_OP_BUS]  ex_inst_op_i;
    wire[`DATA_BUS]     ex_reg_data_2_i;
    wire[`FUNCT_BUS]    ex_funct_i;
    wire[`DATA_BUS]     ex_operand_1_i;
    wire[`DATA_BUS]     ex_operand_2_i;
    wire[`SHAMT_BUS]    ex_shamt_i;
    wire                ex_write_reg_en_i;
    wire[`REG_ADDR_BUS] ex_write_reg_addr_i;

    wire                ex_load_flag;

    wire                ex_ram_en_o;
    wire                ex_ram_write_en_o;

    wire[`INST_OP_BUS]  ex_inst_op_o;
    wire[`DATA_BUS]     ex_reg_data_2_o;
    wire[`DATA_BUS]     ex_result_o;
    wire                ex_write_reg_en_o;
    wire[`REG_ADDR_BUS] ex_write_reg_addr_o;
    wire                ex_write_hilo_en_o;
    wire[`DATA_BUS]     ex_write_hi_data_o;
    wire[`DATA_BUS]     ex_write_lo_data_o;

    // MEM stage
    wire                mem_ram_en_i;
    wire                mem_ram_write_en_i;

    wire[`INST_OP_BUS]  mem_inst_op_i;
    wire[`DATA_BUS]     mem_reg_data_2_i;
    wire[`DATA_BUS]     mem_result_i;
    wire                mem_write_reg_en_i;
    wire[`REG_ADDR_BUS] mem_write_reg_addr_i;
    wire                mem_write_hilo_en_i;
    wire[`DATA_BUS]     mem_write_hi_data_i;
    wire[`DATA_BUS]     mem_write_lo_data_i;

    wire[`DATA_BUS]     mem_result_o;
    wire                mem_write_reg_en_o;
    wire[`REG_ADDR_BUS] mem_write_reg_addr_o;
    wire                mem_write_hilo_en_o;
    wire[`DATA_BUS]     mem_write_hi_data_o;
    wire[`DATA_BUS]     mem_write_lo_data_o;

    // WB stage
    wire[`DATA_BUS]     wb_result_i;
    wire                wb_write_reg_en_i;
    wire[`REG_ADDR_BUS] wb_write_reg_addr_i;
    wire                wb_write_hilo_en_i;
    wire[`DATA_BUS]     wb_write_hi_data_i;
    wire[`DATA_BUS]     wb_write_lo_data_i;

    // RegReadProxy
    wire[`DATA_BUS]     reg_val_mux_data_1;
    wire[`DATA_BUS]     reg_val_mux_data_2;
    wire                load_related_1;
    wire                load_related_2;

    // HILOReadProxy
    wire[`DATA_BUS]     hi_val_mux_data;
    wire[`DATA_BUS]     lo_val_mux_data;

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

    // HILO
    wire                write_hilo_en;
    wire[`DATA_BUS]     write_hi_data;
    wire[`DATA_BUS]     write_lo_data;

    wire[`DATA_BUS]     read_hi_data;
    wire[`DATA_BUS]     read_lo_data;

    // stall signals
    wire                id_stall_request;
    wire                ex_stall_request;
    wire                stall_pc;
    wire                stall_if;
    wire                stall_id;
    wire                stall_ex;
    wire                stall_mem;
    wire                stall_wb;

    PC  pc0(
        .clk                (clk),                  
        .rst                (rst),

        // stall signal
        .stall_pc           (stall_pc),

        // from ID stage
        // branch control
        .branch_flag        (branch_flag),
        .branch_addr        (branch_addr),

        // to ROM
        .rom_en             (rom_en),            
        .addr               (pc_addr)
    );

    IF_ID   if_id0(
        .clk                (clk),                  
        .rst                (rst),

        // stall signals
        .stall_current_stage(stall_if),
        .stall_next_stage   (stall_id),

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
        .load_related_1     (load_related_1),
        .load_related_2     (load_related_2),

        // stall request
        .id_stall_request   (id_stall_request),

        // to RegFile
        .reg_read_en_1      (read_en_1),
        .reg_addr_1         (read_addr_1), 
        .reg_read_en_2      (read_en_2),
        .reg_addr_2         (read_addr_2),

        // to pc
        .branch_flag        (branch_flag),
        .branch_addr        (branch_addr),

        // to RAM
        .ram_en             (id_ram_en_o),
        .ram_write_en       (id_ram_write_en_o),

        // to EX stage
        .ram_read_flag      (id_ram_read_flag_o),
        .inst_op            (id_inst_op_o),
        .reg_data_2         (id_reg_data_2_o),
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

        // stall signals
        .stall_current_stage(stall_id),
        .stall_next_stage   (stall_ex),

        // from ID stage
        .ram_en_in          (id_ram_en_o),
        .ram_write_en_in    (id_ram_write_en_o),
        
        .ram_read_flag_in   (id_ram_read_flag_o),
        .inst_op_in         (id_inst_op_o),
        .reg_data_2_in      (id_reg_data_2_o),
        .funct_in           (id_funct_o),
        .operand_1_in       (id_operand_1_o),
        .operand_2_in       (id_operand_2_o),
        .shamt_in           (id_shamt_o),
        .write_reg_en_in    (id_write_reg_en_o),
        .write_reg_addr_in  (id_write_reg_addr_o),

        // to EX stage
        .ram_en_out         (ex_ram_en_i),
        .ram_write_en_out   (ex_ram_write_en_i),

        .ram_read_flag_out  (ex_ram_read_flag_i),
        .inst_op_out        (ex_inst_op_i),
        .reg_data_2_out     (ex_reg_data_2_i),
        .funct_out          (ex_funct_i),
        .operand_1_out      (ex_operand_1_i),
        .operand_2_out      (ex_operand_2_i),
        .shamt_out          (ex_shamt_i),
        .write_reg_en_out   (ex_write_reg_en_i),
        .write_reg_addr_out (ex_write_reg_addr_i)
    );

    EX  ex0(
        .clk                (clk),
        .rst                (rst),

        // from ID stage
        .ram_en_in          (ex_ram_en_i),
        .ram_write_en_in    (ex_ram_write_en_i),

        .ram_read_flag      (ex_ram_read_flag_i),
        .inst_op_in         (ex_inst_op_i),
        .reg_data_2_in      (ex_reg_data_2_i),
        .funct              (ex_funct_i),
        .operand_1          (ex_operand_1_i),
        .operand_2          (ex_operand_2_i),
        .shamt              (ex_shamt_i),
        .write_reg_en_in    (ex_write_reg_en_i),
        .write_reg_addr_in  (ex_write_reg_addr_i),

        // from HILOReadProxy
        .hi_val_mux_data    (hi_val_mux_data),
        .lo_val_mux_data    (lo_val_mux_data),

        // to RegReadProxy
        .ex_load_flag       (ex_load_flag),

        // stall request
        .ex_stall_request   (ex_stall_request),

        // to MEM stage
        .ram_en_out         (ex_ram_en_o),
        .ram_write_en_out   (ex_ram_write_en_o),

        .inst_op_out        (ex_inst_op_o),
        .reg_data_2_out     (ex_reg_data_2_o),
        .result_out         (ex_result_o),
        .write_reg_en_out   (ex_write_reg_en_o),
        .write_reg_addr_out (ex_write_reg_addr_o),
        .write_hilo_en_out  (ex_write_hilo_en_o),
        .write_hi_data_out  (ex_write_hi_data_o),
        .write_lo_data_out  (ex_write_lo_data_o)
    );

    EX_MEM  ex_mem0(
        .clk                (clk),
        .rst                (rst),

        // stall signals
        .stall_current_stage(stall_ex),
        .stall_next_stage   (stall_mem),

        // from EX stage
        .ram_en_in          (ex_ram_en_o),
        .ram_write_en_in    (ex_ram_write_en_o),

        .inst_op_in         (ex_inst_op_o),
        .reg_data_2_in      (ex_reg_data_2_o),
        .result_in          (ex_result_o),
        .write_reg_en_in    (ex_write_reg_en_o),
        .write_reg_addr_in  (ex_write_reg_addr_o),
        .write_hilo_en_in   (ex_write_hilo_en_o),
        .write_hi_data_in   (ex_write_hi_data_o),
        .write_lo_data_in   (ex_write_lo_data_o),

        // to MEM stage
        .ram_en_out         (mem_ram_en_i),
        .ram_write_en_out   (mem_ram_write_en_i),

        .inst_op_out        (mem_inst_op_i),
        .reg_data_2_out     (mem_reg_data_2_i),
        .result_out         (mem_result_i),
        .write_reg_en_out   (mem_write_reg_en_i),
        .write_reg_addr_out (mem_write_reg_addr_i),
        .write_hilo_en_out  (mem_write_hilo_en_i),
        .write_hi_data_out  (mem_write_hi_data_i),
        .write_lo_data_out  (mem_write_lo_data_i)
    );

    MEM mem0(
        .rst                (rst),

        // from RAM
        .ram_read_data      (ram_read_data),

        // from EX stage
        .ram_en_in          (mem_ram_en_i),
        .ram_write_en_in    (mem_ram_write_en_i),

        .inst_op            (mem_inst_op_i),
        .reg_data_2         (mem_reg_data_2_i),
        .result_in          (mem_result_i),
        .write_reg_en_in    (mem_write_reg_en_i),
        .write_reg_addr_in  (mem_write_reg_addr_i),
        .write_hilo_en_in   (mem_write_hilo_en_i),
        .write_hi_data_in   (mem_write_hi_data_i),
        .write_lo_data_in   (mem_write_lo_data_i),

        // to RAM
        .ram_en_out         (ram_en),
        .ram_write_en_out   (ram_write_en),
        .ram_write_sel_out  (ram_write_sel),
        .ram_addr_out       (ram_addr),
        .ram_write_data_out (ram_write_data),

        // to WB stage
        .result_out         (mem_result_o),
        .write_reg_en_out   (mem_write_reg_en_o),
        .write_reg_addr_out (mem_write_reg_addr_o),
        .write_hilo_en_out  (mem_write_hilo_en_o),
        .write_hi_data_out  (mem_write_hi_data_o),
        .write_lo_data_out  (mem_write_lo_data_o)
    );

    MEM_WB  mem_wb0(
        .clk                (clk),
        .rst                (rst),

        // stall signals
        .stall_current_stage(stall_mem),
        .stall_next_stage   (stall_wb),

        // from MEM stage
        .result_in          (mem_result_o),
        .write_reg_en_in    (mem_write_reg_en_o),
        .write_reg_addr_in  (mem_write_reg_addr_o),
        .write_hilo_en_in   (mem_write_hilo_en_o),
        .write_hi_data_in   (mem_write_hi_data_o),
        .write_lo_data_in   (mem_write_lo_data_o),

        // to WB stage
        .result_out         (wb_result_i),
        .write_reg_en_out   (wb_write_reg_en_i),
        .write_reg_addr_out (wb_write_reg_addr_i),
        .write_hilo_en_out  (wb_write_hilo_en_i),
        .write_hi_data_out  (wb_write_hi_data_i),
        .write_lo_data_out  (wb_write_lo_data_i)
    );

    WB  wb0(
        .rst                (rst),

        // from MEM stage
        .result_in          (wb_result_i),
        .write_reg_en_in    (wb_write_reg_en_i),
        .write_reg_addr_in  (wb_write_reg_addr_i),
        .write_hilo_en_in   (wb_write_hilo_en_i),
        .write_hi_data_in   (wb_write_hi_data_i),
        .write_lo_data_in   (wb_write_lo_data_i),

        // to RegFile
        .result_out         (write_data),
        .write_reg_en_out   (write_en),
        .write_reg_addr_out (write_addr),

        // to HILO
        .write_hilo_en_out  (write_hilo_en),
        .write_hi_data_out  (write_hi_data),
        .write_lo_data_out  (write_lo_data)
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
        .ex_load_flag       (ex_load_flag),

        // input from MEM stage
        .mem_write_reg_en   (mem_write_reg_en_o),
        .mem_write_reg_addr (mem_write_reg_addr_o),
        .mem_data           (mem_result_o),

        // load related signals
        .load_related_1     (load_related_1),
        .load_related_2     (load_related_2),

        // data output
        .reg_val_mux_data_1 (reg_val_mux_data_1),
        .reg_val_mux_data_2 (reg_val_mux_data_2)
    );

    HILOReadProxy   hiloreadproxy(
        // input from HI & LO register
        .read_hi_data       (read_hi_data),
        .read_lo_data       (read_lo_data),

        // input from MEM stage
        .mem_write_hilo_en  (mem_write_hilo_en_o),
        .mem_write_hi_data  (mem_write_hi_data_o),
        .mem_write_lo_data  (mem_write_lo_data_o),

        // input from WB stage
        .wb_write_hilo_en   (write_hilo_en),
        .wb_write_hi_data   (write_hi_data),
        .wb_write_lo_data   (write_lo_data),

        // data output
        .hi_val_mux_data    (hi_val_mux_data),
        .lo_val_mux_data    (lo_val_mux_data)
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

    HILO    hilo0(
        .clk                (clk),
        .rst                (rst),

        // write port
        .write_hilo_en      (write_hilo_en),
        .write_hi_data      (write_hi_data),
        .write_lo_data      (write_lo_data),

        // read port
        .read_hi_data       (read_hi_data),
        .read_lo_data       (read_lo_data)
    );

    PipelineController  pipelinecontroller0(
        .rst                (rst),
        
        // stall request signals
        .id_stall_request   (id_stall_request),
        .ex_stall_request   (ex_stall_request),

        // stall signals for each middle-stage
        .stall_pc           (stall_pc),
        .stall_if           (stall_if),
        .stall_id           (stall_id),
        .stall_ex           (stall_ex),
        .stall_mem          (stall_mem),
        .stall_wb           (stall_wb)
    );

endmodule