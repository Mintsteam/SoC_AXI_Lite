`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"

module MEM(

    input wire clk,
    input wire rst,

    input wire[`REG_DATA_BUS] write_data_i,
    input wire[`REG_ADDR_BUS] write_addr_i,
    input wire write_en_i,

    output reg[`REG_DATA_BUS] write_data_o,
    output reg[`REG_ADDR_BUS] write_addr_o,
    output reg write_en_o

);

	always @ (*) 
    begin
        write_data_o <= rst ? 0 : write_data_i;        
		write_addr_o <= rst ? 0 : write_addr_i;
		write_en_o <= rst ? 0 : write_en_i;
		/*
		hi_o<=rst?0:hi_i;
		lo_o<=rst?0:lo_i;
		whilo_o<=rst?0:whilo_i;
        */
	end    

endmodule