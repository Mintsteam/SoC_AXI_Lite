`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"
`include "../define/opcode.vh"

module EX(

    input wire rst,

    input wire[`ALU_OP_BUS] alu_op_i,
    input wire[`ALU_SEL_BUS] alu_sel_i,

    input wire[`REG_DATA_BUS] operand_1_i,
    input wire[`REG_DATA_BUS] operand_2_i,
    input wire[`REG_ADDR_BUS] reg_write_addr_i,
    input wire reg_write_en_i,

    input wire[`REG_DATA_BUS] hi_read_data_i,
    input wire[`REG_DATA_BUS] lo_read_data_i,

    //forwarding from mem
    input wire[`REG_DATA_BUS] mem_hi_write_data_i,
    input wire[`REG_DATA_BUS] mem_lo_write_data_i,
    input wire mem_hilo_write_en_i,

    //forwarding from wb
    input wire[`REG_DATA_BUS] wb_hi_write_data_i,
    input wire[`REG_DATA_BUS] wb_lo_write_data_i,
    input wire wb_hilo_write_en_i,

    output reg[`REG_DATA_BUS] reg_write_data_o,
    output reg[`REG_ADDR_BUS] reg_write_addr_o,    
    output reg reg_write_en_o,
    
    output reg[`REG_DATA_BUS] hi_write_data_o,
    output reg[`REG_DATA_BUS] lo_write_data_o,
    output reg hilo_write_en_o

);

    reg[`REG_DATA_BUS] logic_out;
    reg[`REG_DATA_BUS] shift_out;
    reg[`REG_DATA_BUS] move_out;
    reg[`REG_DATA_BUS] hi_out;
    reg[`REG_DATA_BUS] lo_out;

    always @ (*)
    begin
        if(rst == `RST_ENABLE)
        begin
            {hi_out, lo_out} <= {`ZEROWORD, `ZEROWORD};
        end else if(mem_hilo_write_en_i == `WRITE_ENABLE) begin
            {hi_out, lo_out} <= {mem_hi_write_data_i, mem_lo_write_data_i};
        end else if(wb_hilo_write_en_i == `WRITE_ENABLE) begin
            {hi_out, lo_out} <= {wb_hi_write_data_i, wb_lo_write_data_i};
        end else begin
            {hi_out, lo_out} <= {hi_read_data_i, lo_read_data_i};
        end
    end

    always @ (*) 
    begin
        case (alu_op_i)
            `EXE_OR_OP:logic_out <= rst ? 0 : operand_1_i | operand_2_i;
            `EXE_AND_OP:logic_out <= rst ? 0 : operand_1_i & operand_2_i;
            `EXE_NOR_OP:logic_out <= rst ? 0 : ~(operand_1_i | operand_2_i);
            `EXE_XOR_OP:logic_out <= rst ? 0 : operand_1_i ^ operand_2_i;
            default:logic_out <= `ZEROWORD;
        endcase
	end   

    always @ (*)
    begin
        case (alu_op_i)
            `EXE_SLL_OP:shift_out <= rst ? 0 : operand_2_i << operand_1_i[4:0];
            `EXE_SRL_OP:shift_out <= rst ? 0 : operand_2_i >> operand_1_i[4:0];
            `EXE_SRA_OP:shift_out <= rst ? 0 : ( { 32 { operand_2_i[31] } } << ( 6'd32 - { 1'b0, operand_1_i[4:0] } ) ) | operand_2_i>> operand_1_i[4:0];
            default:shift_out <= `ZEROWORD;
        endcase
    end

    always @ (*)
    begin
        case(alu_op_i)
            `EXE_MFHI_OP:move_out <= rst ? 0 : hi_out;
            `EXE_MFLO_OP:move_out <= rst ? 0 : lo_out;
            `EXE_MOVZ_OP:move_out <= rst ? 0 : operand_1_i;
            `EXE_MOVN_OP:move_out <= rst ? 0 : operand_1_i;
            default:move_out <= `ZEROWORD;
        endcase
    end

    always @ (*) 
    begin
	    reg_write_en_o <= reg_write_en_i;	 	 	
	    reg_write_addr_o <= reg_write_addr_i;
	    case (alu_sel_i) 
            `EXE_RES_LOGIC:reg_write_data_o <= logic_out;
            `EXE_RES_SHIFT:reg_write_data_o <= shift_out;	
	 	    `EXE_RES_MOVE:reg_write_data_o <= move_out;
	 	    default:reg_write_data_o <= `ZEROWORD;
	    endcase
    end	

    always @ (*)
    begin
        if(rst == `RST_ENABLE)
        begin
            hilo_write_en_o <= `WRITE_DISABLE;
            hi_write_data_o <= `ZEROWORD;
            lo_write_data_o <= `ZEROWORD;
        end else if(alu_op_i == `EXE_MTHI_OP) begin
            hilo_write_en_o <= `WRITE_ENABLE;
            hi_write_data_o <= operand_1_i;
            lo_write_data_o <= lo_out;
        end else if(alu_op_i == `EXE_MTLO_OP) begin
            hilo_write_en_o <= `WRITE_ENABLE;
            hi_write_data_o <= hi_out;
            lo_write_data_o <= operand_1_i;
        end else begin
            hilo_write_en_o <= `WRITE_DISABLE;
            hi_write_data_o <= `ZEROWORD;
            lo_write_data_o <= `ZEROWORD;
        end
    end

endmodule