`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"

module CTRL(

    input wire rst,
    input wire id_stall_req,
    input wire ex_stall_req,

    input wire[31:0] exception_type_i,
    input wire[`REG_DATA_BUS] cp0_epc_i,

    output reg[`REG_DATA_BUS] new_pc,
    output reg flush,

    output reg[5:0] stall

);

    always @ (*)
    begin
        if(rst == `RST_ENABLE)
        begin
            stall <= 6'b000000;
            flush <= 1'b0;
            new_pc <= `ZEROWORD;
        end else if(exception_type_i != `ZEROWORD) begin
            stall <= 6'b000000;
            flush <= 1'b1;
            case(exception_type_i)
                32'h00000001: begin
                    new_pc <= 32'h00000020;
                end
                32'h00000008: begin
                    new_pc <= 32'h00000040;
                end
                32'h0000000a: begin
                    new_pc <= 32'h00000040;
                end
                32'h0000000d: begin
                    new_pc <= 32'h00000040;
                end
                32'h0000000c: begin
                    new_pc <= 32'h00000040;
                end
                32'h0000000e: begin
                    new_pc <= cp0_epc_i;
                end
                default: begin end
            endcase
        end else if(ex_stall_req == `STOP) begin
            stall <= 6'b001111;
            flush <= 1'b0;
        end else if(id_stall_req == `STOP) begin
            stall <= 6'b000111;
            flush <= 1'b0;
        end else begin
            stall <= 6'b000000;
            flush <= 1'b0;
            new_pc <= `ZEROWORD;
        end
    end

endmodule