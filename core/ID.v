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

    output reg[`ALU_OP_BUS] alu_op_o,
    output reg[`ALU_SEL_BUS] alu_sel_o,
    output reg[`REG_DATA_BUS] operand_1_o,
    output reg[`REG_DATA_BUS] operand_2_o

);
    //opcode acquire
    wire[5:0] op = inst_data[31:26];
    wire[4:0] op2 = inst_data[10:6];
    wire[5:0] op3 = inst_data[5:0];
    wire[4:0] op4 = inst_data[20:16];

    reg[`REG_DATA_BUS] imm;

    reg inst_valid;

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
        case (op)
		    `EXE_SPECIAL_INST:
            begin    
	    	    case (op2)
	    		    5'b00000:
                    begin      //special类且功能码为00000的指令
					    case (op3)
	    				    `EXE_OR:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_OR_OP, `EXE_RES_LOGIC, 1'b1, 1'b1, 1'b1};//或
	    				    `EXE_AND:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_AND_OP, `EXE_RES_LOGIC, 1'b1, 1'b1, 1'b1};//与
		    			    `EXE_XOR:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_XOR_OP, `EXE_RES_LOGIC, 1'b1, 1'b1, 1'b1};//异或		
		    			    `EXE_NOR:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_NOR_OP, `EXE_RES_LOGIC, 1'b1, 1'b1, 1'b1};//或非运算
						    `EXE_SLLV:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SLL_OP, `EXE_RES_SHIFT, 1'b1, 1'b1, 1'b1};//使用rs[16:20]为移动位数左移动
						    `EXE_SRLV:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SRL_OP, `EXE_RES_SHIFT, 1'b1, 1'b1, 1'b1};//使用rs[16:20]为移动位数右移动
						    `EXE_SRAV:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SRA_OP, `EXE_RES_SHIFT, 1'b1, 1'b1, 1'b1};//使用rs[16:20]为移动位数算数右移动
						    `EXE_SYNC:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_NOP_OP, `EXE_RES_NOP  , 1'b0, 1'b1, 1'b1};//空操作（保证加载，存储按照顺序执行）
					        `EXE_MFHI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_MFHI_OP, `EXE_RES_MOVE, 1'b0, 1'b0, 1'b1};//从hi寄存器读取到rd
						    `EXE_MFLO:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_MFLO_OP, `EXE_RES_MOVE, 1'b0, 1'b0, 1'b1};//从lo寄存器读取到rd
					        `EXE_MTHI:{reg_write_en_o, alu_op_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MTHI_OP, 1'b1, 1'b0, 1'b1};//从rs读到HI
					        `EXE_MTLO:{reg_write_en_o, alu_op_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MTLO_OP, 1'b1, 1'b0, 1'b1};//从rs读到LO
					        `EXE_MOVN:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {operand_2_o ? 1:0, `EXE_MOVN_OP, `EXE_RES_MOVE, 1'b1, 1'b1, 1'b1};//reg2！=0时，进行移位
					        `EXE_MOVZ:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {operand_2_o ? 0:1, `EXE_MOVZ_OP, `EXE_RES_MOVE, 1'b1, 1'b1, 1'b1};//reg==0时，进行移位
                            default:begin end
                        endcase 
                    end
                    default:begin end
			    endcase	
            end								  
		    `EXE_ORI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_OR_OP, `EXE_RES_LOGIC, 1'b1, 1'b0, {16'h0, inst_data[15:0]}, inst_data[20:16], 1'b1};//立即数或
	  	    `EXE_ANDI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_AND_OP, `EXE_RES_LOGIC, 1'b1, 1'b0, {16'h0, inst_data[15:0]}, inst_data[20:16], 1'b1};//立即数与
	  	    `EXE_XORI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_XOR_OP, `EXE_RES_LOGIC, 1'b1, 1'b0, {16'h0, inst_data[15:0]}, inst_data[20:16], 1'b1};//立即数异或		
		    `EXE_LUI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_OR_OP, `EXE_RES_LOGIC, 1'b1, 1'b0, { inst_data[15:0], 16'h0}, inst_data[20:16], 1'b1};//将立即数放到rd的高16位
		    `EXE_PREF:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_NOP_OP, `EXE_RES_NOP, 1'b0, 1'b0, { inst_data[15:0], 16'h0}, inst_data[20:16], 1'b1};//空操作（openmips没有实现缓存）						  	
            default:begin end
        endcase	

	    //这一段是通过指令6-10位的sa值进行移位操作的 
	    if(inst_data[31:21] == 11'b00000000000) 
        begin
		    case (op3)
	            `EXE_SLL:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm[4:0], reg_write_addr_o, inst_valid} <= {1'b1, `EXE_SLL_OP, `EXE_RES_SHIFT, 1'b0, 1'b1, inst_data[10:6], inst_data[15:11], 1'b1};//右移，用0填充，移动sa位【10-6】
	            `EXE_SRL:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm[4:0], reg_write_addr_o, inst_valid} <= {1'b1, `EXE_SRL_OP, `EXE_RES_SHIFT, 1'b0, 1'b1, inst_data[10:6], inst_data[15:11], 1'b1};//右移，用0填充，移动sa位【10-6】		   
	            `EXE_SRA:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm[4:0], reg_write_addr_o, inst_valid} <= {1'b1, `EXE_SRA_OP, `EXE_RES_SHIFT, 1'b0, 1'b1, inst_data[10:6], inst_data[15:11], 1'b1};//算数右移，空出来的位置用rt【31】进行填充，移动sa位【10-6】
                default:begin end
            endcase
	    end         	
        end
        //operand_1_o acquire
	    always @ (*) 
        begin
            if(rst) begin
                operand_1_o <= `ZEROWORD;
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
            end else if(reg_read_en_2_o == 1'b1) begin
                operand_2_o <= reg_data_2_i;
            end else if(reg_read_en_2_o == 1'b0) begin
                operand_2_o <= imm;
            end else begin
                operand_2_o <= `ZEROWORD;
        end
	end

endmodule