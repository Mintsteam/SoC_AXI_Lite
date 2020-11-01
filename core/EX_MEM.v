`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"
`include "../define/opcode.vh"

module EX_MEM(

    input wire clk,
    input wire rst,

    input wire[`REG_DATA_BUS] ex_reg_write_data,
    input wire[`REG_ADDR_BUS] ex_reg_write_addr,
    input wire ex_reg_write_en,

    input wire[`REG_DATA_BUS] ex_hi_write_data,
    input wire[`REG_DATA_BUS] ex_lo_write_data,
    input wire ex_hilo_write_en,

    input wire[5:0] stall,
	input wire[`DOUBLE_REG_DATA_BUS] hilo_i,
	input wire[1:0] count_i,

	input wire[`ALU_OP_BUS] ex_alu_op,
	input wire[`REG_DATA_BUS] ex_mem_addr,
	input wire[`REG_DATA_BUS] ex_operand_2,

    output reg[`REG_DATA_BUS] mem_reg_write_data,    
    output reg[`REG_ADDR_BUS] mem_reg_write_addr,
    output reg mem_reg_write_en,

    output reg[`REG_DATA_BUS] mem_hi_write_data,
    output reg[`REG_DATA_BUS] mem_lo_write_data,
    output reg mem_hilo_write_en,

	output reg[`DOUBLE_REG_DATA_BUS] hilo_o,
	output reg[1:0] count_o,

	output reg[`ALU_OP_BUS] mem_alu_op,
	output reg[`REG_DATA_BUS] mem_mem_addr,
	output reg[`REG_DATA_BUS] mem_operand_2

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

    always @ (posedge clk) 
    begin
		if(rst == `RST_ENABLE) 
        begin
			mem_reg_write_addr <= `NOP_REG_ADDR;
			mem_reg_write_en <= `WRITE_DISABLE;
		    mem_reg_write_data <= `ZEROWORD;	
		    mem_hi_write_data <= `ZEROWORD;
		    mem_lo_write_data <= `ZEROWORD;
		    mem_hilo_write_en <= `WRITE_DISABLE;		
	        hilo_o <= {`ZEROWORD, `ZEROWORD};
			count_o <= 2'b00;	
			mem_alu_op <= `EXE_NOP_OP;
			mem_mem_addr <= `ZEROWORD;
			mem_operand_2 <= `ZEROWORD;
		end else if(stall[3] == `STOP && stall[4] == `NOT_STOP) begin
			mem_reg_write_addr <= `NOP_REG_ADDR;
			mem_reg_write_en <= `WRITE_DISABLE;
		    mem_reg_write_data <= `ZEROWORD;
		    mem_hi_write_data <= `ZEROWORD;
		    mem_lo_write_data <= `ZEROWORD;
		    mem_hilo_write_en <= `WRITE_DISABLE;
	        hilo_o <= hilo_i;
			count_o <= count_i;	
			mem_alu_op <= `EXE_NOP_OP;
			mem_mem_addr <= `ZEROWORD;
			mem_operand_2 <= `ZEROWORD;		  				    
		end else if(stall[3] == `NOT_STOP) begin
			mem_reg_write_addr <= ex_reg_write_addr;
			mem_reg_write_en <= ex_reg_write_en;
			mem_reg_write_data <= ex_reg_write_data;	
			mem_hi_write_data <= ex_hi_write_data;
			mem_lo_write_data <= ex_lo_write_data;
			mem_hilo_write_en <= ex_hilo_write_en;	
	        hilo_o <= {`ZEROWORD, `ZEROWORD};
			count_o <= 2'b00;	
			mem_alu_op <= ex_alu_op;
			mem_mem_addr <= ex_mem_addr;
			mem_operand_2 <= ex_operand_2;
		end else begin
	        hilo_o <= hilo_i;
			count_o <= count_i;											
		end    
	end      

endmodule