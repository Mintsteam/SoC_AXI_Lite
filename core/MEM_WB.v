`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"

module MEM_WB(

    input wire clk,
    input wire rst,

    input wire[`REG_DATA_BUS] mem_reg_write_data,
    input wire[`REG_ADDR_BUS] mem_reg_write_addr,
    input wire mem_reg_write_en,

    input wire[`REG_DATA_BUS] mem_hi_write_data,
    input wire[`REG_DATA_BUS] mem_lo_write_data,
    input wire mem_hilo_write_en,

    input wire[5:0] stall,

    output reg[`REG_DATA_BUS] wb_reg_write_data,    
    output reg[`REG_ADDR_BUS] wb_reg_write_addr,
    output reg wb_reg_write_en,

    output reg[`REG_DATA_BUS] wb_hi_write_data,
    output reg[`REG_DATA_BUS] wb_lo_write_data,
    output reg wb_hilo_write_en

);

    /*
	always @ (posedge clk) 
    begin

        wb_reg_write_data <= rst ? 0 : mem_reg_write_data;        
		wb_reg_write_addr <= rst ? 0 : mem_reg_write_addr;
		wb_reg_write_en <= rst ? 0 : mem_reg_write_en;
		wb_hi_write_data <= rst ? 0 : mem_hi_write_data;
		wb_lo_write_data <= rst ? 0 : mem_lo_write_data;
		wb_hilo_write_en <= rst ? 0 : mem_hilo_write_en;
	end     
    */

    always @ (posedge clk) 
    begin
		if(rst == `RST_ENABLE) 
        begin
			wb_reg_write_addr <= `NOP_REG_ADDR;
			wb_reg_write_en <= `WRITE_DISABLE;
		    wb_reg_write_data <= `ZEROWORD;	
		    wb_hi_write_data <= `ZEROWORD;
		    wb_lo_write_data <= `ZEROWORD;
		    wb_hilo_write_en <= `WRITE_DISABLE;	
		end else if(stall[4] == `STOP && stall[5] == `NOT_STOP) begin
			wb_reg_write_addr <= `NOP_REG_ADDR;
			wb_reg_write_en <= `WRITE_DISABLE;
		    wb_reg_write_data <= `ZEROWORD;
		    wb_hi_write_data <= `ZEROWORD;
		    wb_lo_write_data <= `ZEROWORD;
		    wb_hilo_write_en <= `WRITE_DISABLE;		  	  
		end else if(stall[4] == `NOT_STOP) begin
			wb_reg_write_addr <= mem_reg_write_addr;
			wb_reg_write_en <= mem_reg_write_en;
			wb_reg_write_data <= mem_reg_write_data;
			wb_hi_write_data <= mem_hi_write_data;
			wb_lo_write_data <= mem_lo_write_data;
			wb_hilo_write_en <= mem_hilo_write_en;			
		end    
	end      

endmodule