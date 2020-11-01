`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"
`include "../define/opcode.vh"
`include "../define/cp0.vh"

module CP0(

    input wire clk,
    input wire rst,

    input wire[4:0] write_addr_i,
    input wire[`REG_DATA_BUS] write_data_i,
    input wire write_en_i,
    input wire[4:0] read_addr_i,
    
    input wire[5:0] interrupt_i,

    output reg[`REG_DATA_BUS] read_data_o,
    output reg[`REG_DATA_BUS] count_o,
    output reg[`REG_DATA_BUS] compare_o,
    output reg[`REG_DATA_BUS] status_o,
    output reg[`REG_DATA_BUS] cause_o,
    output reg[`REG_DATA_BUS] epc_o,
    output reg[`REG_DATA_BUS] config_o,
    output reg[`REG_DATA_BUS] prid_o,
    output reg timer_interrupt_o

);

    always @ (posedge clk) 
    begin
        if(rst == `RST_ENABLE)
        begin
            count_o <= `ZEROWORD;
            compare_o <= `ZEROWORD;
            status_o <= 32'b00010000000000000000000000000000;
            cause_o <= `ZEROWORD;
            epc_o <= `ZEROWORD;
            config_o <= 32'b00000000000000001000000000000000;
			prid_o <= 32'b00000000010011000000000100000010;
            timer_interrupt_o <= `INTERRUPT_NOT_ASSERT;
        end else begin
            count_o <= count_o + 1;
            cause_o[15:10] <= interrupt_i;
            if(compare_o != `ZEROWORD && count_o == compare_o)
            begin
                timer_interrupt_o <= `INTERRUPT_ASSERT;
            end
            if(write_en_i == `WRITE_ENABLE)
            begin
                case(write_addr_i)
                    `CP0_REG_COUNT:count_o <= write_data_i;
                    `CP0_REG_COMPARE:{compare_o, timer_interrupt_o} <= {write_data_i, `INTERRUPT_NOT_ASSERT};
                    `CP0_REG_STATUS:status_o <= write_data_i;
                    `CP0_REG_EPC:epc_o <= write_data_i;
                    `CP0_REG_CAUSE:{cause_o[9:8], cause_o[23], cause_o[22]} <= {write_data_i[9:8], write_data_i[23], write_data_i[22]};
                    default:begin end
                endcase
            end 
        end   
    end

    always @ (*)
    begin
        if(rst == `RST_ENABLE)
        begin
            read_data_o <= `ZEROWORD;
        end else begin
            case(read_addr_i)
                `CP0_REG_COUNT:read_data_o <= count_o;
                `CP0_REG_COMPARE:read_data_o <= compare_o;
                `CP0_REG_STATUS:read_data_o <= status_o;
                `CP0_REG_EPC:read_data_o <= epc_o;
                `CP0_REG_CAUSE:read_data_o <= cause_o;
                `CP0_REG_PRId:read_data_o <= prid_o;
                `CP0_REG_CONFIG:read_data_o <= config_o;
                default:begin end
            endcase
        end 
    end

endmodule