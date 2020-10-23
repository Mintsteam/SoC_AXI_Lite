`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"
`include "../define/rom.vh"
`include "../define/opcode.vh"

module ID(

    input wire rst,

    input wire[`INST_ADDR_BUS] inst_addr,   //instruction address from pc
    input wire[`INST_DATA_BUS] inst_data,   //instruction data from rom    

    //write 
    output reg[`REG_ADDR_BUS] reg_write_addr_o,   //where to write 
    output reg reg_write_en_o,    //write enable

    //read channel 1
    input wire[`REG_DATA_BUS] reg_data_1_i,    
    output reg[`REG_ADDR_BUS] reg_read_addr_1_o,    
    output reg reg_read_en_1_o,

    //read channel 2
    input wire[`REG_DATA_BUS] reg_data_2_i,     
    output reg[`REG_ADDR_BUS] reg_read_addr_2_o,    
    output reg reg_read_en_2_o,

    //forwarding from ex
    input wire ex_reg_write_en_i,
    input wire[`REG_DATA_BUS] ex_reg_write_data_i,
    input wire[`REG_ADDR_BUS] ex_reg_write_addr_i,

    //forwarding from mem
    input wire mem_reg_write_en_i,
    input wire[`REG_DATA_BUS] mem_reg_write_data_i,
    input wire[`REG_ADDR_BUS] mem_reg_write_addr_i,

    output reg[`ALU_OP_BUS] alu_op_o,
    output reg[`ALU_SEL_BUS] alu_sel_o,
    output reg[`REG_DATA_BUS] operand_1_o,
    output reg[`REG_DATA_BUS] operand_2_o,

    output wire stall_req

);
    //opcode acquire
    wire[5:0] op = inst_data[31:26];
    wire[4:0] op2 = inst_data[10:6];
    wire[5:0] op3 = inst_data[5:0];
    wire[4:0] op4 = inst_data[20:16];

    reg[`REG_DATA_BUS] imm;

    reg inst_valid;

    assign stall_req = `NOT_STOP;

    /*****decode*****/
    //signal initialization
    always @ (*) 
    begin	
        alu_op_o <= `EXE_NOP_OP;
        alu_sel_o <= `EXE_RES_NOP;
        reg_write_addr_o <= rst ? 0 : inst_data[15:11];
        reg_write_en_o <= `WRITE_DISABLE;
        inst_valid <= `INST_VALID;   
        reg_read_en_1_o <= 0;
        reg_read_en_2_o <= 0;
        reg_read_addr_1_o <= rst ? 0 : inst_data[25:21];
        reg_read_addr_2_o <= rst ? 0 : inst_data[20:16];		
        imm <= `ZEROWORD;

        //control signals generated based on the opcode
        case(op)
		    `EXE_SPECIAL_INST: begin    
	    	    case (op2)
	    		    5'b00000: begin  
					    case (op3)
	    				    `EXE_OR:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_OR_OP, `EXE_RES_LOGIC, 1'b1, 1'b1, 1'b1};
	    				    `EXE_AND:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_AND_OP, `EXE_RES_LOGIC, 1'b1, 1'b1, 1'b1};
		    			    `EXE_NOR:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_NOR_OP, `EXE_RES_LOGIC, 1'b1, 1'b1, 1'b1};
						    `EXE_SLLV:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SLL_OP, `EXE_RES_SHIFT, 1'b1, 1'b1, 1'b1};
						    `EXE_SRLV:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SRL_OP, `EXE_RES_SHIFT, 1'b1, 1'b1, 1'b1};
						    `EXE_SRAV:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SRA_OP, `EXE_RES_SHIFT, 1'b1, 1'b1, 1'b1};
						    `EXE_SYNC:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_NOP_OP, `EXE_RES_NOP  , 1'b0, 1'b1, 1'b1};
					        `EXE_MFHI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_MFHI_OP, `EXE_RES_MOVE, 1'b0, 1'b0, 1'b1};
						    `EXE_MFLO:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_MFLO_OP, `EXE_RES_MOVE, 1'b0, 1'b0, 1'b1};
					        `EXE_MTHI:{reg_write_en_o, alu_op_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MTHI_OP, 1'b1, 1'b0, 1'b1};
					        `EXE_MTLO:{reg_write_en_o, alu_op_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MTLO_OP, 1'b1, 1'b0, 1'b1};
					        `EXE_MOVN:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {operand_2_o ? 1:0, `EXE_MOVN_OP, `EXE_RES_MOVE, 1'b1, 1'b1, 1'b1};
					        `EXE_MOVZ:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {operand_2_o ? 0:1, `EXE_MOVZ_OP, `EXE_RES_MOVE, 1'b1, 1'b1, 1'b1};
                            `EXE_SLT:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SLT_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b1, 1'b1};
                            `EXE_SLTU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SLTU_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b1, 1'b1};
                            `EXE_ADD:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_ADD_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b1, 1'b1};
                            `EXE_ADDU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_ADDU_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b1, 1'b1};
                            `EXE_SUB:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SUB_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b1, 1'b1};
                            `EXE_SUBU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SUBU_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b1, 1'b1};
                            `EXE_MULT:{reg_write_en_o, alu_op_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MULT_OP, 1'b1, 1'b1, 1'b1};
                            `EXE_MULTU:{reg_write_en_o, alu_op_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MULTU_OP, 1'b1, 1'b1, 1'b1};
                            `EXE_DIV:{reg_write_en_o, alu_op_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_DIV_OP, 1'b1, 1'b1, 1'b1};
                            `EXE_DIVU:{reg_write_en_o, alu_op_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_DIVU_OP, 1'b1, 1'b1, 1'b1};
                            default:begin end
                        endcase     //op3 end
                    end
                    default:begin end
			    endcase     //op2 end
            end								  
		    `EXE_ORI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_OR_OP, `EXE_RES_LOGIC, 1'b1, 1'b0, {16'h0, inst_data[15:0]}, inst_data[20:16], 1'b1};
	  	    `EXE_ANDI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_AND_OP, `EXE_RES_LOGIC, 1'b1, 1'b0, {16'h0, inst_data[15:0]}, inst_data[20:16], 1'b1};
	  	    `EXE_XORI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_XOR_OP, `EXE_RES_LOGIC, 1'b1, 1'b0, {16'h0, inst_data[15:0]}, inst_data[20:16], 1'b1};	
		    `EXE_LUI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_OR_OP, `EXE_RES_LOGIC, 1'b1, 1'b0, {inst_data[15:0], 16'h0}, inst_data[20:16], 1'b1};
		    `EXE_PREF:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_NOP_OP, `EXE_RES_NOP, 1'b0, 1'b0, {inst_data[15:0], 16'h0}, inst_data[20:16], 1'b1};						  	
            
            `EXE_SLTI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_SLT_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b0, {{16{inst_data[15]}}, inst_data[15:0]}, inst_data[20:16], 1'b1};  
            `EXE_SLTIU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_SLTU_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b0, {{16{inst_data[15]}}, inst_data[15:0]}, inst_data[20:16], 1'b1};
            `EXE_ADDI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_ADDI_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b0, {{16{inst_data[15]}}, inst_data[15:0]}, inst_data[20:16], 1'b1};
            `EXE_ADDIU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_ADDIU_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b0, {{16{inst_data[15]}}, inst_data[15:0]}, inst_data[20:16], 1'b1};
            `EXE_SPECIAL_INST_2: begin
                case(op3)
                    `EXE_CLZ:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_CLZ_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b0, 1'b1};
                    `EXE_CLO:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_CLO_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b0, 1'b1};
                    `EXE_MUL:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_MUL_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b1, 1'b1};
                    `EXE_MADD:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MADD_OP, `EXE_RES_MUL, 1'b1, 1'b1, 1'b1};
                    `EXE_MADDU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MADDU_OP, `EXE_RES_MUL, 1'b1, 1'b1, 1'b1};
                    `EXE_MSUB:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MSUB_OP, `EXE_RES_MUL, 1'b1, 1'b1, 1'b1};
                    `EXE_MSUBU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MSUBU_OP, `EXE_RES_MUL, 1'b1, 1'b1, 1'b1};
                    default:begin end
                endcase     //op3 end again
            end
            
            default:begin end
        endcase     //op1 end

	    if(inst_data[31:21] == 11'b00000000000) 
        begin
		    case (op3)
	            `EXE_SLL:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm[4:0], reg_write_addr_o, inst_valid} <= {1'b1, `EXE_SLL_OP, `EXE_RES_SHIFT, 1'b0, 1'b1, inst_data[10:6], inst_data[15:11], 1'b1};
	            `EXE_SRL:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm[4:0], reg_write_addr_o, inst_valid} <= {1'b1, `EXE_SRL_OP, `EXE_RES_SHIFT, 1'b0, 1'b1, inst_data[10:6], inst_data[15:11], 1'b1};		   
	            `EXE_SRA:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm[4:0], reg_write_addr_o, inst_valid} <= {1'b1, `EXE_SRA_OP, `EXE_RES_SHIFT, 1'b0, 1'b1, inst_data[10:6], inst_data[15:11], 1'b1};
                default:begin end
            endcase
	    end         	
    end    

    //operand_1_o acquire
	always @ (*) 
    begin
        if(rst) begin
            operand_1_o <= `ZEROWORD;
        end else if((reg_read_en_1_o == 1'b1) && (ex_reg_write_en_i == 1'b1) && (ex_reg_write_addr_i == reg_read_addr_1_o)) begin
            operand_1_o <= ex_reg_write_data_i;
        end else if((reg_read_en_1_o == 1'b1) && (mem_reg_write_en_i == 1'b1) && (mem_reg_write_addr_i == reg_read_addr_1_o)) begin
            operand_1_o <= mem_reg_write_data_i;
        end else if(reg_read_en_1_o == 1'b1) begin
            operand_1_o <= reg_data_1_i;
        end else if(reg_read_en_1_o == 1'b0) begin
            operand_1_o <= imm;
        end else begin
            operand_1_o <= `ZEROWORD;
        end
    end

    //operand_2_o acquire
	always @ (*) 
    begin
        if(rst) begin
            operand_2_o <= `ZEROWORD;
        end else if((reg_read_en_2_o == 1'b1) && (ex_reg_write_en_i == 1'b1) && (ex_reg_write_addr_i == reg_read_addr_2_o)) begin
            operand_2_o <= ex_reg_write_data_i;
        end else if((reg_read_en_2_o == 1'b1) && (mem_reg_write_en_i == 1'b1) && (mem_reg_write_addr_i == reg_read_addr_2_o)) begin
            operand_2_o <= mem_reg_write_data_i;    
        end else if(reg_read_en_2_o == 1'b1) begin
            operand_2_o <= reg_data_2_i;
        end else if(reg_read_en_2_o == 1'b0) begin
            operand_2_o <= imm;
        end else begin
            operand_2_o <= `ZEROWORD;
        end
    end

endmodule