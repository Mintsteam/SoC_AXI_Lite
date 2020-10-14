`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"

module EX_MEM(

    input wire clk,
    input wire rst,

    input wire[`REG_DATA_BUS] ex_write_data,
    input wire[`REG_ADDR_BUS] ex_write_addr,
    input wire ex_write_en,

    output reg[`REG_DATA_BUS] mem_write_data,    
    output reg[`REG_ADDR_BUS] mem_write_addr,
    output reg mem_write_en

);

    always @ (posedge clk) 
    begin
		mem_write_addr <= rst ? 0 : ex_write_addr;
        mem_write_data <= rst ? 0 : ex_write_data;
		mem_write_en <= rst ? 0 : ex_write_en;
        /*
		mem_hi<=rst?0:ex_hi;
		mem_lo<=rst?0:ex_lo;
		mem_whilo<=rst?0:ex_whilo;
        */	    
	end    
	 

endmodule