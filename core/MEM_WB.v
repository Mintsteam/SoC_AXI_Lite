`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"

module MEM_WB(

    input wire clk,
    input wire rst,

    input wire[`REG_DATA_BUS] mem_reg_write_data,
    input wire[`REG_ADDR_BUS] mem_reg_write_addr,
    input wire mem_reg_write_en,

    output reg[`REG_DATA_BUS] wb_reg_write_data,    
    output reg[`REG_ADDR_BUS] wb_reg_write_addr,
    output reg wb_reg_write_en

);

	always @ (posedge clk) 
    begin

        wb_reg_write_data <= rst ? 0 : mem_reg_write_data;        
		wb_reg_write_addr <= rst ? 0 : mem_reg_write_addr;
		wb_reg_write_en <= rst ? 0 : mem_reg_write_en;
		/*
		wb_hi<=rst?0:mem_hi;
		wb_lo<=rst?0:mem_lo;
		wb_whilo<=rst?0:mem_whilo;
        */
	end     

endmodule