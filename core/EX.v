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
    input wire[`REG_ADDR_BUS] write_addr_i,
    input wire write_en_i,

    output reg[`REG_DATA_BUS] write_data_o,
    output reg[`REG_ADDR_BUS] write_addr_o,    
    output reg write_en_o
    
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
	    write_en_o <= write_en_i;	 	 	
	    write_addr_o <= write_addr_i;
	    case (alu_sel) 
            `EXE_RES_LOGIC:write_data_o <= logic_out;
            //`EXE_RES_SHIFT:wdata_o <= shiftres;	
	 	    //`EXE_RES_MOVE:wdata_o <= moveres;
	 	    default:write_data_o <= `ZEROWORD;
	    endcase
    end	

endmodule