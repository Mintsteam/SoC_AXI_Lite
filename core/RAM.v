`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"

module RAM (
    
    input wire clk,
    input wire ce,
    input wire write_en,
    input wire[`DATA_ADDR_BUS] addr,
    input wire[3:0] sel,
    input wire[`DATA_BUS] data_i,

    output reg[`DATA_BUS] data_o

);

    reg[`BYTE_WIDTH] data_mem0[0:`DATA_MEM_NUM-1];
    reg[`BYTE_WIDTH] data_mem1[0:`DATA_MEM_NUM-1];
    reg[`BYTE_WIDTH] data_mem2[0:`DATA_MEM_NUM-1];
    reg[`BYTE_WIDTH] data_mem3[0:`DATA_MEM_NUM-1];

    always @ (posedge clk) 
    begin
        if(ce == `CHIP_DISABLE)
        begin
            data_o <= `ZEROWORD;
        end else if(write_en == `WRITE_ENABLE) begin
            if(sel[3] == 1'b1)
            begin
                data_mem3[addr[`DATA_ADDR_BUS_WIDTH+1:2]] <= data_i[31:24];
            end 
            if(sel[2] == 1'b1)
            begin
                data_mem2[addr[`DATA_ADDR_BUS_WIDTH+1:2]] <= data_i[23:16];
            end
            if(sel[1] == 1'b1)
            begin
                data_mem1[addr[`DATA_ADDR_BUS_WIDTH+1:2]] <= data_i[15:8];
            end
            if(sel[0] == 1'b1)
            begin
                data_mem0[addr[`DATA_ADDR_BUS_WIDTH+1:2]] <= data_i[7:0];
            end
        end
    end

    always @ (*)
    begin
        if(ce == `CHIP_DISABLE)
        begin
            data_o <= `ZEROWORD;
        end else if(write_en == `WRITE_DISABLE) begin
            data_o <= {data_mem3[addr[`DATA_ADDR_BUS_WIDTH+1:2]], data_mem2[addr[`DATA_ADDR_BUS_WIDTH+1:2]], data_mem1[addr[`DATA_ADDR_BUS_WIDTH+1:2]], data_mem0[addr[`DATA_ADDR_BUS_WIDTH+1:2]]};
        end else begin
            data_o <= `ZEROWORD;
        end
    end
    
endmodule