`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"

module MEM_WB(

    input wire clk,
    input wire rst,

    input wire[`REG_DATA_BUS] mem_write_data,
    input wire[`REG_ADDR_BUS] mem_write_addr,
    input wire mem_write_en,

    output reg[`REG_DATA_BUS] wb_write_data,    
    output reg[`REG_ADDR_BUS] wb_write_addr,
    output reg wb_write_en

);

	always @ (posedge clk) 
    begin

        wb_write_data <= rst ? 0 : mem_write_data;        
		wb_write_addr <= rst ? 0 : mem_write_addr;
		wb_write_en <= rst ? 0 : mem_write_en;
		/*
		wb_hi<=rst?0:mem_hi;
		wb_lo<=rst?0:mem_lo;
		wb_whilo<=rst?0:mem_whilo;
        */
	end     

endmodule