`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"
`include "../define/opcode.vh"
`include "../define/cp0.vh"

module MEM(

    input wire rst,

    input wire[`REG_DATA_BUS] reg_write_data_i,
    input wire[`REG_ADDR_BUS] reg_write_addr_i,
    input wire reg_write_en_i,

    input wire[`REG_DATA_BUS] hi_write_data_i,
    input wire[`REG_DATA_BUS] lo_write_data_i,
    input wire hilo_write_en_i,

	input wire[`ALU_OP_BUS] alu_op_i,
	input wire[`REG_DATA_BUS] mem_addr_i,
	input wire[`REG_DATA_BUS] operand_2_i,

	input wire[`REG_DATA_BUS] mem_read_data_i,

	input wire LLbit_i,
	input wire wb_LLbit_write_en_i,
	input wire wb_LLbit_data_i,

	input wire cp0_reg_write_en_i,
	input wire[4:0] cp0_reg_write_addr_i,
	input wire[`REG_DATA_BUS] cp0_reg_write_data_i,

	input wire[31:0] exception_type_i,
	input wire is_in_delayslot_i,
	input wire[`REG_DATA_BUS] current_inst_addr_i,

	input wire[`REG_DATA_BUS] cp0_status_i,
	input wire[`REG_DATA_BUS] cp0_cause_i,
	input wire[`REG_DATA_BUS] cp0_epc_i,

	input wire wb_cp0_reg_write_en,
	input wire[4:0] wb_cp0_reg_write_addr,
	input wire[`REG_DATA_BUS] wb_cp0_reg_write_data,

    output reg[`REG_DATA_BUS] reg_write_data_o,
    output reg[`REG_ADDR_BUS] reg_write_addr_o,
    output reg reg_write_en_o,

    output reg[`REG_DATA_BUS] hi_write_data_o,
    output reg[`REG_DATA_BUS] lo_write_data_o,
    output reg hilo_write_en_o,

	output reg[`REG_DATA_BUS] mem_addr_o,
	output wire mem_write_en_o,
	output reg[3:0] mem_sel_o,
	output reg[`REG_DATA_BUS] mem_write_data_o,
	output reg mem_ce_o,

	output reg LLbit_write_en_o,
	output reg LLbit_data_o,

	output reg cp0_reg_write_en_o,
	output reg[4:0] cp0_reg_write_addr_o,
	output reg[`REG_DATA_BUS] cp0_reg_write_data_o,

	output reg[31:0] exception_type_o,
	output wire[`REG_DATA_BUS] cp0_epc_o,
	output wire is_in_delayslot_o,

	output wire[`REG_DATA_BUS] current_inst_addr_o

);

	reg LLbit;
	wire[`REG_DATA_BUS] zero32;
	reg mem_we;
	reg[`REG_DATA_BUS] cp0_status;
	reg[`REG_DATA_BUS] cp0_cause;
	reg[`REG_DATA_BUS] cp0_epc;

	assign zero32 = `ZEROWORD;
	
	assign is_in_delayslot_o = is_in_delayslot_i;

	assign current_inst_addr_o = current_inst_addr_i;

	always @ (*)
	begin
		if(rst == `RST_ENABLE)
		begin
			cp0_status <= `ZEROWORD;
		end	else if((wb_cp0_reg_write_en == `WRITE_ENABLE) && (wb_cp0_reg_write_addr == `CP0_REG_STATUS)) begin
			cp0_status <= wb_cp0_reg_write_data;
		end else begin
			cp0_status <= cp0_status_i;
		end
	end

	always @ (*)
	begin
		if(rst == `RST_ENABLE)
		begin
			cp0_epc <= `ZEROWORD;
		end	else if((wb_cp0_reg_write_en == `WRITE_ENABLE) && (wb_cp0_reg_write_addr == `CP0_REG_EPC)) begin
			cp0_epc <= wb_cp0_reg_write_data;
		end else begin
			cp0_epc <= cp0_epc_i;
		end
	end

	assign cp0_epc_o = cp0_epc;

	always @ (*)    //暂存cp0_cause
	begin
		if(rst == `RST_ENABLE)
		begin
			cp0_cause <= `ZEROWORD;
		end	else if((wb_cp0_reg_write_en == `WRITE_ENABLE) && (wb_cp0_reg_write_addr == `CP0_REG_CAUSE)) begin    //从写回阶段前推，解决数据相关
			cp0_cause[9:8] <= wb_cp0_reg_write_data[9:8];
			cp0_cause[22] <= wb_cp0_reg_write_data[22];
			cp0_cause[23] <= wb_cp0_reg_write_data[23];
		end else begin
			cp0_cause <= cp0_cause_i;
		end
	end

	always @ (*) begin    //最终确定异常原因
		if(rst == `RST_ENABLE) 
		begin
			exception_type_o <= `ZEROWORD;
		end else begin
			exception_type_o <= `ZEROWORD;
			if(current_inst_addr_i != `ZEROWORD) 
			begin
				if(((cp0_cause[15:8] & (cp0_status[15:8])) != 8'h00) && (cp0_status[1] == 1'b0) && (cp0_status[0] == 1'b1)) begin //若status和cause关于外部中断的IM[7:0]和IP[7:0]有相同位置均不为0的项,且IE=1,EXL=0
					exception_type_o <= 32'h00000001;       //interrupt
				end else if(exception_type_i[8] == 1'b1) begin
			  		exception_type_o <= 32'h00000008;       //syscall
				end else if(exception_type_i[9] == 1'b1) begin
					exception_type_o <= 32'h0000000a;       //inst_invalid
				end else if(exception_type_i[10] ==1'b1) begin
					exception_type_o <= 32'h0000000d;		//trap
				end else if(exception_type_i[11] == 1'b1) begin  
					exception_type_o <= 32'h0000000c;		//ov
				end else if(exception_type_i[12] == 1'b1) begin  
					exception_type_o <= 32'h0000000e;		//返回指令
				end
			end	
		end
	end

	assign mem_write_en_o = mem_we & (~(|exception_type_o));

	always @ (*) 
	begin
		if(rst == `RST_ENABLE)
		begin
			LLbit <= 1'b0;
		end	else begin
			if(wb_LLbit_write_en_i == 1'b1)
			begin
				LLbit <= wb_LLbit_data_i;
			end else begin
				LLbit <= LLbit_i;
			end
		end
	end

    always @ (*) begin
		if(rst == `RST_ENABLE) 
        begin
			reg_write_addr_o <= `NOP_REG_ADDR;
			reg_write_en_o <= `WRITE_DISABLE;
		    reg_write_data_o <= `ZEROWORD;
		    hi_write_data_o <= `ZEROWORD;
		    lo_write_data_o <= `ZEROWORD;
		    hilo_write_en_o <= `WRITE_DISABLE;	
			mem_addr_o <= `ZEROWORD;
			mem_we <= `WRITE_DISABLE;
			mem_sel_o <= 4'b0000;
			mem_write_data_o <= `ZEROWORD;
			mem_ce_o <= `CHIP_DISABLE;	  
			LLbit_write_en_o <= 1'b0;
			LLbit_data_o <= 1'b0;
			cp0_reg_write_en_o <= `WRITE_DISABLE;
			cp0_reg_write_addr_o <= 5'b00000;
			cp0_reg_write_data_o <= `ZEROWORD;
		end else begin
		    reg_write_addr_o <= reg_write_addr_i;
			reg_write_en_o <= reg_write_en_i;
			reg_write_data_o <= reg_write_data_i;
			hi_write_data_o <= hi_write_data_i;
			lo_write_data_o <= lo_write_data_i;
			hilo_write_en_o <= hilo_write_en_i;	
			mem_addr_o <= `ZEROWORD;
			mem_we <= `WRITE_DISABLE;
			mem_sel_o <= 4'b1111;
			mem_write_data_o <= `ZEROWORD;
			mem_ce_o <= `CHIP_DISABLE;
			LLbit_write_en_o <= 1'b0;
			LLbit_data_o <= 1'b0;
			cp0_reg_write_en_o <= cp0_reg_write_en_i;
			cp0_reg_write_addr_o <= cp0_reg_write_addr_i;
			cp0_reg_write_data_o <= cp0_reg_write_data_i;
			case (alu_op_i)
				`EXE_LB_OP: begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WRITE_DISABLE;
					mem_ce_o <= `CHIP_ENABLE;
					case (mem_addr_i[1:0])
						2'b00: begin
							reg_write_data_o <= {{24{mem_read_data_i[31]}},mem_read_data_i[31:24]};
							mem_sel_o <= 4'b1000;
						end
						2'b01: begin
							reg_write_data_o <= {{24{mem_read_data_i[23]}},mem_read_data_i[23:16]};
							mem_sel_o <= 4'b0100;
						end
						2'b10: begin
							reg_write_data_o <= {{24{mem_read_data_i[15]}},mem_read_data_i[15:8]};
							mem_sel_o <= 4'b0010;
						end
						2'b11: begin
							reg_write_data_o <= {{24{mem_read_data_i[7]}},mem_read_data_i[7:0]};
							mem_sel_o <= 4'b0001;
						end
						default: begin
							reg_write_data_o <= `ZEROWORD;
						end
					endcase
				end
				`EXE_LBU_OP: begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WRITE_DISABLE;
					mem_ce_o <= `CHIP_ENABLE;
					case (mem_addr_i[1:0])
						2'b00: begin
							reg_write_data_o <= {{24{1'b0}},mem_read_data_i[31:24]};
							mem_sel_o <= 4'b1000;
						end
						2'b01: begin
							reg_write_data_o <= {{24{1'b0}},mem_read_data_i[23:16]};
							mem_sel_o <= 4'b0100;
						end
						2'b10: begin
							reg_write_data_o <= {{24{1'b0}},mem_read_data_i[15:8]};
							mem_sel_o <= 4'b0010;
						end
						2'b11: begin
							reg_write_data_o <= {{24{1'b0}},mem_read_data_i[7:0]};
							mem_sel_o <= 4'b0001;
						end
						default: begin
							reg_write_data_o <= `ZEROWORD;
						end
					endcase				
				end
				`EXE_LH_OP: begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WRITE_DISABLE;
					mem_ce_o <= `CHIP_ENABLE;
					case (mem_addr_i[1:0])
						2'b00: begin
							reg_write_data_o <= {{16{mem_read_data_i[31]}},mem_read_data_i[31:16]};
							mem_sel_o <= 4'b1100;
						end
						2'b10: begin
							reg_write_data_o <= {{16{mem_read_data_i[15]}},mem_read_data_i[15:0]};
							mem_sel_o <= 4'b0011;
						end
						default: begin
							reg_write_data_o <= `ZEROWORD;
						end
					endcase					
				end
				`EXE_LHU_OP: begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WRITE_DISABLE;
					mem_ce_o <= `CHIP_ENABLE;
					case (mem_addr_i[1:0])
						2'b00: begin
							reg_write_data_o <= {{16{1'b0}},mem_read_data_i[31:16]};
							mem_sel_o <= 4'b1100;
						end
						2'b10: begin
							reg_write_data_o <= {{16{1'b0}},mem_read_data_i[15:0]};
							mem_sel_o <= 4'b0011;
						end
						default: begin
							reg_write_data_o <= `ZEROWORD;
						end
					endcase				
				end
				`EXE_LW_OP: begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WRITE_DISABLE;
					reg_write_data_o <= mem_read_data_i;
					mem_sel_o <= 4'b1111;
					mem_ce_o <= `CHIP_ENABLE;		
				end
				`EXE_LWL_OP: begin
					mem_addr_o <= {mem_addr_i[31:2], 2'b00};
					mem_we <= `WRITE_DISABLE;
					mem_sel_o <= 4'b1111;
					mem_ce_o <= `CHIP_ENABLE;
					case (mem_addr_i[1:0])
						2'b00: begin
							reg_write_data_o <= mem_read_data_i[31:0];
						end
						2'b01: begin
							reg_write_data_o <= {mem_read_data_i[23:0], operand_2_i[7:0]};
						end
						2'b10: begin
							reg_write_data_o <= {mem_read_data_i[15:0], operand_2_i[15:0]};
						end
						2'b11: begin
							reg_write_data_o <= {mem_read_data_i[7:0], operand_2_i[23:0]};	
						end
						default: begin
							reg_write_data_o <= `ZEROWORD;
						end
					endcase				
				end
				`EXE_LWR_OP: begin
					mem_addr_o <= {mem_addr_i[31:2], 2'b00};
					mem_we <= `WRITE_DISABLE;
					mem_sel_o <= 4'b1111;
					mem_ce_o <= `CHIP_ENABLE;
					case (mem_addr_i[1:0])
						2'b00: begin
							reg_write_data_o <= {operand_2_i[31:8],mem_read_data_i[31:24]};
						end
						2'b01: begin
							reg_write_data_o <= {operand_2_i[31:16],mem_read_data_i[31:16]};
						end
						2'b10: begin
							reg_write_data_o <= {operand_2_i[31:24],mem_read_data_i[31:8]};
						end
						2'b11: begin
							reg_write_data_o <= mem_read_data_i;	
						end
						default: begin
							reg_write_data_o <= `ZEROWORD;
						end
					endcase					
				end
				`EXE_SB_OP: begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WRITE_ENABLE;
					mem_write_data_o <= {operand_2_i[7:0], operand_2_i[7:0], operand_2_i[7:0], operand_2_i[7:0]};
					mem_ce_o <= `CHIP_ENABLE;
					case (mem_addr_i[1:0])
						2'b00: begin
							mem_sel_o <= 4'b1000;
						end
						2'b01: begin
							mem_sel_o <= 4'b0100;
						end
						2'b10:	begin
							mem_sel_o <= 4'b0010;
						end
						2'b11: begin
							mem_sel_o <= 4'b0001;	
						end
						default: begin
							mem_sel_o <= 4'b0000;
						end
					endcase				
				end
				`EXE_SH_OP: begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WRITE_ENABLE;
					mem_write_data_o <= {operand_2_i[15:0],operand_2_i[15:0]};
					mem_ce_o <= `CHIP_ENABLE;
					case (mem_addr_i[1:0])
						2'b00: begin
							mem_sel_o <= 4'b1100;
						end
						2'b10: begin
							mem_sel_o <= 4'b0011;
						end
						default: begin
							mem_sel_o <= 4'b0000;
						end
					endcase						
				end
				`EXE_SW_OP:	begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WRITE_ENABLE;
					mem_write_data_o <= operand_2_i;
					mem_sel_o <= 4'b1111;	
					mem_ce_o <= `CHIP_ENABLE;		
				end
				`EXE_SWL_OP: begin
					mem_addr_o <= {mem_addr_i[31:2], 2'b00};
					mem_we <= `WRITE_ENABLE;
					mem_ce_o <= `CHIP_ENABLE;
					case (mem_addr_i[1:0])
						2'b00: begin						  
							mem_sel_o <= 4'b1111;
							mem_write_data_o <= operand_2_i;
						end
						2'b01: begin
							mem_sel_o <= 4'b0111;
							mem_write_data_o <= {zero32[7:0],operand_2_i[31:8]};
						end
						2'b10: begin
							mem_sel_o <= 4'b0011;
							mem_write_data_o <= {zero32[15:0],operand_2_i[31:16]};
						end
						2'b11: begin
							mem_sel_o <= 4'b0001;	
							mem_write_data_o <= {zero32[23:0],operand_2_i[31:24]};
						end
						default: begin
							mem_sel_o <= 4'b0000;
						end
					endcase							
				end
				`EXE_SWR_OP: begin
					mem_addr_o <= {mem_addr_i[31:2], 2'b00};
					mem_we <= `WRITE_ENABLE;
					mem_ce_o <= `CHIP_ENABLE;
					case (mem_addr_i[1:0])
						2'b00: begin						  
							mem_sel_o <= 4'b1000;
							mem_write_data_o <= {operand_2_i[7:0],zero32[23:0]};
						end
						2'b01: begin
							mem_sel_o <= 4'b1100;
							mem_write_data_o <= {operand_2_i[15:0],zero32[15:0]};
						end
						2'b10: begin
							mem_sel_o <= 4'b1110;
							mem_write_data_o <= {operand_2_i[23:0],zero32[7:0]};
						end
						2'b11: begin
							mem_sel_o <= 4'b1111;	
							mem_write_data_o <= operand_2_i[31:0];
						end
						default: begin
							mem_sel_o <= 4'b0000;
						end
					endcase											
				end 
				`EXE_LL_OP: begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WRITE_DISABLE;
					reg_write_data_o <= mem_read_data_i;
					LLbit_write_en_o <= 1'b1;
					LLbit_data_o <= 1'b1;
					mem_sel_o <= 4'b1111;
					mem_ce_o <= `CHIP_ENABLE;
				end
				`EXE_SC_OP: begin
					if(LLbit == 1'b1)
					begin
						mem_addr_o <= mem_addr_i;
						mem_we <= `WRITE_ENABLE;
						mem_write_data_o <= operand_2_i;
						LLbit_write_en_o <= 1'b1;
						LLbit_data_o <= 1'b0;
						mem_sel_o <= 4'b1111;
						mem_ce_o <= `CHIP_ENABLE;
						reg_write_data_o <= 32'b1;
					end else begin
						reg_write_data_o <= 32'b0;
					end
					
				end
				default: begin
				end
			endcase							
		end       
	end      

endmodule