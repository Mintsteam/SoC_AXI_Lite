`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"
`include "../define/rom.vh"

module core(

    input clk,
    input rst,

    input wire[`REG_DATA_BUS] rom_data_i,
    output wire[`REG_DATA_BUS] rom_addr_o,
    output wire rom_ce_o

);

    //connect IF_ID with ID
    wire[`INST_ADDR_BUS] pc;
    wire[`INST_ADDR_BUS] id_pc_o;
    wire[`INST_DATA_BUS] id_inst_o;

    //connect ID with ID_EX
    wire[`ALU_OP_BUS] id_alu_op_o;
    wire[`ALU_SEL_BUS] id_alu_sel_o;
    wire[`REG_DATA_BUS] id_operand_1_o;
    wire[`REG_DATA_BUS] id_operand_2_o;
    wire id_reg_write_en_o;
    wire[`REG_ADDR_BUS] id_reg_write_addr_o;

    //connect ID_EX with EX
    wire[`ALU_OP_BUS] ex_alu_op_i;
    wire[`ALU_SEL_BUS] ex_alu_sel_i;
    wire[`REG_DATA_BUS] ex_operand_1_i;
    wire[`REG_DATA_BUS] ex_operand_2_i;
    wire ex_reg_write_en_i;
    wire[`REG_ADDR_BUS] ex_reg_write_addr_i;

    //connect EX with EX_MEM
    wire ex_reg_write_en_o;
    wire[`REG_ADDR_BUS] ex_reg_write_addr_o;
    wire[`REG_DATA_BUS] ex_reg_write_data_o;
    wire ex_hilo_write_en_o;
    wire[`REG_DATA_BUS] ex_hi_write_data_o;
    wire[`REG_DATA_BUS] ex_lo_write_data_o;

    //connect EX_MEM with MEM
    wire mem_reg_write_en_i;
    wire[`REG_ADDR_BUS] mem_reg_write_addr_i;
    wire[`REG_DATA_BUS] mem_reg_write_data_i;
    wire mem_hilo_write_en_i;
    wire[`REG_DATA_BUS] mem_hi_write_data_i;
    wire[`REG_DATA_BUS] mem_lo_write_data_i;

    //connect MEM with MEM_WB
    wire mem_reg_write_en_o;
    wire[`REG_ADDR_BUS] mem_reg_write_addr_o;
    wire[`REG_DATA_BUS] mem_reg_write_data_o;
    wire mem_hilo_write_en_o;
    wire[`REG_DATA_BUS] mem_hi_write_data_o;
    wire[`REG_DATA_BUS] mem_lo_write_data_o;

    //connect MEM_WB with WB
    wire wb_reg_write_en_i;
    wire[`REG_ADDR_BUS] wb_reg_write_addr_i;
    wire[`REG_DATA_BUS] wb_reg_write_data_i;
    wire wb_hilo_write_en_i;
    wire[`REG_DATA_BUS] wb_hi_write_data_i;
    wire[`REG_DATA_BUS] wb_lo_write_data_i;

    //connect ID with REGFIE
    wire reg_read_en_1;
    wire reg_read_en_2;
    wire[`REG_DATA_BUS] reg_read_data_1;
    wire[`REG_DATA_BUS] reg_read_data_2;
    wire[`REG_ADDR_BUS] reg_read_addr_1;
    wire[`REG_ADDR_BUS] reg_read_addr_2;

    //connect HILO with EX
    wire[`REG_DATA_BUS] hi_read_data_o;
    wire[`REG_DATA_BUS] lo_read_data_o;

    PC PC0(

        .clk(clk),
        .rst(rst),
        
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

        //OUTPUT TO ID
        .id_pc(id_pc_o),
        .id_inst(id_inst_o)

    );

    ID ID0(

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

        //INPUT FROM EX (forwarding)
        .ex_reg_write_en_i(ex_reg_write_en_o),
        .ex_reg_write_data_i(ex_reg_write_data_o),
        .ex_reg_write_addr_i(ex_reg_write_addr_o),

        //INPUT FROM MEM (forwarding)
        .mem_reg_write_en_i(mem_reg_write_en_o),
        .mem_reg_write_data_i(mem_reg_write_data_o),
        .mem_reg_write_addr_i(mem_reg_write_addr_o),

        //OUTPUT TO ID/EX 
        .alu_op_o(id_alu_op_o),
        .alu_sel_o(id_alu_sel_o),
        .operand_1_o(id_operand_1_o),
        .operand_2_o(id_operand_2_o),
        .reg_write_addr_o(id_reg_write_addr_o),
        .reg_write_en_o(id_reg_write_en_o)

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

        //OUTPUT TO EX
        .ex_alu_op(ex_alu_op_i),
        .ex_alu_sel(ex_alu_sel_i),
        .ex_reg_data_1(ex_operand_1_i),
        .ex_reg_data_2(ex_operand_2_i),
        .ex_reg_write_addr(ex_reg_write_addr_i),
        .ex_reg_write_en(ex_reg_write_en_i)

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

        //INPUT FROM HILO
        .hi_read_data_i(hi_read_data_o),
        .lo_read_data_i(lo_read_data_o),

        //INPUT FROM MEM (forwarding)
        .mem_hi_write_data_i(mem_hi_write_data_o),
        .mem_lo_write_data_i(mem_lo_write_data_o),
        .mem_hilo_write_en_i(mem_hilo_write_en_o),

        //INPUT FROM WB (forwarding)
        .wb_hi_write_data_i(wb_hi_write_data_i),
        .wb_lo_write_data_i(wb_lo_write_data_i),
        .wb_hilo_write_en_i(wb_hilo_write_en_i),

        //OUTPUT TO EX_MEM,ID(forwarding)
        .reg_write_data_o(ex_reg_write_data_o),
        .reg_write_addr_o(ex_reg_write_addr_o),
        .reg_write_en_o(ex_reg_write_en_o),

        //OUTPUT TO EX_MEM
        .hi_write_data_o(ex_hi_write_data_o),
        .lo_write_data_o(ex_lo_write_data_o),
        .hilo_write_en_o(ex_hilo_write_en_o)

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

        //OUTPUT TO MEM
        .mem_reg_write_data(mem_reg_write_data_i),
        .mem_reg_write_addr(mem_reg_write_addr_i),
        .mem_reg_write_en(mem_reg_write_en_i),
        .mem_hi_write_data(mem_hi_write_data_i),
        .mem_lo_write_data(mem_lo_write_data_i),
        .mem_hilo_write_en(mem_hilo_write_en_i)

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

        //OUTPUT TO MEM_WB
        .reg_write_data_o(mem_reg_write_data_o),
        .reg_write_addr_o(mem_reg_write_addr_o),
        .reg_write_en_o(mem_reg_write_en_o),

        //OUTPUT TO MEM_WB,EX(forwarding)
        .hi_write_data_o(mem_hi_write_data_o),
        .lo_write_data_o(mem_lo_write_data_o),
        .hilo_write_en_o(mem_hilo_write_en_o)

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

        //OUTPUT TO WB
        .wb_reg_write_data(wb_reg_write_data_i),
        .wb_reg_write_addr(wb_reg_write_addr_i),
        .wb_reg_write_en(wb_reg_write_en_i),

        //OUTPUT TO WB,EX(forwarding)
        .wb_hi_write_data(wb_hi_write_data_i),
        .wb_lo_write_data(wb_lo_write_data_i),
        .wb_hilo_write_en(wb_hilo_write_en_i)

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

endmodule