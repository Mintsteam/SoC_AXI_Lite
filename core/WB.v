`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"

module WB(

    input wire resetn,

    input wire stall_req_from_arbiter,

    input wire[`INST_ADDR_BUS] wb_pc_i,
	output reg[`INST_ADDR_BUS] wb_pc_o,

    input wire[`REG_DATA_BUS] wb_reg_write_data_i,
    input wire[`REG_ADDR_BUS] wb_reg_write_addr_i,
    input wire wb_reg_write_en_i,

    input wire[`REG_DATA_BUS] wb_hi_write_data_i,
    input wire[`REG_DATA_BUS] wb_lo_write_data_i,
    input wire wb_hilo_write_en_i,

	input wire wb_cp0_reg_write_en_i,
	input wire[4:0] wb_cp0_reg_write_addr_i,
	input wire[`REG_DATA_BUS] wb_cp0_reg_write_data_i,

	input wire wb_LLbit_write_en_i,
	input wire wb_LLbit_data_i,

    output reg[`REG_DATA_BUS] wb_reg_write_data_o,    
    output reg[`REG_ADDR_BUS] wb_reg_write_addr_o,
    output reg wb_reg_write_en_o,

    output reg[`REG_DATA_BUS] wb_hi_write_data_o,
    output reg[`REG_DATA_BUS] wb_lo_write_data_o,
    output reg wb_hilo_write_en_o,

	output reg wb_cp0_reg_write_en_o,
	output reg[4:0] wb_cp0_reg_write_addr_o,
	output reg[`REG_DATA_BUS] wb_cp0_reg_write_data_o,

	output reg wb_LLbit_write_en_o,
	output reg wb_LLbit_data_o

);
    /*
    assign {wb_reg_write_addr_o,    wb_reg_write_en_o,          wb_reg_write_data_o,        wb_hi_write_data_o,
		    wb_lo_write_data_o,     wb_hilo_write_en_o,         wb_LLbit_write_en_o,        wb_LLbit_data_o,
			wb_cp0_reg_write_en_o,  wb_cp0_reg_write_addr_o,    wb_cp0_reg_write_data_o,    wb_pc_o}            = !resetn ? 

           {`NOP_REG_ADDR,          `WRITE_DISABLE,             `ZEROWORD,                  `ZEROWORD, 
            `ZEROWORD,              `WRITE_DISABLE,             1'b0,                       1'b0, 
            `WRITE_DISABLE,         5'b00000,                   `ZEROWORD,                  `ZEROWORD}                    : 
            
           {wb_reg_write_addr_i,    wb_reg_write_en_i,          wb_reg_write_data_i,        wb_hi_write_data_i,
		    wb_lo_write_data_i,     wb_hilo_write_en_i,         wb_LLbit_write_en_i,        wb_LLbit_data_i,
			wb_cp0_reg_write_en_i,  wb_cp0_reg_write_addr_i,    wb_cp0_reg_write_data_i,    wb_pc_i};
    */

    always @ (*) 
    begin
		if(resetn == `RST_ENABLE) 
        begin
			wb_reg_write_addr_o <= `NOP_REG_ADDR;
			wb_reg_write_en_o <= `WRITE_DISABLE;
		    wb_reg_write_data_o <= `ZEROWORD;	
		    wb_hi_write_data_o <= `ZEROWORD;
		    wb_lo_write_data_o <= `ZEROWORD;
		    wb_hilo_write_en_o <= `WRITE_DISABLE;	
			wb_LLbit_write_en_o <= 1'b0;
			wb_LLbit_data_o <= 1'b0;
			wb_cp0_reg_write_en_o <= `WRITE_DISABLE;
			wb_cp0_reg_write_addr_o <= 5'b00000;
			wb_cp0_reg_write_data_o <= `ZEROWORD;
			wb_pc_o <= `ZEROWORD;
        end else if(stall_req_from_arbiter) begin
            wb_reg_write_addr_o <= wb_reg_write_addr_i;
			wb_reg_write_en_o <= 1'b0;
			wb_reg_write_data_o <= wb_reg_write_data_i;
			wb_hi_write_data_o <= wb_hi_write_data_i;
			wb_lo_write_data_o <= wb_lo_write_data_i;
			wb_hilo_write_en_o <= wb_hilo_write_en_i;		
			wb_LLbit_write_en_o <= wb_LLbit_write_en_i;
			wb_LLbit_data_o <= wb_LLbit_data_i;
			wb_cp0_reg_write_en_o <= wb_cp0_reg_write_en_i;
			wb_cp0_reg_write_addr_o <= wb_cp0_reg_write_addr_i;
			wb_cp0_reg_write_data_o <= wb_cp0_reg_write_data_i;	
			wb_pc_o <= wb_pc_i;
		end else begin
			wb_reg_write_addr_o <= wb_reg_write_addr_i;
			wb_reg_write_en_o <= wb_reg_write_en_i;
			wb_reg_write_data_o <= wb_reg_write_data_i;
			wb_hi_write_data_o <= wb_hi_write_data_i;
			wb_lo_write_data_o <= wb_lo_write_data_i;
			wb_hilo_write_en_o <= wb_hilo_write_en_i;		
			wb_LLbit_write_en_o <= wb_LLbit_write_en_i;
			wb_LLbit_data_o <= wb_LLbit_data_i;
			wb_cp0_reg_write_en_o <= wb_cp0_reg_write_en_i;
			wb_cp0_reg_write_addr_o <= wb_cp0_reg_write_addr_i;
			wb_cp0_reg_write_data_o <= wb_cp0_reg_write_data_i;	
			wb_pc_o <= wb_pc_i;
		end    
	end     

endmodule