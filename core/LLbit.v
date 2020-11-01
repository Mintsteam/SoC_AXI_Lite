`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"
`include "../define/opcode.vh"

module LLbit(

    input wire clk,
    input wire rst,

    input wire flush,

    input wire LLbit_i,
    input wire LLbit_write_en,

    output reg LLbit_o

);

    always @ (posedge clk)
    begin
        if(rst == `RST_ENABLE)
        begin
            LLbit_o <= 1'b0;
        end else if((flush == 1'b1)) begin
            LLbit_o <= 1'b0;
        end else if((LLbit_write_en == `WRITE_ENABLE)) begin
            LLbit_o <= LLbit_i;
        end
    end

endmodule