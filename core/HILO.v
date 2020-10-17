`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"

module HILO(

    input wire clk,
    input wire rst,

    input wire hilo_write_en,
    input wire[`REG_DATA_BUS] hi_write_data_i,
    input wire[`REG_DATA_BUS] lo_write_data_i,

    output reg[`REG_DATA_BUS] hi_read_data_o,
    output reg[`REG_DATA_BUS] lo_read_data_o

);

    always@(posedge clk)
    begin
        if(rst == `RST_ENABLE)
        begin
            hi_read_data_o <= `ZEROWORD;
            lo_read_data_o <= `ZEROWORD;
        end else if((hilo_write_en == `WRITE_ENABLE)) begin
            hi_read_data_o <= hi_write_data_i;
            lo_read_data_o <= lo_write_data_i;
        end
    end

endmodule