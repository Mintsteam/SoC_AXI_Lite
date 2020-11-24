`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"

module CTRL(

    input wire rst,
    input wire arbiter_stall_req,
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
                32'h00000001:new_pc <= 32'hbfc00380;    //中断例外
                32'h00000004:new_pc <= 32'hbfc00380;    //取指或读数据时发生地址错例外
                32'h00000005:new_pc <= 32'hbfc00380;    //写数据时发生地址错例外
                32'h00000008:new_pc <= 32'hbfc00380;    //系统调用syscall例外
                32'h00000009:new_pc <= 32'hbfc00380;    //断点例外
                32'h0000000a:new_pc <= 32'hbfc00380;    //保留指令例外
                32'h0000000d:new_pc <= 32'hbfc00380;    //自陷例外
                32'h0000000c:new_pc <= 32'hbfc00380;    //整形溢出例外
                32'h0000000e:new_pc <= cp0_epc_i;       //异常返回指令
                default: begin
                    new_pc <= `ZEROWORD;
                end
            endcase
        end else if(ex_stall_req == `STOP) begin        //若执行阶段提出阻塞流水线请求，则将EX及此前的阶段均阻塞
            stall <= 6'b001111;
            flush <= 1'b0;
        end else if(id_stall_req == `STOP) begin        //若译码阶段提出阻塞流水线请求，则将ID及此前的阶段均阻塞
            stall <= 6'b000111;
            flush <= 1'b0;
        end else if(arbiter_stall_req == `STOP) begin   //仲裁器访存时发送阻塞请求，将所有阶段全部阻塞
            stall <= 6'b111111;
        end else begin                                  //正常运行
            stall <= 6'b000000;
            flush <= 1'b0;
            new_pc <= `ZEROWORD;
        end
    end

endmodule