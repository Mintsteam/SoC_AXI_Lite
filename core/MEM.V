`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"
`include "../define/opcode.vh"

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
	output reg[`REG_DATA_BUS] cp0_reg_write_data_o

);

	reg LLbit;

	wire[`REG_DATA_BUS] zero32;
	reg mem_we;

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

	assign mem_write_en_o = mem_we;
	assign zero32 = `ZEROWORD;

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