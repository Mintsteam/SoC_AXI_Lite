`timescale 1ns / 1ps
`include "../define/global.vh"

module Redemption(

    input clk,
    input rst,

    input wire[`REG_DATA_BUS] rom_data_i,
    output wire[`REG_DATA_BUS] rom_addr_o,
    output wire rom_ce_o

);

    wire[`INST_ADDR_BUS] inst_addr;
    wire[`INST_BUS] inst;
    wire rom_ce;

endmodule