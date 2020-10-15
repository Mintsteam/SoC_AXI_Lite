`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"
`include "../define/opcode.vh"

module EX(

    input wire rst,

    input wire[`ALU_OP_BUS] alu_op,
    input wire[`ALU_SEL_BUS] alu_sel,

    input wire[`REG_DATA_BUS] operand_1,
    input wire[`REG_DATA_BUS] operand_2,
    input wire[`REG_ADDR_BUS] reg_write_addr_i,
    input wire reg_write_en_i,

    output reg[`REG_DATA_BUS] reg_write_data_o,
    output reg[`REG_ADDR_BUS] reg_write_addr_o,    
    output reg reg_write_en_o
    
);

    reg[`REG_DATA_BUS] logic_out;

    always @ (*) 
    begin
        case (alu_op)
            `EXE_OR_OP:logic_out <= rst ? 0 : operand_1 | operand_2;
            //`EXE_AND_OP:logic_out <= rst ? 0 : operand_1 & operand_2;
            //`EXE_NOR_OP:logic_out <= rst ? 0 : ~(operand_1 | operand_2);
            //`EXE_XOR_OP:logic_out <= rst ? 0 : operand_1 ^ operand_2;
            default:logic_out <= 0;
        endcase
	end   

    always @ (*) 
    begin
	    reg_write_en_o <= reg_write_en_i;	 	 	
	    reg_write_addr_o <= reg_write_addr_i;
	    case (alu_sel) 
            `EXE_RES_LOGIC:reg_write_data_o <= logic_out;
            //`EXE_RES_SHIFT:wdata_o <= shiftres;	
	 	    //`EXE_RES_MOVE:wdata_o <= moveres;
	 	    default:reg_write_data_o <= `ZEROWORD;
	    endcase
    end	

endmodule