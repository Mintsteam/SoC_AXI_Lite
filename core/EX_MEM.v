`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"

module EX_MEM(

    input wire clk,
    input wire rst,

    input wire[`REG_DATA_BUS] ex_reg_write_data,
    input wire[`REG_ADDR_BUS] ex_reg_write_addr,
    input wire ex_reg_write_en,

    input wire[`REG_DATA_BUS] ex_hi_write_data,
    input wire[`REG_DATA_BUS] ex_lo_write_data,
    input wire ex_hilo_write_en,

    output reg[`REG_DATA_BUS] mem_reg_write_data,    
    output reg[`REG_ADDR_BUS] mem_reg_write_addr,
    output reg mem_reg_write_en,

    output reg[`REG_DATA_BUS] mem_hi_write_data,
    output reg[`REG_DATA_BUS] mem_lo_write_data,
    output reg mem_hilo_write_en

);

    always @ (posedge clk) 
    begin
		mem_reg_write_addr <= rst ? 0 : ex_reg_write_addr;
        mem_reg_write_data <= rst ? 0 : ex_reg_write_data;
		mem_reg_write_en <= rst ? 0 : ex_reg_write_en;
		mem_hi_write_data <= rst ? 0 : ex_hi_write_data;
		mem_lo_write_data <= rst ? 0 : ex_lo_write_data;
		mem_hilo_write_en <= rst ? 0 : ex_hilo_write_en;   
	end    

endmodule