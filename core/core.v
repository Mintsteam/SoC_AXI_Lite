`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"
`include "../define/rom.vh"

module core(

    input wire clk,
    input wire rst,
    input wire[5:0] interrupt_i,

    input wire[`REG_DATA_BUS] rom_data_i,
    output wire[`REG_DATA_BUS] rom_addr_o,
    output wire rom_ce_o,

    input wire[`REG_DATA_BUS] ram_read_data_i,
    output wire[`REG_DATA_BUS] ram_addr_o,
    output wire[`REG_DATA_BUS] ram_write_data_o,
    output wire ram_write_en_o,
    output wire[3:0] ram_sel_o,
    output wire ram_ce_o,
    output wire timer_interrupt_o

);

    //connect IF_ID to ID
    wire[`INST_ADDR_BUS] pc;
    wire[`INST_ADDR_BUS] id_pc_o;
    wire[`INST_DATA_BUS] id_inst_o;

    //connect ID to PC
    wire[`REG_DATA_BUS] branch_target_addr_o;
    wire branch_flag_o;

    //connect ID to ID_EX
    wire[`ALU_OP_BUS] id_alu_op_o;
    wire[`ALU_SEL_BUS] id_alu_sel_o;
    wire[`REG_DATA_BUS] id_operand_1_o;
    wire[`REG_DATA_BUS] id_operand_2_o;
    wire id_reg_write_en_o;
    wire[`REG_ADDR_BUS] id_reg_write_addr_o;
    wire[`REG_DATA_BUS] link_addr_o;
    wire[`REG_DATA_BUS] inst_data_o;
    wire[31:0] exception_type_o;
    wire[`REG_DATA_BUS] current_inst_addr_o;

    //connect ID_EX to EX
    wire[`ALU_OP_BUS] ex_alu_op_i;
    wire[`ALU_SEL_BUS] ex_alu_sel_i;
    wire[`REG_DATA_BUS] ex_operand_1_i;
    wire[`REG_DATA_BUS] ex_operand_2_i;
    wire ex_reg_write_en_i;
    wire[`REG_ADDR_BUS] ex_reg_write_addr_i;
    wire ex_is_in_delayslot;
    wire[`REG_DATA_BUS] ex_link_addr;
    wire next_inst_in_delayslot_o;
    wire[`REG_DATA_BUS] ex_inst_data;
    wire [31:0] ex_exception_type;
    wire[`REG_DATA_BUS] ex_current_inst_addr;

    //connect ID_EX to ID
    wire is_in_delayslot_o;

    //connect EX to EX_MEM
    wire ex_reg_write_en_o;
    wire[`REG_ADDR_BUS] ex_reg_write_addr_o;
    wire[`REG_DATA_BUS] ex_reg_write_data_o;
    wire ex_hilo_write_en_o;
    wire[`REG_DATA_BUS] ex_hi_write_data_o;
    wire[`REG_DATA_BUS] ex_lo_write_data_o;
    wire[1:0] ex_count_o;
    wire[`DOUBLE_REG_DATA_BUS] ex_hilo_temp_o;
    wire[`ALU_OP_BUS] alu_op_o;
    wire[`REG_DATA_BUS] mem_addr_o;
    wire[`REG_DATA_BUS] operand_2_o;
    wire[4:0] cp0_reg_read_addr_o;
    wire[`REG_DATA_BUS] cp0_reg_write_data_o1;
    wire[4:0] cp0_reg_write_addr_o1;
    wire cp0_reg_write_en_o1;
    wire[31:0] exception_type_o1;
    wire is_in_delayslot_o1;
    wire[`REG_DATA_BUS] current_inst_addr_o1;

    //connect EX to DIV
    wire[`REG_DATA_BUS] div_operand_1_o;
    wire[`REG_DATA_BUS] div_operand_2_o;
    wire div_start_o;
    wire signed_div_o;

    //connect EX_MEM to MEM
    wire mem_reg_write_en_i;
    wire[`REG_ADDR_BUS] mem_reg_write_addr_i;
    wire[`REG_DATA_BUS] mem_reg_write_data_i;
    wire mem_hilo_write_en_i;
    wire[`REG_DATA_BUS] mem_hi_write_data_i;
    wire[`REG_DATA_BUS] mem_lo_write_data_i;
    wire[`ALU_OP_BUS] mem_alu_op;
    wire[`REG_DATA_BUS] mem_mem_addr;
    wire[`REG_DATA_BUS] mem_operand_2;
    wire[`REG_DATA_BUS] mem_cp0_reg_write_data;
    wire[4:0] mem_cp0_reg_write_addr;
    wire mem_cp0_reg_write_en;
    wire[31:0] mem_exception_type;
    wire mem_is_in_delayslot;
    wire[`REG_DATA_BUS] mem_current_inst_addr;

    //connect MEM to MEM_WB
    wire mem_reg_write_en_o;
    wire[`REG_ADDR_BUS] mem_reg_write_addr_o;
    wire[`REG_DATA_BUS] mem_reg_write_data_o;
    wire mem_hilo_write_en_o;
    wire[`REG_DATA_BUS] mem_hi_write_data_o;
    wire[`REG_DATA_BUS] mem_lo_write_data_o;
    wire LLbit_write_en_o;
    wire LLbit_data_o;
    wire[`REG_DATA_BUS] cp0_reg_write_data_o;
    wire[4:0] cp0_reg_write_addr_o;
    wire cp0_reg_write_en_o;   

    //connect MEM to CTRL
    wire[`REG_DATA_BUS] cp0_epc_o;

    //connect MEM_WB to WB
    wire wb_reg_write_en_i;
    wire[`REG_ADDR_BUS] wb_reg_write_addr_i;
    wire[`REG_DATA_BUS] wb_reg_write_data_i;
    wire wb_hilo_write_en_i;
    wire[`REG_DATA_BUS] wb_hi_write_data_i;
    wire[`REG_DATA_BUS] wb_lo_write_data_i;

    //connect MEM_WB to LLbit
    wire wb_LLbit_write_en;
    wire wb_LLbit_data;

    //connect MEM_WB to CP0
    wire[`REG_DATA_BUS] wb_cp0_reg_write_data;
    wire[4:0] wb_cp0_reg_write_addr;
    wire wb_cp0_reg_write_en;
    wire[31:0] exception_type_o2;
    wire[`REG_DATA_BUS] current_inst_addr_o2;
    wire is_in_delayslot_o2; 

    //connect ID to REGFIE
    wire reg_read_en_1;
    wire reg_read_en_2;
    wire[`REG_DATA_BUS] reg_read_data_1;
    wire[`REG_DATA_BUS] reg_read_data_2;
    wire[`REG_ADDR_BUS] reg_read_addr_1;
    wire[`REG_ADDR_BUS] reg_read_addr_2;

    //connect HILO to EX
    wire[`REG_DATA_BUS] hi_read_data_o;
    wire[`REG_DATA_BUS] lo_read_data_o;

    //connect CTRL to pipeline regs
    wire[5:0] stall;

    //connect CTRL to ID,EX
    wire id_stall_req;
    wire ex_stall_req;

    //connect CTRL to PC,ID_EX,EX_MEM,MEM_WB,LLbit
    wire flush;
    wire[`INST_ADDR_BUS] new_pc;

    //connect EX_MEM to EX
    wire[1:0] ex_mem_count_o;
    wire[`DOUBLE_REG_DATA_BUS] ex_mem_hilo_o;

    //connect DIV to EX
    wire[`DOUBLE_REG_DATA_BUS] div_out;
    wire div_ready_o; 

    //connect LLbit to MEM
    wire LLbit_o;

    //connect CP0 to EX
    wire[`REG_DATA_BUS] read_data_o;

    //connect CP0 to MEM
    wire[`REG_DATA_BUS] count_o;
    wire[`REG_DATA_BUS] compare_o;
    wire[`REG_DATA_BUS] status_o;
    wire[`REG_DATA_BUS] cause_o;
    wire[`REG_DATA_BUS] epc_o;
    wire[`REG_DATA_BUS] config_o;
    wire[`REG_DATA_BUS] prid_o;

    PC PC0(

        .clk(clk),
        .rst(rst),

        //INPUT FROM PC
        .branch_flag_i(branch_flag_o),
        .branch_target_addr_i(branch_target_addr_o),

        //INPUT FROM CTRL
        .stall(stall),
        .flush(flush),
        .new_pc(new_pc),
        
        //OUTPUT TO IF_ID
        .pc(pc),
        .ce(rom_ce_o)

    );

    assign rom_addr_o = pc;

    IF_ID IF_ID0(

        .clk(clk),
        .rst(rst),

        //INPUT FROM PC
        .if_pc(pc),
        .if_inst(rom_data_i),

        //INPUT FROM CTRL
        .stall(stall),
        .flush(flush),

        //OUTPUT TO ID
        .id_pc(id_pc_o),
        .id_inst(id_inst_o)

    );

    ID ID0(

        //INPUT FROM PC
        .branch_target_addr_o(branch_target_addr_o),
        .branch_flag_o(branch_flag_o),

        //INPUT FROM IF_ID
        .rst(rst),
        .inst_addr(id_pc_o),        
        .inst_data(id_inst_o),

        //OUTPUT TO REGFILE 
        .reg_read_addr_1_o(reg_read_addr_1),
        .reg_read_en_1_o(reg_read_en_1),
        .reg_read_addr_2_o(reg_read_addr_2),
        .reg_read_en_2_o(reg_read_en_2),

        //INPUT FROM REGFILE
        .reg_data_1_i(reg_read_data_1),
        .reg_data_2_i(reg_read_data_2),

        //INPUT FROM ID_EX
        .is_in_delayslot_i(is_in_delayslot_o),

        //INPUT FROM EX (forwarding)
        .ex_reg_write_en_i(ex_reg_write_en_o),
        .ex_reg_write_data_i(ex_reg_write_data_o),
        .ex_reg_write_addr_i(ex_reg_write_addr_o),
        .ex_alu_op_i(ex_alu_op_i),

        //INPUT FROM MEM (forwarding)
        .mem_reg_write_en_i(mem_reg_write_en_o),
        .mem_reg_write_data_i(mem_reg_write_data_o),
        .mem_reg_write_addr_i(mem_reg_write_addr_o),

        //OUTPUT TO ID_EX 
        .alu_op_o(id_alu_op_o),
        .alu_sel_o(id_alu_sel_o),
        .operand_1_o(id_operand_1_o),
        .operand_2_o(id_operand_2_o),
        .reg_write_addr_o(id_reg_write_addr_o),
        .reg_write_en_o(id_reg_write_en_o),
        .is_in_delayslot_o(is_in_delayslot_o),
        .link_addr_o(link_addr_o),
        .next_inst_in_delayslot_o(next_inst_in_delayslot_o),
        .inst_data_o(inst_data_o),
        .exception_type_o(exception_type_o),
        .current_inst_addr_o(current_inst_addr_o),

        //OUTPUT TO CTRL
        .stall_req(id_stall_req)

    );

    REGFILE REGFILE0(

        .clk(clk),
        .rst(rst),

        //INPUT FROM MEM_WB
        .write_en_i(wb_reg_write_en_i),
        .write_data_i(wb_reg_write_data_i),
        .write_addr_i(wb_reg_write_addr_i),

        //INPUT FROM ID
        .read_en_1_i(reg_read_en_1),
        .read_addr_1_i(reg_read_addr_1),
        .read_en_2_i(reg_read_en_2),
        .read_addr_2_i(reg_read_addr_2),

        //OUTPUT TO ID
        .read_data_1_o(reg_read_data_1),
        .read_data_2_o(reg_read_data_2)

    );

    ID_EX ID_EX0(

        .clk(clk),
        .rst(rst),

        //INPUT FROM ID
        .id_alu_op(id_alu_op_o),
        .id_alu_sel(id_alu_sel_o),
        .id_reg_data_1(id_operand_1_o),
        .id_reg_data_2(id_operand_2_o),
        .id_reg_write_addr(id_reg_write_addr_o),
        .id_reg_write_en(id_reg_write_en_o),
        .id_link_addr(link_addr_o),
        .id_is_in_delayslot(is_in_delayslot_o),
        .next_inst_in_delayslot_i(next_inst_in_delayslot_o),
        .id_inst_data(inst_data_o),
        .id_exception_type(exception_type_o),
        .id_current_inst_addr(current_inst_addr_o),

        //INPUT FROM CTRL
        .stall(stall),
        .flush(flush),

        //OUTPUT TO EX
        .ex_alu_op(ex_alu_op_i),
        .ex_alu_sel(ex_alu_sel_i),
        .ex_reg_data_1(ex_operand_1_i),
        .ex_reg_data_2(ex_operand_2_i),
        .ex_reg_write_addr(ex_reg_write_addr_i),
        .ex_reg_write_en(ex_reg_write_en_i),
        .ex_link_addr(ex_link_addr),
        .ex_is_in_delayslot(ex_is_in_delayslot),
        .is_in_delayslot_o(is_in_delayslot_o),
        .ex_inst_data(ex_inst_data),
        .ex_exception_type(ex_exception_type),
        .ex_current_inst_addr(ex_current_inst_addr)

    );

    EX EX0(

        .rst(rst),

        //INPUT FROM ID_EX
        .alu_op_i(ex_alu_op_i),
        .alu_sel_i(ex_alu_sel_i),
        .operand_1_i(ex_operand_1_i),
        .operand_2_i(ex_operand_2_i),
        .reg_write_addr_i(ex_reg_write_addr_i),
        .reg_write_en_i(ex_reg_write_en_i),
        .link_addr_i(ex_link_addr),
        .is_in_delayslot_i(ex_is_in_delayslot),
        .inst_data_i(ex_inst_data),
        .exception_type_i(ex_exception_type),
        .current_inst_addr_i(ex_current_inst_addr),

        //INPUT FROM HILO
        .hi_read_data_i(hi_read_data_o),
        .lo_read_data_i(lo_read_data_o),

        //INPUT FROM MEM (forwarding)
        .mem_hi_write_data_i(mem_hi_write_data_o),
        .mem_lo_write_data_i(mem_lo_write_data_o),
        .mem_hilo_write_en_i(mem_hilo_write_en_o),
        .mem_cp0_reg_write_data(cp0_reg_write_data_o),
        .mem_cp0_reg_write_addr(cp0_reg_write_addr_o),
        .mem_cp0_reg_write_en(cp0_reg_write_en_o),

        //INPUT FROM MEM_WB (forwarding)
        .wb_hi_write_data_i(wb_hi_write_data_i),
        .wb_lo_write_data_i(wb_lo_write_data_i),
        .wb_hilo_write_en_i(wb_hilo_write_en_i),
        .wb_cp0_reg_write_data(wb_cp0_reg_write_data),
        .wb_cp0_reg_write_addr(wb_cp0_reg_write_addr),
        .wb_cp0_reg_write_en(wb_cp0_reg_write_en),

        //INPUT FROM EX_MEM
        .count_i(ex_mem_count_o),
        .hilo_temp_i(ex_mem_hilo_o),

        //INPUT FROM DIV
        .div_result_i(div_out),
        .div_ready_i(div_ready_o),

        //INPUT FROM CP0
        .cp0_reg_read_data_i(read_data_o),

        //OUTPUT TO EX_MEM,ID(forwarding)
        .reg_write_data_o(ex_reg_write_data_o),
        .reg_write_addr_o(ex_reg_write_addr_o),
        .reg_write_en_o(ex_reg_write_en_o),

        //OUTPUT TO EX_MEM
        .hi_write_data_o(ex_hi_write_data_o),
        .lo_write_data_o(ex_lo_write_data_o),
        .hilo_write_en_o(ex_hilo_write_en_o),
        .count_o(ex_count_o),
        .hilo_temp_o(ex_hilo_temp_o),
        .alu_op_o(alu_op_o),
        .mem_addr_o(mem_addr_o),
        .operand_2_o(operand_2_o),
        .cp0_reg_read_addr_o(cp0_reg_read_addr_o),
        .cp0_reg_write_data_o(cp0_reg_write_data_o1),
        .cp0_reg_write_addr_o(cp0_reg_write_addr_o1),
        .cp0_reg_write_en_o(cp0_reg_write_en_o1),
        .exception_type_o(exception_type_o1),
        .current_inst_addr_o(current_inst_addr_o1),
        .is_in_delayslot_o(is_in_delayslot_o1),

        //OUTPUT TO CTRL
        .stall_req(ex_stall_req),

        //OUTPUT TO DIV
        .div_operand_1_o(div_operand_1_o),
        .div_operand_2_o(div_operand_2_o),
        .div_start_o(div_start_o),
        .signed_div_o(signed_div_o)

    );

    EX_MEM EX_MEM0(

        .clk(clk),
        .rst(rst),

        //INPUT FROM EX
        .ex_reg_write_data(ex_reg_write_data_o),
        .ex_reg_write_addr(ex_reg_write_addr_o),
        .ex_reg_write_en(ex_reg_write_en_o),
        .ex_hi_write_data(ex_hi_write_data_o),
        .ex_lo_write_data(ex_lo_write_data_o),
        .ex_hilo_write_en(ex_hilo_write_en_o),
        .count_i(ex_count_o),
        .hilo_i(ex_hilo_temp_o),
        .ex_alu_op(alu_op_o),
        .ex_mem_addr(mem_addr_o),
        .ex_operand_2(operand_2_o),
        .ex_cp0_reg_write_data(cp0_reg_write_data_o1),
        .ex_cp0_reg_write_addr(cp0_reg_write_addr_o1),
        .ex_cp0_reg_write_en(cp0_reg_write_en_o1),
        .ex_exception_type(exception_type_o1),
        .ex_current_inst_addr(current_inst_addr_o1),
        .ex_is_in_delayslot(is_in_delayslot_o1),

        //INPUT FROM CTRL
        .stall(stall),
        .flush(flush),

        //OUTPUT TO MEM
        .mem_reg_write_data(mem_reg_write_data_i),
        .mem_reg_write_addr(mem_reg_write_addr_i),
        .mem_reg_write_en(mem_reg_write_en_i),
        .mem_hi_write_data(mem_hi_write_data_i),
        .mem_lo_write_data(mem_lo_write_data_i),
        .mem_hilo_write_en(mem_hilo_write_en_i),
        .mem_alu_op(mem_alu_op),
        .mem_mem_addr(mem_mem_addr),
        .mem_operand_2(mem_operand_2),
        .mem_cp0_reg_write_data(mem_cp0_reg_write_data),
        .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr),
        .mem_cp0_reg_write_en(mem_cp0_reg_write_en),
        .mem_exception_type(mem_exception_type),
        .mem_current_inst_addr(mem_current_inst_addr),
        .mem_is_in_delayslot(mem_is_in_delayslot),

        //OUTPUT TO EX
        .count_o(ex_mem_count_o),
        .hilo_o(ex_mem_hilo_o)

    );

    MEM MEM0(

        .rst(rst),

        //INPUT FROM EX_MEM
        .reg_write_data_i(mem_reg_write_data_i),
        .reg_write_addr_i(mem_reg_write_addr_i),
        .reg_write_en_i(mem_reg_write_en_i),
        .hi_write_data_i(mem_hi_write_data_i),
        .lo_write_data_i(mem_lo_write_data_i),
        .hilo_write_en_i(mem_hilo_write_en_i),
        .alu_op_i(mem_alu_op),
        .mem_addr_i(mem_mem_addr),
        .operand_2_i(mem_operand_2),
        .cp0_reg_write_data_i(mem_cp0_reg_write_data),
        .cp0_reg_write_addr_i(mem_cp0_reg_write_addr),
        .cp0_reg_write_en_i(mem_cp0_reg_write_en),
        .exception_type_i(mem_exception_type),
        .current_inst_addr_i(mem_current_inst_addr),
        .is_in_delayslot_i(mem_is_in_delayslot),

        //INPUT FROM MEM_WB
        .wb_cp0_reg_write_en(wb_cp0_reg_write_en),
        .wb_cp0_reg_write_addr(wb_cp0_reg_write_addr),
        .wb_cp0_reg_write_data(wb_cp0_reg_write_data),

        //INPUT FROM RAM
        .mem_read_data_i(ram_read_data_i),

        //INPUT FROM LLbit
        .LLbit_i(LLbit_o),
        .wb_LLbit_write_en_i(wb_LLbit_write_en),
        .wb_LLbit_data_i(wb_LLbit_data),

        //INPUT FROM CP0
        .cp0_status_i(status_o),
        .cp0_cause_i(cause_o),
        .cp0_epc_i(epc_o),

        //OUTPUT TO MEM_WB
        .reg_write_data_o(mem_reg_write_data_o),
        .reg_write_addr_o(mem_reg_write_addr_o),
        .reg_write_en_o(mem_reg_write_en_o),
        .LLbit_write_en_o(LLbit_write_en_o),
        .LLbit_data_o(LLbit_data_o),
        .cp0_reg_write_data_o(cp0_reg_write_data_o),
        .cp0_reg_write_addr_o(cp0_reg_write_addr_o),
        .cp0_reg_write_en_o(cp0_reg_write_en_o),

        //OUTPUT TO MEM_WB,EX(forwarding)
        .hi_write_data_o(mem_hi_write_data_o),
        .lo_write_data_o(mem_lo_write_data_o),
        .hilo_write_en_o(mem_hilo_write_en_o),

        //OUTPUT TO RAM
        .mem_addr_o(ram_addr_o),
        .mem_write_en_o(ram_write_en_o),
        .mem_sel_o(ram_sel_o),
        .mem_write_data_o(ram_write_data_o),
        .mem_ce_o(ram_ce_o),

        //OUTPUT TO CP0
        .exception_type_o(exception_type_o2),
        .current_inst_addr_o(current_inst_addr_o2),
        .is_in_delayslot_o(is_in_delayslot_o2),

        //OUTPUT TO CTRL
        .cp0_epc_o(cp0_epc_o)

    );

    MEM_WB MEM_WB0(

        .clk(clk),
        .rst(rst),

        //INPUT FROM MEM
        .mem_reg_write_data(mem_reg_write_data_o),
        .mem_reg_write_addr(mem_reg_write_addr_o),
        .mem_reg_write_en(mem_reg_write_en_o),
        .mem_hi_write_data(mem_hi_write_data_o),
        .mem_lo_write_data(mem_lo_write_data_o),
        .mem_hilo_write_en(mem_hilo_write_en_o),
        .mem_LLbit_write_en(LLbit_write_en_o),
        .mem_LLbit_data(LLbit_data_o),
        .mem_cp0_reg_write_data(cp0_reg_write_data_o),
        .mem_cp0_reg_write_addr(cp0_reg_write_addr_o),
        .mem_cp0_reg_write_en(cp0_reg_write_en_o),

        //INPUT FROM CTRL
        .stall(stall),
        .flush(flush),

        //OUTPUT TO WB
        .wb_reg_write_data(wb_reg_write_data_i),
        .wb_reg_write_addr(wb_reg_write_addr_i),
        .wb_reg_write_en(wb_reg_write_en_i),

        //OUTPUT TO LLbit
        .wb_LLbit_write_en(wb_LLbit_write_en),
        .wb_LLbit_data(wb_LLbit_data),

        //OUTPUT TO WB,EX(forwarding)
        .wb_hi_write_data(wb_hi_write_data_i),
        .wb_lo_write_data(wb_lo_write_data_i),
        .wb_hilo_write_en(wb_hilo_write_en_i),
        .wb_cp0_reg_write_data(wb_cp0_reg_write_data),
        .wb_cp0_reg_write_en(wb_cp0_reg_write_en),
        .wb_cp0_reg_write_addr(wb_cp0_reg_write_addr)

    );

    HILO HILO0(

        .clk(clk),
        .rst(rst),

        //INPUT FROM MEM_WB
        .hi_write_data_i(wb_hi_write_data_i),
        .lo_write_data_i(wb_lo_write_data_i),
        .hilo_write_en(wb_hilo_write_en_i),

        //OUTPUT TO EX
        .hi_read_data_o(hi_read_data_o),
        .lo_read_data_o(lo_read_data_o)

    );

    CTRL CTRL0(

        .rst(rst),

        //INPUT FROM ID
        .id_stall_req(id_stall_req),

        //INPUT FROM EX
        .ex_stall_req(ex_stall_req),

        //INPUT FROM MEM
        .exception_type_i(exception_type_o2),

        //INPUT FROM CTRL
        .cp0_epc_i(cp0_epc_o),

        //OUTPUT
        .stall(stall),
        .flush(flush),

        //OUTPUT TO PC
        .new_pc(new_pc)

    );

    DIV DIV0(

        .clk(clk),
        .rst(rst),

        //INPUT FROM EX
        .operand_1_i(div_operand_1_o),
        .operand_2_i(div_operand_2_o),
        .start_div_i(div_start_o),
        .signed_div_i(signed_div_o),
        .discard_div(flush),

        //OUTPUT TO EX
        .div_out(div_out),
        .div_ready_o(div_ready_o)

    );

    LLbit LLbit0(

        //INPUT
        .clk(clk),
        .rst(rst),
        .flush(flush),

        //INPUT FROM MEM_WB
        .LLbit_write_en(wb_LLbit_write_en),
        .LLbit_i(wb_LLbit_data),

        //OUTPUT TO MEM
        .LLbit_o(LLbit_o)

    );

    CP0 CP00(

        //INPUT
        .clk(clk),
        .rst(rst),
        .interrupt_i(interrupt_i),

        //INPUT FROM MEM
        .exception_type_i(exception_type_o2),
        .current_inst_addr_i(current_inst_addr_o2),
        .is_in_delayslot_i(is_in_delayslot_o2),
        
        //INPUT FROM MEM_WB
        .write_data_i(wb_cp0_reg_write_data),
        .write_addr_i(wb_cp0_reg_write_addr),
        .write_en_i(wb_cp0_reg_write_en),
        .read_addr_i(cp0_reg_read_addr_o),

        //OUTPUT TO EX
        .read_data_o(read_data_o),
        .count_o(count_o),
        .compare_o(compare_o),
        .status_o(status_o),
        .cause_o(cause_o),
        .epc_o(epc_o),
        .config_o(config_o),
        .prid_o(prid_o),
        
        .timer_interrupt_o(timer_interrupt_o)

    );

endmodule