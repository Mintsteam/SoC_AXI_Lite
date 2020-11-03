`timescale 1ns / 1ps
`include "../define/global.vh"

module myCPU_tb();

    reg CLK_50;
    reg rst;

    initial 
    begin
        CLK_50 = 1'b0;
        forever #10 CLK_50 = ~CLK_50;
    end

    initial 
    begin
        rst = `RST_ENABLE;
        #195 rst = `RST_DISABLE;
        #10000 $stop;
    end

    myCPU myCPU0(
        .clk(CLK_50),
        .rst(rst)
    );

endmodule