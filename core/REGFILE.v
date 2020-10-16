`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"

module REGFILE(

    input wire clk,
    input wire rst,

    input wire write_en_i,
    input wire[`REG_DATA_BUS] write_data_i,    
    input wire[`REG_ADDR_BUS] write_addr_i,

    input wire read_en_1_i,
    input wire[`REG_ADDR_BUS] read_addr_1_i,
    input wire read_en_2_i,
    input wire[`REG_ADDR_BUS] read_addr_2_i,

    output reg[`REG_DATA_BUS] read_data_1_o,
    output reg[`REG_DATA_BUS] read_data_2_o

);

    reg[`REG_DATA_BUS] regs[0:`REG_NUM-1];

    //write
    always @ (posedge clk)
    begin
        if(!rst)
        begin
            if((write_en_i) && (write_addr_i != `REG_ADDR_BUS_WIDTH'h0))
            begin
                regs[write_addr_i] <= write_data_i;
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
            read_data_1_o <= `ZEROWORD;
        end else if(read_en_1_i && read_addr_1_i == `REG_ADDR_BUS_WIDTH'h0)
        begin
            read_data_1_o <= `ZEROWORD;
        end else if(read_en_1_i && write_en_i && read_addr_1_i == write_addr_i) begin
            read_data_1_o <= write_data_i;
        end else if(read_en_1_i) begin
            read_data_1_o <= regs[read_addr_1_i];
        end else begin
            read_data_1_o <= `ZEROWORD;
        end
    end

    //read channel 2
    always @ (*)
    begin
        if(rst)
        begin
            read_data_2_o <= `ZEROWORD;
        end else if(read_en_2_i && read_addr_2_i == `REG_ADDR_BUS_WIDTH'h0)
        begin
            read_data_2_o <= `ZEROWORD;
        end else if(read_en_2_i && write_en_i && read_addr_2_i == write_addr_i) begin
            read_data_2_o <= write_data_i;
        end else if(read_en_2_i) begin
            read_data_2_o <= regs[read_addr_2_i];
        end else begin
            read_data_2_o <= `ZEROWORD;
        end
    end

endmodule