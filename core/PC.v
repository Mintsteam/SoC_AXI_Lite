`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/rom.vh"

module PC(

    input wire clk,
    input wire rst,
    input wire[5:0] stall,
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
        ce <= ( rst ? `CHIP_DISABLE : `CHIP_ENABLE );
    end

    always @ (posedge clk)
    begin
        if(ce == `CHIP_DISABLE)
        begin
            pc <= 32'h00000000;
        end else if(stall[0] == `NOT_STOP) begin
            pc <= pc + 4'h4;
        end else begin
            pc <= `ZEROWORD;
        end
    end
    

endmodule