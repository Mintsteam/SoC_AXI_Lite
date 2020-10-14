`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/rom.vh"

module ROM(

    input wire ce,
    input wire[`INST_ADDR_BUS] addr,
    output reg[`INST_DATA_BUS] inst

);

    reg[`INST_DATA_BUS] inst_mem[0:`INST_MEM_SIZE-1];

    initial $readmemh ("inst_rom.data", inst_mem);

    always @ (*)
    begin
        inst <= ce ? inst_mem[addr[`INST_MEM_SIZE_WIDTH+1:2]] : 0;
    end

endmodule