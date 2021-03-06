`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"
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
    input wire[`ALU_OP_BUS] ex_alu_op_i,

    //forwarding from mem
    input wire mem_reg_write_en_i,
    input wire[`REG_DATA_BUS] mem_reg_write_data_i,
    input wire[`REG_ADDR_BUS] mem_reg_write_addr_i,

    //branch
    input wire is_in_delayslot_i,
    output reg next_inst_in_delayslot_o,
    output reg branch_flag_o,
    output reg[`REG_DATA_BUS] branch_target_addr_o,
    output reg[`REG_DATA_BUS] link_addr_o,
    output reg is_in_delayslot_o,

    output reg[`ALU_OP_BUS] alu_op_o,
    output reg[`ALU_SEL_BUS] alu_sel_o,
    output reg[`REG_DATA_BUS] operand_1_o,
    output reg[`REG_DATA_BUS] operand_2_o,

    output wire[`REG_DATA_BUS] inst_data_o,

    output wire stall_req,
    output wire[31:0] exception_type_o,
    output wire[`REG_DATA_BUS] current_inst_addr_o

);

    //opcode acquire
    wire[5:0] op = inst_data[31:26];
    wire[4:0] op2 = inst_data[10:6];
    wire[5:0] op3 = inst_data[5:0];
    wire[4:0] op4 = inst_data[20:16];

    wire[`REG_DATA_BUS] pc_plus_8;
    wire[`REG_DATA_BUS] pc_plus_4;

    wire[`REG_DATA_BUS] branch_addr;

    reg exception_is_syscall;
    reg exception_is_eret;

    reg[`REG_DATA_BUS] imm;

    reg inst_valid;

    assign exception_type_o = {19'b0, exception_is_eret, 2'b0, inst_valid, exception_is_syscall, 8'b0};

    assign current_inst_addr_o = inst_addr;

    reg stall_req_for_reg1_loadrelate;
    reg stall_req_for_reg2_loadrelate;

    assign stall_req = stall_req_for_reg1_loadrelate | stall_req_for_reg2_loadrelate;

    wire pre_inst_is_load;

    assign pre_inst_is_load = ((ex_alu_op_i == `EXE_LB_OP) || (ex_alu_op_i == `EXE_LBU_OP) || (ex_alu_op_i == `EXE_LH_OP) || (ex_alu_op_i == `EXE_LHU_OP) || (ex_alu_op_i == `EXE_LW_OP) || (ex_alu_op_i == `EXE_LWR_OP) || (ex_alu_op_i == `EXE_LWL_OP) || (ex_alu_op_i == `EXE_LL_OP) || (ex_alu_op_i == `EXE_SC_OP)) ? 1'b1 : 1'b0;

    assign inst_data_o = inst_data;

    assign pc_plus_8 = inst_addr + 8;
    assign pc_plus_4 = inst_addr + 4;

    assign branch_addr = {{14{inst_data[15]}}, inst_data[15:0], 2'b00};

    /*****decode*****/
    //signal initialization
    always @ (*) 
    begin	
        link_addr_o <= `ZEROWORD;
        branch_target_addr_o <= `ZEROWORD;
        branch_flag_o <= `NOT_BRANCH;
        next_inst_in_delayslot_o <= `NOT_IN_DELAY_SLOT;
        alu_op_o <= `EXE_NOP_OP;
        alu_sel_o <= `EXE_RES_NOP;
        reg_write_addr_o <= !rst ? 0 : inst_data[15:11];
        reg_write_en_o <= `WRITE_DISABLE;
        inst_valid <= !rst ? `INST_VALID : `INST_INVALID;   
        reg_read_en_1_o <= 0;
        reg_read_en_2_o <= 0;
        reg_read_addr_1_o <= !rst ? 0 : inst_data[25:21];
        reg_read_addr_2_o <= !rst ? 0 : inst_data[20:16];		
        imm <= `ZEROWORD;
        exception_is_syscall <= `FALSE;
        exception_is_eret <= `FALSE;

        //control signals generated based on the opcode
        case(op)
		    `EXE_SPECIAL_INST: begin    
	    	    case (op2)
	    		    5'b00000: begin  
					    case (op3)
	    				    `EXE_OR:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_OR_OP, `EXE_RES_LOGIC, 1'b1, 1'b1, 1'b0};
	    				    `EXE_AND:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_AND_OP, `EXE_RES_LOGIC, 1'b1, 1'b1, 1'b0};
		    			    `EXE_NOR:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_NOR_OP, `EXE_RES_LOGIC, 1'b1, 1'b1, 1'b0};
						    `EXE_SLLV:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SLL_OP, `EXE_RES_SHIFT, 1'b1, 1'b1, 1'b0};
						    `EXE_SRLV:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SRL_OP, `EXE_RES_SHIFT, 1'b1, 1'b1, 1'b0}; 
						    `EXE_SRAV:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SRA_OP, `EXE_RES_SHIFT, 1'b1, 1'b1, 1'b0};
						    `EXE_SYNC:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_NOP_OP, `EXE_RES_NOP  , 1'b0, 1'b1, 1'b0};
					        `EXE_MFHI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_MFHI_OP, `EXE_RES_MOVE, 1'b0, 1'b0, 1'b0};
						    `EXE_MFLO:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_MFLO_OP, `EXE_RES_MOVE, 1'b0, 1'b0, 1'b0};
					        `EXE_MTHI:{reg_write_en_o, alu_op_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MTHI_OP, 1'b1, 1'b0, 1'b0};
					        `EXE_MTLO:{reg_write_en_o, alu_op_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MTLO_OP, 1'b1, 1'b0, 1'b0};
					        `EXE_MOVN:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {operand_2_o ? 1:0, `EXE_MOVN_OP, `EXE_RES_MOVE, 1'b1, 1'b1, 1'b0};
					        `EXE_MOVZ:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {operand_2_o ? 0:1, `EXE_MOVZ_OP, `EXE_RES_MOVE, 1'b1, 1'b1, 1'b0};
                            `EXE_SLT:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SLT_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b1, 1'b0};
                            `EXE_SLTU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SLTU_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b1, 1'b0};
                            `EXE_ADD:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_ADD_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b1, 1'b0};
                            `EXE_ADDU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_ADDU_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b1, 1'b0};
                            `EXE_SUB:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SUB_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b1, 1'b0};
                            `EXE_SUBU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SUBU_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b1, 1'b0};
                            `EXE_MULT:{reg_write_en_o, alu_op_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MULT_OP, 1'b1, 1'b1, 1'b0};
                            `EXE_MULTU:{reg_write_en_o, alu_op_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MULTU_OP, 1'b1, 1'b1, 1'b0};
                            `EXE_DIV:{reg_write_en_o, alu_op_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_DIV_OP, 1'b1, 1'b1, 1'b0};
                            `EXE_DIVU:{reg_write_en_o, alu_op_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_DIVU_OP, 1'b1, 1'b1, 1'b0};
                            `EXE_JR:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, link_addr_o, branch_target_addr_o, branch_flag_o, next_inst_in_delayslot_o, inst_valid} <= {1'b0, `EXE_JR_OP, `EXE_RES_JUMP_BRANCH, 1'b1, 1'b0, `ZEROWORD, operand_1_o, `BRANCH, `IN_DELAY_SLOT, 1'b0};
                            `EXE_JALR:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, link_addr_o, branch_target_addr_o, branch_flag_o, next_inst_in_delayslot_o, inst_valid} <= {1'b1, `EXE_JALR_OP, `EXE_RES_JUMP_BRANCH, 1'b1, 1'b0, pc_plus_8, operand_1_o, `BRANCH, `IN_DELAY_SLOT, 1'b0};
                            `EXE_TEQ:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_TEQ_OP, `EXE_RES_NOP, 1'b0, 1'b0, 1'b0};
                            `EXE_TGE:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_TGE_OP, `EXE_RES_NOP, 1'b1, 1'b1, 1'b0};
                            `EXE_TGEU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_TGEU_OP, `EXE_RES_NOP, 1'b1, 1'b1, 1'b0};
                            `EXE_TLT:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_TLT_OP, `EXE_RES_NOP, 1'b1, 1'b1, 1'b0};
                            `EXE_TLTU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_TLTU_OP, `EXE_RES_NOP, 1'b1, 1'b1, 1'b0};
                            `EXE_TNE:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_TNE_OP, `EXE_RES_NOP, 1'b1, 1'b1, 1'b0};
                            `EXE_SYSCALL:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid, exception_is_syscall} <= {1'b0, `EXE_SYSCALL_OP, `EXE_RES_NOP, 1'b0, 1'b0, 1'b0, `TRUE};
                            default:begin end
                        endcase     //op3 end
                    end
                    default:begin end
			    endcase     //op2 end
            end								  
		    `EXE_ORI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_OR_OP, `EXE_RES_LOGIC, 1'b1, 1'b0, {16'h0, inst_data[15:0]}, inst_data[20:16], 1'b0};
	  	    `EXE_ANDI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_AND_OP, `EXE_RES_LOGIC, 1'b1, 1'b0, {16'h0, inst_data[15:0]}, inst_data[20:16], 1'b0};
	  	    `EXE_XORI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_XOR_OP, `EXE_RES_LOGIC, 1'b1, 1'b0, {16'h0, inst_data[15:0]}, inst_data[20:16], 1'b0};	
		    `EXE_LUI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_OR_OP, `EXE_RES_LOGIC, 1'b1, 1'b0, {inst_data[15:0], 16'h0}, inst_data[20:16], 1'b0};
		    `EXE_PREF:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_NOP_OP, `EXE_RES_NOP, 1'b0, 1'b0, {inst_data[15:0], 16'h0}, inst_data[20:16], 1'b0};						  	            
            `EXE_SLTI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_SLT_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b0, {{16{inst_data[15]}}, inst_data[15:0]}, inst_data[20:16], 1'b0};  
            `EXE_SLTIU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_SLTU_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b0, {{16{inst_data[15]}}, inst_data[15:0]}, inst_data[20:16], 1'b0};
            `EXE_ADDI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_ADDI_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b0, {{16{inst_data[15]}}, inst_data[15:0]}, inst_data[20:16], 1'b0};
            `EXE_ADDIU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_ADDIU_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b0, {{16{inst_data[15]}}, inst_data[15:0]}, inst_data[20:16], 1'b0};
            `EXE_J:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, link_addr_o, branch_flag_o, next_inst_in_delayslot_o, inst_valid, branch_target_addr_o} <= {1'b0, `EXE_J_OP, `EXE_RES_JUMP_BRANCH, 1'b0, 1'b0, `ZEROWORD, `BRANCH, `IN_DELAY_SLOT, 1'b0, {pc_plus_4[31:28], inst_data[25:0], 2'b00}};
            `EXE_JAL:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, reg_write_addr_o, link_addr_o, branch_flag_o, next_inst_in_delayslot_o, inst_valid, branch_target_addr_o} <= {1'b1, `EXE_JAL_OP, `EXE_RES_JUMP_BRANCH, 1'b0, 1'b0, 5'b11111, pc_plus_8, `BRANCH, `IN_DELAY_SLOT, 1'b0, {pc_plus_4[31:28], inst_data[25:0], 2'b00}};
            `EXE_BEQ: begin
                reg_write_en_o <= `WRITE_DISABLE;
                alu_op_o <= `EXE_BEQ_OP;
                alu_sel_o <= `EXE_RES_JUMP_BRANCH;
                reg_read_en_1_o <= 1'b1;
                reg_read_en_2_o <= 1'b1;
                inst_valid <= `INST_VALID;
                if(operand_1_o == operand_2_o)
                begin
                    branch_target_addr_o <= pc_plus_4 + branch_addr;
                    branch_flag_o <= `BRANCH;
                    next_inst_in_delayslot_o <= `IN_DELAY_SLOT;
                end
            end
            `EXE_BGTZ: begin
                reg_write_en_o <= `WRITE_DISABLE;
                alu_op_o <= `EXE_BGTZ_OP;
                alu_sel_o <= `EXE_RES_JUMP_BRANCH;
                reg_read_en_1_o <= 1'b1;
                reg_read_en_2_o <= 1'b0;
                inst_valid <= `INST_VALID;
                if(operand_1_o[31] == 1'b0 || operand_1_o != `ZEROWORD)
                begin
                    branch_target_addr_o <= pc_plus_4 + branch_addr;
                    branch_flag_o <= `BRANCH;
                    next_inst_in_delayslot_o <= `IN_DELAY_SLOT;
                end
            end
            `EXE_BLEZ: begin
                reg_write_en_o <= `WRITE_DISABLE;
                alu_op_o <= `EXE_BLEZ_OP;
                alu_sel_o <= `EXE_RES_JUMP_BRANCH;
                reg_read_en_1_o <= 1'b1;
                reg_read_en_2_o <= 1'b0;
                inst_valid <= `INST_VALID;
                if(operand_1_o[31] == 1'b1 || operand_1_o == `ZEROWORD)
                begin
                    branch_target_addr_o <= pc_plus_4 + branch_addr;
                    branch_flag_o <= `BRANCH;
                    next_inst_in_delayslot_o <= `IN_DELAY_SLOT;
                end
            end
            `EXE_BNE: begin
                reg_write_en_o <= `WRITE_DISABLE;
                alu_op_o <= `EXE_BNE_OP;
                alu_sel_o <= `EXE_RES_JUMP_BRANCH;
                reg_read_en_1_o <= 1'b1;
                reg_read_en_2_o <= 1'b1;
                inst_valid <= `INST_VALID;
                if(operand_1_o != operand_2_o)
                begin
                    branch_target_addr_o <= pc_plus_4 + branch_addr;
                    branch_flag_o <= `BRANCH;
                    next_inst_in_delayslot_o <= `IN_DELAY_SLOT;
                end
            end
            `EXE_LB:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_LB_OP, `EXE_RES_LOAD_STORE, 1'b1, 1'b0, inst_data[20:16], 1'b0};
            `EXE_LBU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_LBU_OP, `EXE_RES_LOAD_STORE, 1'b1, 1'b0, inst_data[20:16], 1'b0};
            `EXE_LH:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_LH_OP, `EXE_RES_LOAD_STORE, 1'b1, 1'b0, inst_data[20:16], 1'b0};
            `EXE_LHU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_LHU_OP, `EXE_RES_LOAD_STORE, 1'b1, 1'b0, inst_data[20:16], 1'b0};
            `EXE_LW:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_LW_OP, `EXE_RES_LOAD_STORE, 1'b1, 1'b0, inst_data[20:16], 1'b0};
            `EXE_LWL:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_LWL_OP, `EXE_RES_LOAD_STORE, 1'b1, 1'b1, inst_data[20:16], 1'b0};
            `EXE_LWR:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_LWR_OP, `EXE_RES_LOAD_STORE, 1'b1, 1'b1, inst_data[20:16], 1'b0};
            `EXE_SB:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_SB_OP, `EXE_RES_LOAD_STORE, 1'b1, 1'b1, 1'b0};
            `EXE_SH:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_SH_OP, `EXE_RES_LOAD_STORE, 1'b1, 1'b1, 1'b0};
            `EXE_SW:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_SW_OP, `EXE_RES_LOAD_STORE, 1'b1, 1'b1, 1'b0};
            `EXE_SWL:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_SWL_OP, `EXE_RES_LOAD_STORE, 1'b1, 1'b1, 1'b0};
            `EXE_SWR:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_SWR_OP, `EXE_RES_LOAD_STORE, 1'b1, 1'b1, 1'b0};
            `EXE_LL:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_LL_OP, `EXE_RES_LOAD_STORE, 1'b1, 1'b0, inst_data[20:16], 1'b0};
            `EXE_SC:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_SC_OP, `EXE_RES_LOAD_STORE, 1'b1, 1'b1, inst_data[20:16], 1'b0};
            `EXE_REGIMM_INST: begin
                case(op4)
                    `EXE_BGEZ: begin
                        reg_write_en_o <= `WRITE_DISABLE;
                        alu_op_o <= `EXE_BGEZ_OP;
                        alu_sel_o <= `EXE_RES_JUMP_BRANCH;
                        reg_read_en_1_o <= 1'b1;
                        reg_read_en_2_o <= 1'b0;
                        inst_valid <= `INST_VALID;
                        if(operand_1_o[31] == 1'b0)
                        begin
                            branch_target_addr_o <= pc_plus_4 + branch_addr;
                            branch_flag_o <= `BRANCH;
                            next_inst_in_delayslot_o <= `IN_DELAY_SLOT;
                        end
                    end
                    `EXE_BGEZAL: begin
                        reg_write_en_o <= `WRITE_ENABLE;
                        alu_op_o <= `EXE_BGEZAL_OP;
                        alu_sel_o <= `EXE_RES_JUMP_BRANCH;
                        reg_read_en_1_o <= 1'b1;
                        reg_read_en_2_o <= 1'b0;
                        link_addr_o <= pc_plus_8;
                        reg_write_addr_o <= 5'b11111;
                        inst_valid <= `INST_VALID;
                        if(operand_1_o[31] == 1'b0)
                        begin
                            branch_target_addr_o <= pc_plus_4 + branch_addr;
                            branch_flag_o <= `BRANCH;
                            next_inst_in_delayslot_o <= `IN_DELAY_SLOT;
                        end
                    end
                    `EXE_BLTZ: begin
                        reg_write_en_o <= `WRITE_ENABLE;
                        alu_op_o <= `EXE_BLTZ_OP;
                        alu_sel_o <= `EXE_RES_JUMP_BRANCH;
                        reg_read_en_1_o <= 1'b1;
                        reg_read_en_2_o <= 1'b0;
                        inst_valid <= `INST_VALID;
                        if(operand_1_o[31] == 1'b1)
                        begin
                            branch_target_addr_o <= pc_plus_4 + branch_addr;
                            branch_flag_o <= `BRANCH;
                            next_inst_in_delayslot_o <= `IN_DELAY_SLOT;
                        end
                    end
                    `EXE_BLTZAL: begin
                        reg_write_en_o <= `WRITE_ENABLE;
                        alu_op_o <= `EXE_BLTZAL_OP;
                        alu_sel_o <= `EXE_RES_JUMP_BRANCH;
                        reg_read_en_1_o <= 1'b1;
                        reg_read_en_2_o <= 1'b0;
                        link_addr_o <= pc_plus_8;
                        reg_write_addr_o <= 5'b11111;
                        inst_valid <= `INST_VALID;
                        if(operand_1_o[31] == 1'b1)
                        begin
                            branch_target_addr_o <= pc_plus_4 + branch_addr;
                            branch_flag_o <= `BRANCH;
                            next_inst_in_delayslot_o <= `IN_DELAY_SLOT;
                        end
                    end
                    `EXE_TEQI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, inst_valid} <= {1'b0, `EXE_TEQI_OP, `EXE_RES_NOP, 1'b1, 1'b0, {{16{inst_data[15]}}, inst_data[15:0]}, 1'b0};
                    `EXE_TGEI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, inst_valid} <= {1'b0, `EXE_TGEI_OP, `EXE_RES_NOP, 1'b1, 1'b0, {{16{inst_data[15]}}, inst_data[15:0]}, 1'b0};
                    `EXE_TGEIU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, inst_valid} <= {1'b0, `EXE_TGEIU_OP, `EXE_RES_NOP, 1'b1, 1'b0, {{16{inst_data[15]}}, inst_data[15:0]}, 1'b0};
                    `EXE_TLTI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, inst_valid} <= {1'b0, `EXE_TLTI_OP, `EXE_RES_NOP, 1'b1, 1'b0, {{16{inst_data[15]}}, inst_data[15:0]}, 1'b0};
                    `EXE_TLTIU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, inst_valid} <= {1'b0, `EXE_TLTIU_OP, `EXE_RES_NOP, 1'b1, 1'b0, {{16{inst_data[15]}}, inst_data[15:0]}, 1'b0};
                    `EXE_TNEI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, inst_valid} <= {1'b0, `EXE_TNEI_OP, `EXE_RES_NOP, 1'b1, 1'b0, {{16{inst_data[15]}}, inst_data[15:0]}, 1'b0};
                    default: begin end
                endcase     //op4 end
            end
            `EXE_SPECIAL_INST_2: begin
                case(op3)
                    `EXE_CLZ:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_CLZ_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b0, 1'b0};
                    `EXE_CLO:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_CLO_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b0, 1'b0};
                    `EXE_MUL:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_MUL_OP, `EXE_RES_ARITHMETIC, 1'b1, 1'b1, 1'b0};
                    `EXE_MADD:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MADD_OP, `EXE_RES_MUL, 1'b1, 1'b1, 1'b0};
                    `EXE_MADDU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MADDU_OP, `EXE_RES_MUL, 1'b1, 1'b1, 1'b0};
                    `EXE_MSUB:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MSUB_OP, `EXE_RES_MUL, 1'b1, 1'b1, 1'b0};
                    `EXE_MSUBU:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MSUBU_OP, `EXE_RES_MUL, 1'b1, 1'b1, 1'b0};
                    default:begin end
                endcase     //op3 end again
            end
            default:begin end
        endcase     //op1 end

        if(inst_data == `EXE_ERET)
        begin
            reg_write_en_o <= `WRITE_DISABLE;
            alu_op_o <= `EXE_ERET_OP;
            alu_sel_o <= `EXE_RES_NOP;
            reg_read_en_1_o <= 1'b0;
            reg_read_en_2_o <= 1'b0;
            inst_valid <= `INST_VALID;
            exception_is_eret <= `TRUE;
        end else if(inst_data[31:21] == 11'b01000000000 && inst_data[10:0] == 11'b00000000000)
        begin
            alu_op_o <= `EXE_MFC0_OP;
            alu_sel_o <= `EXE_RES_MOVE;
            reg_write_addr_o <= inst_data[20:16];
            reg_write_en_o <= `WRITE_ENABLE;
            inst_valid <= `INST_VALID;   
            reg_read_en_1_o <= 1'b0;
            reg_read_en_2_o <= 1'b0;
        end else if(inst_data[31:21] == 11'b01000000100 && inst_data[10:0] == 11'b00000000000) begin
            alu_op_o <= `EXE_MTC0_OP;
            alu_sel_o <= `EXE_RES_MOVE;
            reg_write_en_o <= `WRITE_DISABLE;
            inst_valid <= `INST_VALID;   
            reg_read_en_1_o <= 1'b1;
            reg_read_en_2_o <= 1'b0;
            reg_read_addr_1_o <= inst_data[20:16];
        end

	    if(inst_data[31:21] == 11'b00000000000) 
        begin
		    case (op3)
	            `EXE_SLL:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm[4:0], reg_write_addr_o, inst_valid} <= {1'b1, `EXE_SLL_OP, `EXE_RES_SHIFT, 1'b0, 1'b1, inst_data[10:6], inst_data[15:11], 1'b0};
	            `EXE_SRL:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm[4:0], reg_write_addr_o, inst_valid} <= {1'b1, `EXE_SRL_OP, `EXE_RES_SHIFT, 1'b0, 1'b1, inst_data[10:6], inst_data[15:11], 1'b0};		   
	            `EXE_SRA:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm[4:0], reg_write_addr_o, inst_valid} <= {1'b1, `EXE_SRA_OP, `EXE_RES_SHIFT, 1'b0, 1'b1, inst_data[10:6], inst_data[15:11], 1'b0};
                default:begin end
            endcase
	    end         	
    end    

    //operand_1_o acquire
	always @ (*) 
    begin
        stall_req_for_reg1_loadrelate <= `NOT_STOP;
        if(rst == `RST_ENABLE)
        begin
            operand_1_o <= `ZEROWORD;
        end else if(pre_inst_is_load == 1'b1 && ex_reg_write_addr_i == reg_read_addr_1_o && reg_read_en_1_o == 1'b1) begin
            stall_req_for_reg1_loadrelate <= `STOP;
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
        stall_req_for_reg2_loadrelate <= `NOT_STOP;
        if(rst == `RST_ENABLE)
        begin
            operand_2_o <= `ZEROWORD;
        end else if(pre_inst_is_load == 1'b1 && ex_reg_write_addr_i == reg_read_addr_2_o && reg_read_en_2_o == 1'b1) begin
            stall_req_for_reg2_loadrelate <= `STOP;
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

    always @ (*)
    begin
        if(rst == `RST_ENABLE)
        begin
            is_in_delayslot_o <= `NOT_IN_DELAY_SLOT;
        end else begin
            is_in_delayslot_o <= is_in_delayslot_i;
        end
    end

endmodule