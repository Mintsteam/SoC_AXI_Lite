`timescale 1ns / 1ps
`include "../define/global.vh"

module myCPU(

    input clk,
    input rst,

);

    wire[`INST_ADDR_BUS] inst_addr;
    wire[`INST_BUS] inst;
    wire rom_ce;

    

endmodule