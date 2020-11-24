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
            count_o <= count_o + 1;    //每过一个时钟周期，count寄存器自加1
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
            cause_o[15:10] <= interrupt_i;    //为cause寄存器的中断字段IP[7:2]写入外部中断信号
            if(compare_o != `ZEROWORD && count_o == compare_o)    //若到达时钟中断发生时间
            begin
                timer_interrupt_o <= `INTERRUPT_ASSERT;    //时钟中断发生，直到有数据写入compare寄存器才结束
            end
            case (exception_type_i)
				32'h00000001: begin    //外部中断
					if(is_in_delayslot_i == `IN_DELAY_SLOT) 
                    begin
						epc_o <= current_inst_addr_i - 4;    //若该异常指令在延迟槽，则程序返回地址应为上一条指令处
						cause_o[31] <= 1'b1;    //若该异常指令在延迟槽，将BD字段置1
					end else begin
					    epc_o <= current_inst_addr_i;
					    cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;    //设置EXL字段为1,禁止中断
					cause_o[6:2] <= 5'b00000;    //设置ExcCode字段，表示异常原因为外部中断
				end
				32'h00000008: begin    //系统调用异常syscall
					if(status_o[1] == 1'b0)    //若不处于异常级
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
				32'h0000000a: begin    //无效指令异常
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
				32'h0000000d: begin    //自陷异常
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
					status_o[1] <= 1'b1;    //设置EXL字段为1
					cause_o[6:2] <= 5'b01101;					
				end
				32'h0000000c: begin    //溢出异常
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
				32'h0000000e: begin    //异常返回指令eret
					status_o[1] <= 1'b0;    //清除EXL字段数据,允许中断
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
                `CP0_REG_COMPARE:   {compare_o, timer_interrupt_o} <= {write_data_i, `INTERRUPT_NOT_ASSERT};    //当有数据写入compare寄存器时，结束时钟中断
                `CP0_REG_STATUS:    status_o <= write_data_i;
                `CP0_REG_EPC:       epc_o <= write_data_i;
                `CP0_REG_CAUSE:     {cause_o[9:8], cause_o[23], cause_o[22]} <= {write_data_i[9:8], write_data_i[23], write_data_i[22]};    //分别写入cause寄存器的IP[1:0],IV，WP字段，且仅有这些字段可写
                default:begin end
            endcase
        end 
    end

    always @(*)    //读取CP0各个寄存器的值
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