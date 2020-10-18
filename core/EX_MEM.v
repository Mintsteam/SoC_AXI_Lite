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

    input wire[5:0] stall,

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
	        //hilo_o <= {`ZEROWORD, `ZEROWORD};
			//cnt_o <= 2'b00;	
		end else if(stall[3] == `STOP && stall[4] == `NOT_STOP) begin
			mem_reg_write_addr <= `NOP_REG_ADDR;
			mem_reg_write_en <= `WRITE_DISABLE;
		    mem_reg_write_data <= `ZEROWORD;
		    mem_hi_write_data <= `ZEROWORD;
		    mem_lo_write_data <= `ZEROWORD;
		    mem_hilo_write_en <= `WRITE_DISABLE;
	        //hilo_o <= hilo_i;
			//cnt_o <= cnt_i;			  				    
		end else if(stall[3] == `NOT_STOP) begin
			mem_reg_write_addr <= ex_reg_write_addr;
			mem_reg_write_en <= ex_reg_write_en;
			mem_reg_write_data <= ex_reg_write_data;	
			mem_hi_write_data <= ex_hi_write_data;
			mem_lo_write_data <= ex_lo_write_data;
			mem_hilo_write_en <= ex_hilo_write_en;	
	        //hilo_o <= {`ZEROWORD, `ZEROWORD};
			//cnt_o <= 2'b00;	
		end else begin
	        //hilo_o <= hilo_i;
			//cnt_o <= cnt_i;											
		end    
	end      

endmodule