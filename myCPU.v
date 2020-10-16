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
    wire rom_ce;

    core core0(
        .clk(clk),
        .rst(rst),
        .rom_addr_o(inst_addr),
        .rom_data_i(inst),
        .rom_ce_o(rom_ce)
    );
    
    ROM ROM0(
        .ce(rom_ce),
        .addr(inst_addr),
        .inst(inst)
    );

endmodule