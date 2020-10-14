`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"

module REGFILE(

    input wire clk,
    input wire rst,

    input wire write_en,
    input wire[`REG_DATA_BUS] write_data,    
    input wire[`REG_ADDR_BUS] write_addr,

    input wire read_en_1,
    input wire[`REG_ADDR_BUS] read_addr_1,
    output reg[`REG_DATA_BUS] read_data_1,

    input wire read_en_2,
    input wire[`REG_ADDR_BUS] read_addr_2,
    output reg[`REG_DATA_BUS] read_data_2

);

    reg[`REG_DATA_BUS] regs[0:`REG_NUM-1];

    //write
    always @ (posedge clk)
    begin
        if(!rst)
        begin
            if((write_en) && (write_addr != `REG_ADDR_BUS_WIDTH'h0))
            begin
                regs[write_addr] <= write_data;
            end
        end else begin
            regs[0] <= 0; regs[1] <= 0; regs[2] <= 0;
            regs[3] <= 0; regs[4] <= 0; regs[5] <= 0;
            regs[6] <= 0; regs[7] <= 0; regs[8] <= 0;
            regs[9] <= 0; regs[10] <= 0; regs[11] <= 0;
            regs[12] <= 0; regs[13] <= 0; regs[14] <= 0;
            regs[15] <= 0; regs[16] <= 0; regs[17] <= 0;
            regs[18] <= 0; regs[19] <= 0; regs[20] <= 0;
            regs[21] <= 0; regs[22] <= 0; regs[23] <= 0;
            regs[24] <= 0; regs[25] <= 0; regs[26] <= 0;
            regs[27] <= 0; regs[28] <= 0; regs[29] <= 0;
            regs[30] <= 0; regs[31] <= 0;
        end
    end

    //read channel 1
    always @ (*)
    begin
        if(rst)
        begin
            read_data_1 <= `ZEROWORD;
        end else if(read_en_1 && read_addr_1 == `REG_ADDR_BUS_WIDTH'h0)
        begin
            read_data_1 <= `ZEROWORD;
        end else if(read_en_1 && write_en && read_addr_1 == write_addr) begin
            read_data_1 <= write_data;
        end else if(read_en_1) begin
            read_data_1 <= regs[read_addr_1];
        end else begin
            read_data_1 <= `ZEROWORD;
        end
    end

    //read channel 2
    always @ (*)
    begin
        if(rst)
        begin
            read_data_2 <= `ZEROWORD;
        end else if(read_en_2 && read_addr_2 == `REG_ADDR_BUS_WIDTH'h0)
        begin
            read_data_2 <= `ZEROWORD;
        end else if(read_en_2 && write_en && read_addr_2 == write_addr) begin
            read_data_2 <= write_data;
        end else if(read_en_2) begin
            read_data_2 <= regs[read_addr_2];
        end else begin
            read_data_2 <= `ZEROWORD;
        end
    end

endmodule