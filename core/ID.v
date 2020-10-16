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
                    begin      //special���ҹ�����Ϊ00000��ָ��
					    case (op3)
	    				    `EXE_OR:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_OR_OP, `EXE_RES_LOGIC, 1'b1, 1'b1, 1'b1};//��
	    				    `EXE_AND:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_AND_OP, `EXE_RES_LOGIC, 1'b1, 1'b1, 1'b1};//��
		    			    `EXE_XOR:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_XOR_OP, `EXE_RES_LOGIC, 1'b1, 1'b1, 1'b1};//���		
		    			    `EXE_NOR:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_NOR_OP, `EXE_RES_LOGIC, 1'b1, 1'b1, 1'b1};//�������
						    `EXE_SLLV:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SLL_OP, `EXE_RES_SHIFT, 1'b1, 1'b1, 1'b1};//ʹ��rs[16:20]Ϊ�ƶ�λ�����ƶ�
						    `EXE_SRLV:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SRL_OP, `EXE_RES_SHIFT, 1'b1, 1'b1, 1'b1};//ʹ��rs[16:20]Ϊ�ƶ�λ�����ƶ�
						    `EXE_SRAV:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_SRA_OP, `EXE_RES_SHIFT, 1'b1, 1'b1, 1'b1};//ʹ��rs[16:20]Ϊ�ƶ�λ���������ƶ�
						    `EXE_SYNC:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_NOP_OP, `EXE_RES_NOP  , 1'b0, 1'b1, 1'b1};//�ղ�������֤���أ��洢����˳��ִ�У�
					        `EXE_MFHI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_MFHI_OP, `EXE_RES_MOVE, 1'b0, 1'b0, 1'b1};//��hi�Ĵ�����ȡ��rd
						    `EXE_MFLO:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b1, `EXE_MFLO_OP, `EXE_RES_MOVE, 1'b0, 1'b0, 1'b1};//��lo�Ĵ�����ȡ��rd
					        `EXE_MTHI:{reg_write_en_o, alu_op_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MTHI_OP, 1'b1, 1'b0, 1'b1};//��rs����HI
					        `EXE_MTLO:{reg_write_en_o, alu_op_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {1'b0, `EXE_MTLO_OP, 1'b1, 1'b0, 1'b1};//��rs����LO
					        `EXE_MOVN:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {operand_2_o ? 1:0, `EXE_MOVN_OP, `EXE_RES_MOVE, 1'b1, 1'b1, 1'b1};//reg2��=0ʱ��������λ
					        `EXE_MOVZ:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, inst_valid} <= {operand_2_o ? 0:1, `EXE_MOVZ_OP, `EXE_RES_MOVE, 1'b1, 1'b1, 1'b1};//reg==0ʱ��������λ
                            default:begin end
                        endcase 
                    end
                    default:begin end
			    endcase	
            end								  
		    `EXE_ORI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_OR_OP, `EXE_RES_LOGIC, 1'b1, 1'b0, {16'h0, inst_data[15:0]}, inst_data[20:16], 1'b1};//��������
	  	    `EXE_ANDI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_AND_OP, `EXE_RES_LOGIC, 1'b1, 1'b0, {16'h0, inst_data[15:0]}, inst_data[20:16], 1'b1};//��������
	  	    `EXE_XORI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_XOR_OP, `EXE_RES_LOGIC, 1'b1, 1'b0, {16'h0, inst_data[15:0]}, inst_data[20:16], 1'b1};//���������		
		    `EXE_LUI:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_OR_OP, `EXE_RES_LOGIC, 1'b1, 1'b0, { inst_data[15:0], 16'h0}, inst_data[20:16], 1'b1};//���������ŵ�rd�ĸ�16λ
		    `EXE_PREF:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm, reg_write_addr_o, inst_valid} <= {1'b1, `EXE_NOP_OP, `EXE_RES_NOP, 1'b0, 1'b0, { inst_data[15:0], 16'h0}, inst_data[20:16], 1'b1};//�ղ�����openmipsû��ʵ�ֻ��棩						  	
            default:begin end
        endcase	

	    //��һ����ͨ��ָ��6-10λ��saֵ������λ������ 
	    if(inst_data[31:21] == 11'b00000000000) 
        begin
		    case (op3)
	            `EXE_SLL:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm[4:0], reg_write_addr_o, inst_valid} <= {1'b1, `EXE_SLL_OP, `EXE_RES_SHIFT, 1'b0, 1'b1, inst_data[10:6], inst_data[15:11], 1'b1};//���ƣ���0��䣬�ƶ�saλ��10-6��
	            `EXE_SRL:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm[4:0], reg_write_addr_o, inst_valid} <= {1'b1, `EXE_SRL_OP, `EXE_RES_SHIFT, 1'b0, 1'b1, inst_data[10:6], inst_data[15:11], 1'b1};//���ƣ���0��䣬�ƶ�saλ��10-6��		   
	            `EXE_SRA:{reg_write_en_o, alu_op_o, alu_sel_o, reg_read_en_1_o, reg_read_en_2_o, imm[4:0], reg_write_addr_o, inst_valid} <= {1'b1, `EXE_SRA_OP, `EXE_RES_SHIFT, 1'b0, 1'b1, inst_data[10:6], inst_data[15:11], 1'b1};//�������ƣ��ճ�����λ����rt��31��������䣬�ƶ�saλ��10-6��
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