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
        end else if(exception_type_i != `ZEROWORD) begin    //���쳣���Ͳ�Ϊ0
            stall <= 6'b000000;     //���н׶���������
            flush <= 1'b1;          //�����ˮ��
            case(exception_type_i)
                32'h00000001:new_pc <= 32'hbfc00380;    //�ж�����
                32'h00000004:new_pc <= 32'hbfc00380;    //ȡָ�������ʱ������ַ������
                32'h00000005:new_pc <= 32'hbfc00380;    //д����ʱ������ַ������
                32'h00000008:new_pc <= 32'hbfc00380;    //ϵͳ����syscall����
                32'h00000009:new_pc <= 32'hbfc00380;    //�ϵ�����
                32'h0000000a:new_pc <= 32'hbfc00380;    //����ָ������
                32'h0000000d:new_pc <= 32'hbfc00380;    //��������
                32'h0000000c:new_pc <= 32'hbfc00380;    //�����������
                32'h0000000e:new_pc <= cp0_epc_i;       //�쳣����ָ��
                default: begin
                    new_pc <= `ZEROWORD;
                end
            endcase
        end else if(ex_stall_req == `STOP) begin        //��ִ�н׶����������ˮ��������EX����ǰ�Ľ׶ξ�����
            stall <= 6'b001111;
            flush <= 1'b0;
        end else if(id_stall_req == `STOP) begin        //������׶����������ˮ��������ID����ǰ�Ľ׶ξ�����
            stall <= 6'b000111;
            flush <= 1'b0;
        end else if(arbiter_stall_req == `STOP) begin   //�ٲ����ô�ʱ�����������󣬽����н׶�ȫ������
            stall <= 6'b111111;
        end else begin                                  //��������
            stall <= 6'b000000;
            flush <= 1'b0;
            new_pc <= `ZEROWORD;
        end
    end

endmodule