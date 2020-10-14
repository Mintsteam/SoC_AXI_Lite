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

    output reg[`ALU_OP_BUS] ex_alu_op,
    output reg[`ALU_SEL_BUS] ex_alu_sel,

    output reg[`REG_DATA_BUS] ex_reg_data_1,
    output reg[`REG_DATA_BUS] ex_reg_data_2,
    output reg[`REG_ADDR_BUS] ex_reg_write_addr,    
    output reg ex_reg_write_en

);

    always @ (posedge clk)
    begin
        ex_alu_op <= rst ? 0 :id_alu_op;
        ex_alu_sel <= rst ? 0 : id_alu_sel;
        ex_reg_data_1 <= rst ? 0 :id_reg_data_1;
        ex_reg_data_2 <= rst ? 0 : id_reg_data_2;
        ex_reg_write_addr <= rst ? 0 : id_reg_write_addr;
        ex_reg_write_addr <= rst ? 0 : id_reg_write_en;	
    end

endmodule