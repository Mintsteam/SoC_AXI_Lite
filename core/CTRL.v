`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"

module CTRL(

    input wire rst,
    input wire id_stall_req,
    input wire ex_stall_req,

    input wire[31:0] exception_type_i,
    input wire[`REG_DATA_BUS] cp0_epc_i,

    output reg[`REG_DATA_BUS] new_pc,
    output reg flush,

    output reg[5:0] stall

);

    always @ (*)
    begin
        if(rst == `RST_ENABLE)
        begin
            stall <= 6'b000000;
            flush <= 1'b0;
            new_pc <= `ZEROWORD;
        end else if(exception_type_i != `ZEROWORD) begin    //若异常类型不为0
            stall <= 6'b000000;     //所有阶段正常运行
            flush <= 1'b1;          //清空流水线
            case(exception_type_i)
                32'h00000001:new_pc <= 32'h00000020;    //中断的异常处理入口地址
                32'h00000008:new_pc <= 32'h00000040;    //系统调用syscall的异常处理入口地址
                32'h0000000a:new_pc <= 32'h00000040;    //指令无效的异常处理入口地址
                32'h0000000d:new_pc <= 32'h00000040;    //自陷的异常处理入口地址
                32'h0000000c:new_pc <= 32'h00000040;    //溢出的异常处理入口地址
                32'h0000000e:new_pc <= cp0_epc_i;       //异常返回指令返回正常程序运行
                default: begin end
            endcase
        end else if(ex_stall_req == `STOP) begin    //若执行阶段提出阻塞流水线请求，则将EX及此前的阶段均阻塞
            stall <= 6'b001111;
            flush <= 1'b0;
        end else if(id_stall_req == `STOP) begin    //若译码阶段提出阻塞流水线请求，则将ID及此前的阶段均阻塞
            stall <= 6'b000111;
            flush <= 1'b0;
        end else begin                              //正常运行
            stall <= 6'b000000;
            flush <= 1'b0;
            new_pc <= `ZEROWORD;
        end
    end

endmodule