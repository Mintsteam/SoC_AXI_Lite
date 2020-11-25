`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/exception.vh"
`include "../define/regfile.vh"

module PC(

    input wire clk,
    input wire rst,

    input wire[5:0] stall,

    input wire branch_flag_i,
    input wire[`REG_DATA_BUS] branch_target_addr_i,

    input wire flush,
    input wire[`REG_DATA_BUS] new_pc,

    output reg[`INST_ADDR_BUS] pc,  

    output wire[`INST_ADDR_BUS] rom_addr,
    output wire rom_en  
    
);

    assign rom_en = rst;    //重置结束立即使能rom

    assign rom_addr = pc;    //指令所在地址

    always @(posedge clk) 
    begin
        if(rst == `RST_ENABLE)
        begin
            pc <= `INIT_PC;
        end else if(flush == 1'b1) begin
            pc <= new_pc;
        end else if(stall[0] == `NOT_STOP) begin
            if(branch_flag_i == `BRANCH)
            begin
                pc <= branch_target_addr_i;
            end else begin
                pc <= pc + 4'h4;
            end
        end
    end

endmodule