`timescale 1ns / 1ps
`include "../define/global.vh"

module CTRL(

    input wire rst,
    input wire id_stall_req,
    input wire ex_stall_req,
    output reg[5:0] stall

);

    always @ (*)
    begin
        if(rst == `RST_ENABLE)
        begin
            stall <= 6'b000000;
        end else if(ex_stall_req == `STOP) begin
            stall <= 6'b001111;
        end else if(id_stall_req == `STOP) begin
            stall <= 6'b000111;
        end else begin
            stall <= 6'b000000;
        end
    end

endmodule