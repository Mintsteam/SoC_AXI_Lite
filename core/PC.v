`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"
`include "../define/rom.vh"

module PC(

    input wire clk,
    input wire rst,

    input wire[5:0] stall,

    input wire branch_flag_i,
    input wire[`REG_DATA_BUS] branch_target_addr_i,

    output reg[`INST_ADDR_BUS] pc,  
    output reg ce  
    
);

    always @ (posedge clk)
    begin
        if(rst == `RST_ENABLE)
        begin
            ce <= `CHIP_DISABLE;
        end else begin
            ce <= `CHIP_ENABLE;
        end
    end 

    always @ (posedge clk)
    begin
        if(ce == `CHIP_DISABLE)
        begin
            pc <= 32'h00000000;
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