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

    output reg[`ALU_OP_BUS] ex_alu_op,
    output reg[`ALU_SEL_BUS] ex_alu_sel,

    output reg[`REG_DATA_BUS] ex_reg_data_1,
    output reg[`REG_DATA_BUS] ex_reg_data_2,
    output reg[`REG_ADDR_BUS] ex_reg_write_addr,    
    output reg ex_reg_write_en

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
		end else if(stall[2] == `STOP && stall[3] == `NOT_STOP) begin
			ex_alu_op <= `EXE_NOP_OP;
			ex_alu_sel <= `EXE_RES_NOP;
			ex_reg_data_1 <= `ZEROWORD;
			ex_reg_data_2 <= `ZEROWORD;
			ex_reg_write_addr <= `NOP_REG_ADDR;
			ex_reg_write_en <= `WRITE_DISABLE;			
		end else if(stall[2] == `NOT_STOP) begin		
			ex_alu_op <= id_alu_op;
			ex_alu_sel <= id_alu_sel;
			ex_reg_data_1 <= id_reg_data_1;
			ex_reg_data_2 <= id_reg_data_2;
			ex_reg_write_addr <= id_reg_write_addr;
			ex_reg_write_en <= id_reg_write_en;		
		end
	end

endmodule