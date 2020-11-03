`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"
`include "../define/opcode.vh"

module ID_EX(
    
    input wire clk,
    input wire rst,

    input wire[`ALU_OP_BUS] id_alu_op,      //type of the operation
    input wire[`ALU_SEL_BUS] id_alu_sel,    //subtype of the operation

    input wire[`REG_DATA_BUS] id_reg_data_1,    //operand_1
    input wire[`REG_DATA_BUS] id_reg_data_2,    //operand_2
    input wire[`REG_ADDR_BUS] id_reg_write_addr,    //reg addr which wll be wrote in the id stage 
    input wire id_reg_write_en,     //whether a reg will be wrote in the id stage

    input wire[5:0] stall,

	input wire[`REG_DATA_BUS] id_link_addr,
	input wire id_is_in_delayslot,
	input wire next_inst_in_delayslot_i,

	input wire[`REG_DATA_BUS] id_inst_data,

	input wire flush,
	input wire[`REG_DATA_BUS] id_current_inst_addr,
	input wire[31:0] id_exception_type,

    output reg[`ALU_OP_BUS] ex_alu_op,
    output reg[`ALU_SEL_BUS] ex_alu_sel,

    output reg[`REG_DATA_BUS] ex_reg_data_1,
    output reg[`REG_DATA_BUS] ex_reg_data_2,
    output reg[`REG_ADDR_BUS] ex_reg_write_addr,    
    output reg ex_reg_write_en,

	output reg[`REG_DATA_BUS] ex_link_addr,
	output reg ex_is_in_delayslot,
	output reg is_in_delayslot_o,

	output reg[`REG_DATA_BUS] ex_inst_data,

	output reg[`REG_DATA_BUS] ex_current_inst_addr,
	output reg[31:0] ex_exception_type

);

    always @ (posedge clk) 
    begin
		if (rst == `RST_ENABLE) 
        begin
			ex_alu_op <= `EXE_NOP_OP;
			ex_alu_sel <= `EXE_RES_NOP;
			ex_reg_data_1 <= `ZEROWORD;
			ex_reg_data_2 <= `ZEROWORD;
			ex_reg_write_addr <= `NOP_REG_ADDR;
			ex_reg_write_en <= `WRITE_DISABLE;
			ex_link_addr <= `ZEROWORD;
			ex_is_in_delayslot <= `NOT_IN_DELAY_SLOT;
	    	is_in_delayslot_o <= `NOT_IN_DELAY_SLOT;
			ex_inst_data <= `ZEROWORD;
			ex_exception_type <= `ZEROWORD;
			ex_current_inst_addr <= `ZEROWORD;
		end else if(flush == 1'b1) begin
			ex_alu_op <= `EXE_NOP_OP;
			ex_alu_sel <= `EXE_RES_NOP;
			ex_reg_data_1 <= `ZEROWORD;
			ex_reg_data_2 <= `ZEROWORD;
			ex_reg_write_addr <= `NOP_REG_ADDR;
			ex_reg_write_en <= `WRITE_DISABLE;
			ex_exception_type <= `ZEROWORD;
			ex_current_inst_addr <= `ZEROWORD;
			ex_is_in_delayslot <= `NOT_IN_DELAY_SLOT;
			is_in_delayslot_o <= `NOT_IN_DELAY_SLOT;	
			ex_current_inst_addr <= `ZEROWORD;
		end else if(stall[2] == `STOP && stall[3] == `NOT_STOP) begin
			ex_alu_op <= `EXE_NOP_OP;
			ex_alu_sel <= `EXE_RES_NOP;
			ex_reg_data_1 <= `ZEROWORD;
			ex_reg_data_2 <= `ZEROWORD;
			ex_reg_write_addr <= `NOP_REG_ADDR;
			ex_reg_write_en <= `WRITE_DISABLE;		
			ex_is_in_delayslot <= `NOT_IN_DELAY_SLOT;
			is_in_delayslot_o <= `NOT_IN_DELAY_SLOT;	
			ex_current_inst_addr <= `ZEROWORD;	
		end else if(stall[2] == `NOT_STOP) begin		
			ex_alu_op <= id_alu_op;
			ex_alu_sel <= id_alu_sel;
			ex_reg_data_1 <= id_reg_data_1;
			ex_reg_data_2 <= id_reg_data_2;
			ex_reg_write_addr <= id_reg_write_addr;
			ex_reg_write_en <= id_reg_write_en;	
			ex_link_addr <= id_link_addr;
			ex_is_in_delayslot <= id_is_in_delayslot;
			is_in_delayslot_o <= next_inst_in_delayslot_i;	
			ex_inst_data <= id_inst_data;
			ex_exception_type <= id_exception_type;
			ex_current_inst_addr <= id_current_inst_addr;
		end
	end

endmodule