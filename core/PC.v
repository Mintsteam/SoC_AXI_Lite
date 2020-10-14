`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/rom.vh"

module PC(

    input wire clk,
    input wire rst,
    output reg[`INST_ADDR_BUS] pc,  
    output reg ce  
    
);

    always @ (posedge clk)
    begin
        ce <= ( rst ? `CHIP_DISABLE : `CHIP_ENABLE );
    end

    always @ (posedge clk)
    begin
        pc <= ( ce == `CHIP_DISABLE ? `ZEROWORD : pc + 4'h4 );
    end

endmodule