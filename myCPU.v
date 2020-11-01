`timescale 1ns / 1ps
`include "./define/global.vh"
`include "./define/regfile.vh"
`include "./define/rom.vh"

module myCPU(

    input clk,
    input rst

);

    wire[`INST_ADDR_BUS] inst_addr;
    wire[`INST_DATA_BUS] inst;
    wire[`REG_DATA_BUS] ram_addr_o;
    wire[`REG_DATA_BUS] ram_write_data_o;
    wire[3:0] ram_sel_o;
    wire ram_write_en_o;
    wire[`REG_DATA_BUS] data_o;
    wire rom_ce;
    wire ram_ce;
    wire[5:0] interrupt;
    wire timer_interrupt;

    assign interrupt = {5'b00000, timer_interrupt};

    assign ram_ce = 1'b1;

    core core0(

        //INPUT
        .clk(clk),
        .rst(rst),
        .rom_data_i(inst),
        .ram_read_data_i(data_o),
        .interrupt_i(interrupt),

        //OUTPUT
        .rom_addr_o(inst_addr),
        .rom_ce_o(rom_ce),
        .ram_addr_o(ram_addr_o),
        .ram_write_data_o(ram_write_data_o),
        .ram_write_en_o(ram_write_en_o),
        .ram_sel_o(ram_sel_o),
        .ram_ce_o(ram_ce_o),
        .timer_interrupt_o(timer_interrupt)

    );
    
    ROM ROM0(
        
        .ce(rom_ce),
        .addr(inst_addr),
        .inst(inst)

    );

    RAM RAM0(

        //INPUT
        .clk(clk),
        .ce(ram_ce),
        .write_en(ram_write_en_o),
        .addr(ram_addr_o),
        .sel(ram_sel_o),
        .data_i(ram_write_data_o),

        //OUTPUT
        .data_o(data_o)

    );

endmodule