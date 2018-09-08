`timescale  1ns / 1ps

`include "../define/global_def.v"

module  data_ram(
    input   wire            clk,
    input   wire            rst,

    input   wire            ram_en,

    // write port
    input   wire            write_en,
    input   wire[3:0]       write_sel,
    input   wire[`ADDR_BUS] write_addr,
    input   wire[`DATA_BUS] write_data,

    // read port
    output  reg [`DATA_BUS] read_data
);

    reg [`BYTE_BUS] data_mem    [`DATA_MEM_BUS];

    // write operation
    always @ (posedge clk)  begin
        if (ram_en == `CHIP_DISABLE)    begin
        end else if (write_en == `WRITE_ENABLE) begin
            if (write_sel[3])   data_mem[write_addr[`DATA_MEM_NUM_LOG2 + 1 : 2] + 0]    <= write_data[31:24];
            if (write_sel[2])   data_mem[write_addr[`DATA_MEM_NUM_LOG2 + 1 : 2] + 1]    <= write_data[23:16];
            if (write_sel[1])   data_mem[write_addr[`DATA_MEM_NUM_LOG2 + 1 : 2] + 2]    <= write_data[15: 8];
            if (write_sel[0])   data_mem[write_addr[`DATA_MEM_NUM_LOG2 + 1 : 2] + 3]    <= write_data[ 7: 0];
        end
    end

    // read operation
    always @ (*)    begin
        if (ram_en == `CHIP_DISABLE)    
            read_data   <= `ZERO_WORD;
        else if (write_en == `WRITE_DISABLE)
            read_data   <= {data_mem[write_addr[`DATA_MEM_NUM_LOG2 + 1 : 2] + 0],
                            data_mem[write_addr[`DATA_MEM_NUM_LOG2 + 1 : 2] + 1], 
                            data_mem[write_addr[`DATA_MEM_NUM_LOG2 + 1 : 2] + 2],
                            data_mem[write_addr[`DATA_MEM_NUM_LOG2 + 1 : 2] + 3]};
        else
            read_data   <= `ZERO_WORD;
    end

endmodule