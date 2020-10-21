`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"

module MEM(

    input wire rst,

    input wire[`REG_DATA_BUS] reg_write_data_i,
    input wire[`REG_ADDR_BUS] reg_write_addr_i,
    input wire reg_write_en_i,

    input wire[`REG_DATA_BUS] hi_write_data_i,
    input wire[`REG_DATA_BUS] lo_write_data_i,
    input wire hilo_write_en_i,

    output reg[`REG_DATA_BUS] reg_write_data_o,
    output reg[`REG_ADDR_BUS] reg_write_addr_o,
    output reg reg_write_en_o,

    output reg[`REG_DATA_BUS] hi_write_data_o,
    output reg[`REG_DATA_BUS] lo_write_data_o,
    output reg hilo_write_en_o

);

    /*
	always @ (*) 
    begin
        reg_write_data_o <= rst ? 0 : reg_write_data_i;        
		reg_write_addr_o <= rst ? 0 : reg_write_addr_i;
		reg_write_en_o <= rst ? 0 : reg_write_en_i;
		hi_write_data_o <= rst ? 0 : hi_write_data_i;
		lo_write_data_o <= rst ? 0 : lo_write_data_i;
		hilo_write_en_o <= rst ? 0 : hilo_write_en_i;
	end    
    */

    always @ (*) begin
		if(rst == `RST_ENABLE) 
        begin
			reg_write_addr_o <= `NOP_REG_ADDR;
			reg_write_en_o <= `WRITE_DISABLE;
		    reg_write_data_o <= `ZEROWORD;
		    hi_write_data_o <= `ZEROWORD;
		    lo_write_data_o <= `ZEROWORD;
		    hilo_write_en_o <= `WRITE_DISABLE;		  
		end else begin
		    reg_write_addr_o <= reg_write_addr_i;
			reg_write_en_o <= reg_write_en_i;
			reg_write_data_o <= reg_write_data_i;
			hi_write_data_o <= hi_write_data_i;
			lo_write_data_o <= lo_write_data_i;
			hilo_write_en_o <= hilo_write_en_i;			
		end    
	end      

endmodule