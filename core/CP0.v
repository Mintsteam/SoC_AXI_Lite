`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"
`include "../define/opcode.vh"
`include "../define/cp0.vh"

module CP0(

    input wire clk,
    input wire rst,

    input wire[4:0] write_addr_i,
    input wire[`REG_DATA_BUS] write_data_i,
    input wire write_en_i,
    input wire[4:0] read_addr_i,
    
    input wire[5:0] interrupt_i,

    input wire[31:0] exception_type_i,
    input wire[`REG_DATA_BUS] current_inst_addr_i,
    input wire is_in_delayslot_i,

    output reg[`REG_DATA_BUS] read_data_o,
    output reg[`REG_DATA_BUS] badvaddr_o,
    output reg[`REG_DATA_BUS] count_o,
    output reg[`REG_DATA_BUS] compare_o,
    output reg[`REG_DATA_BUS] status_o,
    output reg[`REG_DATA_BUS] cause_o,
    output reg[`REG_DATA_BUS] epc_o,
    output reg[`REG_DATA_BUS] config_o,
    output reg[`REG_DATA_BUS] prid_o,
    output reg timer_interrupt_o

);
    always @(posedge clk)
    begin
        if(rst == `RST_ENABLE)
        begin
            count_o <= `ZEROWORD;
        end else begin
            count_o <= count_o + 1;    //ÿ��һ��ʱ�����ڣ�count�Ĵ����Լ�1
        end
    end

    always @(posedge clk) 
    begin
        if(rst == `RST_ENABLE)
        begin
            badvaddr_o <= `ZEROWORD;
            compare_o <= `ZEROWORD;
            status_o <= 32'b00010000000000000000000000000000;
            cause_o <= `ZEROWORD;
            epc_o <= `ZEROWORD;
            config_o <= 32'b00000000000000001000000000000000;
			prid_o <= 32'b00000000010011000000000100000010;
            timer_interrupt_o <= `INTERRUPT_NOT_ASSERT;
        end else begin
            cause_o[15:10] <= interrupt_i;    //Ϊcause�Ĵ������ж��ֶ�IP[7:2]д���ⲿ�ж��ź�
            if(compare_o != `ZEROWORD && count_o == compare_o)    //������ʱ���жϷ���ʱ��
            begin
                timer_interrupt_o <= `INTERRUPT_ASSERT;    //ʱ���жϷ�����ֱ��������д��compare�Ĵ����Ž���
            end
            case (exception_type_i)
				32'h00000001: begin    //�ⲿ�ж�
					if(is_in_delayslot_i == `IN_DELAY_SLOT) 
                    begin
						epc_o <= current_inst_addr_i - 4;    //�����쳣ָ�����ӳٲۣ�����򷵻ص�ַӦΪ��һ��ָ�
						cause_o[31] <= 1'b1;    //�����쳣ָ�����ӳٲۣ���BD�ֶ���1
					end else begin
					    epc_o <= current_inst_addr_i;
					    cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;    //����EXL�ֶ�Ϊ1,��ֹ�ж�
					cause_o[6:2] <= 5'b00000;    //����ExcCode�ֶΣ���ʾ�쳣ԭ��Ϊ�ⲿ�ж�
				end
				32'h00000008: begin    //ϵͳ�����쳣syscall
					if(status_o[1] == 1'b0)    //���������쳣��
                    begin
						if(is_in_delayslot_i == `IN_DELAY_SLOT) 
                        begin
							epc_o <= current_inst_addr_i - 4;
							cause_o[31] <= 1'b1;
						end else begin
					  	    epc_o <= current_inst_addr_i;
					  	    cause_o[31] <= 1'b0;
						end
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01000;			
				end
				32'h0000000a: begin    //��Чָ���쳣
					if(status_o[1] == 1'b0) 
                    begin
						if(is_in_delayslot_i == `IN_DELAY_SLOT) 
                        begin
							epc_o <= current_inst_addr_i - 4;
							cause_o[31] <= 1'b1;
						end else begin
					  	epc_o <= current_inst_addr_i;
					  	cause_o[31] <= 1'b0;
						end
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01010;					
				end
				32'h0000000d: begin    //�����쳣
					if(status_o[1] == 1'b0) 
                    begin
						if(is_in_delayslot_i == `IN_DELAY_SLOT) 
                        begin
							epc_o <= current_inst_addr_i - 4;
							cause_o[31] <= 1'b1;
						end else begin
					  	    epc_o <= current_inst_addr_i;
					  	    cause_o[31] <= 1'b0;
						end
					end
					status_o[1] <= 1'b1;    //����EXL�ֶ�Ϊ1
					cause_o[6:2] <= 5'b01101;					
				end
				32'h0000000c: begin    //����쳣
					if(status_o[1] == 1'b0) 
                    begin
						if(is_in_delayslot_i == `IN_DELAY_SLOT) 
                        begin
							epc_o <= current_inst_addr_i - 4;
							cause_o[31] <= 1'b1;
						end else begin
					  	    epc_o <= current_inst_addr_i;
					  	    cause_o[31] <= 1'b0;
						end
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01100;					
				end				
				32'h0000000e: begin    //�쳣����ָ��eret
					status_o[1] <= 1'b0;    //���EXL�ֶ�����,�����ж�
				end
				default:begin end
			endcase	
        end   
    end
    
    always @(posedge clk) 
    begin
        if(write_en_i == `WRITE_ENABLE)
        begin
            case(write_addr_i)
                `CP0_REG_COUNT:     count_o <= write_data_i;
                `CP0_REG_COMPARE:   {compare_o, timer_interrupt_o} <= {write_data_i, `INTERRUPT_NOT_ASSERT};    //��������д��compare�Ĵ���ʱ������ʱ���ж�
                `CP0_REG_STATUS:    status_o <= write_data_i;
                `CP0_REG_EPC:       epc_o <= write_data_i;
                `CP0_REG_CAUSE:     {cause_o[9:8], cause_o[23], cause_o[22]} <= {write_data_i[9:8], write_data_i[23], write_data_i[22]};    //�ֱ�д��cause�Ĵ�����IP[1:0],IV��WP�ֶΣ��ҽ�����Щ�ֶο�д
                default:begin end
            endcase
        end 
    end

    always @(*)    //��ȡCP0�����Ĵ�����ֵ
    begin
        if(rst == `RST_ENABLE)
        begin
            read_data_o <= `ZEROWORD;
        end else begin
            case(read_addr_i)
                `CP0_REG_BadVAddr:  read_data_o <= badvaddr_o;
                `CP0_REG_COUNT:     read_data_o <= count_o;
                `CP0_REG_COMPARE:   read_data_o <= compare_o;
                `CP0_REG_STATUS:    read_data_o <= status_o;
                `CP0_REG_EPC:       read_data_o <= epc_o;
                `CP0_REG_CAUSE:     read_data_o <= cause_o;
                `CP0_REG_PRId:      read_data_o <= prid_o;
                `CP0_REG_CONFIG:    read_data_o <= config_o;
                default:begin
                    read_data_o <= `ZEROWORD;
                end
            endcase
        end 
    end

endmodule