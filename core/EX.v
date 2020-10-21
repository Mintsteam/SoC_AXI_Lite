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

    input wire[`DOUBLE_REG_DATA_BUS] hilo_temp_i,
    input wire[1:0] count_i,

    output reg[`REG_DATA_BUS] reg_write_data_o,
    output reg[`REG_ADDR_BUS] reg_write_addr_o,    
    output reg reg_write_en_o,
    
    output reg[`REG_DATA_BUS] hi_write_data_o,
    output reg[`REG_DATA_BUS] lo_write_data_o,
    output reg hilo_write_en_o,
    
    output reg stall_req,

    output reg[`DOUBLE_REG_DATA_BUS] hilo_temp_o,
    output reg[1:0] count_o

);

    reg[`REG_DATA_BUS] logic_out;
    reg[`REG_DATA_BUS] shift_out;
    reg[`REG_DATA_BUS] move_out;
    reg[`REG_DATA_BUS] hi_out;
    reg[`REG_DATA_BUS] lo_out;
    reg[`DOUBLE_REG_DATA_BUS] mul_out;
    reg[`REG_DATA_BUS] arithmetic_out;
    reg[`DOUBLE_REG_DATA_BUS] hilo_temp1;
    reg madd_msub_stall_req;

    wire overflow;
    wire equal;
    wire smaller;
    wire[`REG_DATA_BUS] operand_2_complement;
    wire[`REG_DATA_BUS] operand_1_not;
    wire[`REG_DATA_BUS] sum_out;
    wire[`REG_DATA_BUS] operand_multiplicand;
    wire[`REG_DATA_BUS] operand_multiplier;
    wire[`DOUBLE_REG_DATA_BUS] hilo_temp;

    //******************************phase I****execute******************************//

    //execute arithmethic instructions
    assign operand_2_complement = ((alu_op_i == `EXE_SUB_OP) || (alu_op_i == `EXE_SUBU_OP) || (alu_op_i == `EXE_SLT_OP)) ? (~operand_2_i) + 1 : operand_2_i;

    assign sum_out = operand_1_i + operand_2_complement;

    assign overflow = ((!operand_1_i[31] && !operand_2_complement[31]) && sum_out[31]) || ((operand_1_i[31] && operand_2_complement[31]) && (!sum_out[31]));

    assign smaller = ((alu_op_i == `EXE_SLT_OP)) ? ((operand_1_i[31] && !operand_2_i[31]) || (operand_1_i[31] && !operand_2_i[31] && sum_out[31]) || (operand_1_i[31] && operand_2_i[31] && sum_out[31])) : (operand_1_i < operand_2_i);

    assign operand_1_not = ~operand_1_i;

    always @ (*)
    begin
        if(rst == `RST_ENABLE)
        begin
            arithmetic_out <= `ZEROWORD;
        end else begin
            case(alu_op_i)
                `EXE_SLT_OP, `EXE_SLTU_OP: begin
                    arithmetic_out <= smaller;
                end
                `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP: begin
                    arithmetic_out <= sum_out;
                end
                `EXE_SUB_OP, `EXE_SUBU_OP: begin
                    arithmetic_out <= sum_out;
                end
                `EXE_CLZ_OP: begin
                    arithmetic_out <= operand_1_i[31] ? 0 : operand_1_i[30] ? 1 :
                                    operand_1_i[29] ? 2 : operand_1_i[28] ? 3 : 
                                    operand_1_i[27] ? 4 : operand_1_i[26] ? 5 : 
                                    operand_1_i[25] ? 6 : operand_1_i[24] ? 7 : 
                                    operand_1_i[23] ? 8 : operand_1_i[22] ? 9 : 
                                    operand_1_i[21] ? 10 : operand_1_i[20] ? 11 : 
                                    operand_1_i[19] ? 12 : operand_1_i[18] ? 13 : 
                                    operand_1_i[17] ? 14 : operand_1_i[16] ? 15 : 
                                    operand_1_i[15] ? 16 : operand_1_i[14] ? 17 : 
                                    operand_1_i[13] ? 18 : operand_1_i[12] ? 19 : 
                                    operand_1_i[11] ? 20 : operand_1_i[10] ? 21 : 
                                    operand_1_i[9] ? 22 : operand_1_i[8] ? 23 : 
                                    operand_1_i[7] ? 24 : operand_1_i[6] ? 25 : 
                                    operand_1_i[5] ? 26 : operand_1_i[4] ? 27 : 
                                    operand_1_i[3] ? 28 : operand_1_i[2] ? 29 : 
                                    operand_1_i[1] ? 30 : operand_1_i[0] ? 31 : 32; 
                end 
                `EXE_CLO_OP: begin
                    arithmetic_out <= operand_1_not[31] ? 0 : operand_1_not[30] ? 1 :
                                    operand_1_not[29] ? 2 : operand_1_not[28] ? 3 : 
                                    operand_1_not[27] ? 4 : operand_1_not[26] ? 5 : 
                                    operand_1_not[25] ? 6 : operand_1_not[24] ? 7 : 
                                    operand_1_not[23] ? 8 : operand_1_not[22] ? 9 : 
                                    operand_1_not[21] ? 10 : operand_1_not[20] ? 11 : 
                                    operand_1_not[19] ? 12 : operand_1_not[18] ? 13 : 
                                    operand_1_not[17] ? 14 : operand_1_not[16] ? 15 : 
                                    operand_1_not[15] ? 16 : operand_1_not[14] ? 17 : 
                                    operand_1_not[13] ? 18 : operand_1_not[12] ? 19 : 
                                    operand_1_not[11] ? 20 : operand_1_not[10] ? 21 : 
                                    operand_1_not[9] ? 22 : operand_1_not[8] ? 23 : 
                                    operand_1_not[7] ? 24 : operand_1_not[6] ? 25 : 
                                    operand_1_not[5] ? 26 : operand_1_not[4] ? 27 : 
                                    operand_1_not[3] ? 28 : operand_1_not[2] ? 29 : 
                                    operand_1_not[1] ? 30 : operand_1_not[0] ? 31 : 32;
                end
                default: begin
                    arithmetic_out <= `ZEROWORD;
                end
            endcase 
        end
    end

    assign operand_multiplicand = (((alu_op_i == `EXE_MUL_OP) || (alu_op_i == `EXE_MULT_OP) || (alu_op_i == `EXE_MADD_OP) || (alu_op_i == `EXE_MSUB_OP)) && (operand_1_i[31] == 1'b1)) ? (~operand_1_i + 1) : operand_1_i;

    assign operand_multiplier = (((alu_op_i == `EXE_MUL_OP) || (alu_op_i == `EXE_MULT_OP) || (alu_op_i == `EXE_MADD_OP) || (alu_op_i == `EXE_MSUB_OP)) && (operand_2_i[31] == 1'b1)) ? (~operand_2_i + 1) : operand_2_i;
    
    assign hilo_temp = operand_multiplicand * operand_multiplier;

    //generate the result of multiply
    always @ (*) 
    begin
        if(rst == `RST_ENABLE) 
        begin
            mul_out <= {`ZEROWORD, `ZEROWORD};
        end else if((alu_op_i == `EXE_MULT_OP) || (alu_op_i == `EXE_MUL_OP) || (alu_op_i == `EXE_MADD_OP) || (alu_op_i == `EXE_MSUB_OP)) begin
            if(operand_1_i[31] ^ operand_2_i == 1'b1) 
            begin
                mul_out <= ~hilo_temp + 1;
            end else begin
                mul_out <= hilo_temp;
            end
        end else begin
            mul_out <= hilo_temp;
        end
    end

    //execute multiadd instructions
    always @ (*)
    begin
        if(rst == `RST_ENABLE)
        begin
            hilo_temp_o <= {`ZEROWORD, `ZEROWORD};
            count_o <= 2'b00;
            madd_msub_stall_req <= `NOT_STOP;
        end else begin
            case(alu_op_i) 
				`EXE_MADD_OP, `EXE_MADDU_OP: begin
					if(count_i == 2'b00) 
                    begin
						hilo_temp_o <= mul_out;
						count_o <= 2'b01;
						madd_msub_stall_req <= `STOP;
						hilo_temp1 <= {`ZEROWORD,`ZEROWORD};
					end else if(count_i == 2'b01) begin
						hilo_temp_o <= {`ZEROWORD,`ZEROWORD};						
						count_o <= 2'b10;
						hilo_temp1 <= hilo_temp_i + {hi_out, lo_out};
						madd_msub_stall_req <= `NOT_STOP;
					end
				end
				`EXE_MSUB_OP, `EXE_MSUBU_OP: begin
					if(count_i == 2'b00) 
                    begin
						hilo_temp_o <=  ~mul_out + 1 ;
						count_o <= 2'b01;
						madd_msub_stall_req <= `STOP;
                        hilo_temp1 <= {`ZEROWORD,`ZEROWORD};
					end else if(count_i == 2'b01)begin
						hilo_temp_o <= {`ZEROWORD,`ZEROWORD};						
						count_o <= 2'b10;
						hilo_temp1 <= hilo_temp_i + {hi_out, lo_out};
						madd_msub_stall_req <= `NOT_STOP;
					end				
				end
				default: begin
					hilo_temp_o <= {`ZEROWORD,`ZEROWORD};
					count_o <= 2'b00;
					madd_msub_stall_req <= `NOT_STOP;				
				end
			endcase
        end
    end 

    always @ (*)
    begin
        stall_req = madd_msub_stall_req;
    end

    //execute logic instructions
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

    //execute shift instructions
    always @ (*)
    begin
        case (alu_op_i)
            `EXE_SLL_OP:shift_out <= rst ? 0 : operand_2_i << operand_1_i[4:0];
            `EXE_SRL_OP:shift_out <= rst ? 0 : operand_2_i >> operand_1_i[4:0];
            `EXE_SRA_OP:shift_out <= rst ? 0 : ( { 32 { operand_2_i[31] } } << ( 6'd32 - { 1'b0, operand_1_i[4:0] } ) ) | operand_2_i>> operand_1_i[4:0];
            default:shift_out <= `ZEROWORD;
        endcase
    end

    //execute move instructions
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

    //******************************phase II****write to regs******************************//

    //select the result which will write back to REGFILE
    always @ (*) 
    begin
        reg_write_addr_o <= reg_write_addr_i;	 	
        if(((alu_op_i == `EXE_ADD_OP) || (alu_op_i == `EXE_ADDI_OP) || (alu_op_i == `EXE_SUB_OP)) && (overflow == 1'b1)) 
        begin
	 	    reg_write_en_o  <= `WRITE_DISABLE;
	    end else begin
	        reg_write_en_o <= reg_write_en_i;	
	    end
	    
	    case (alu_sel_i) 
            `EXE_RES_LOGIC:reg_write_data_o <= logic_out;
            `EXE_RES_SHIFT:reg_write_data_o <= shift_out;	
	 	    `EXE_RES_MOVE:reg_write_data_o <= move_out;
            `EXE_RES_ARITHMETIC:reg_write_data_o <= arithmetic_out;
            `EXE_RES_MUL:reg_write_data_o <= mul_out[31:0];
	 	    default:reg_write_data_o <= `ZEROWORD;
	    endcase
    end	

    //select the result which will write to the HILO
    always @ (*)
    begin
        if(rst == `RST_ENABLE)
        begin
            hilo_write_en_o <= `WRITE_DISABLE;
            hi_write_data_o <= `ZEROWORD;
            lo_write_data_o <= `ZEROWORD;
        end else if((alu_op_i == `EXE_MSUB_OP) || (alu_op_i == `EXE_MSUBU_OP)) begin
            hilo_write_en_o <= `WRITE_ENABLE;
            hi_write_data_o <= hilo_temp1[63:32];
            lo_write_data_o <= hilo_temp1[31:0]; 
        end else if((alu_op_i == `EXE_MADD_OP) || (alu_op_i == `EXE_MADDU_OP)) begin
            hilo_write_en_o <= `WRITE_ENABLE;
            hi_write_data_o <= hilo_temp1[63:32];
            lo_write_data_o <= hilo_temp1[31:0]; 
        end else if((alu_op_i == `EXE_MULT_OP) || (alu_op_i == `EXE_MULTU_OP)) begin
            hilo_write_en_o <= `WRITE_ENABLE;
            hi_write_data_o <= mul_out[63:32];
            lo_write_data_o <= mul_out[31:0];   
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

    //forwarding
    always @ (*)
    begin
        if(rst == `RST_ENABLE)
        begin
            hi_out <= `ZEROWORD;
            lo_out <= `ZEROWORD;
        end else if(mem_hilo_write_en_i == `WRITE_ENABLE) begin
            hi_out <= mem_hi_write_data_i;
            lo_out <= mem_lo_write_data_i;
        end else if(wb_hilo_write_en_i == `WRITE_ENABLE) begin
            hi_out <= wb_hi_write_data_i;
            lo_out <= wb_lo_write_data_i;
        end else begin
            hi_out <= hi_read_data_i;
            lo_out <= lo_read_data_i;
        end
    end

endmodule