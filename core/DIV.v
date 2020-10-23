`timescale 1ns / 1ps
`include "../define/global.vh"
`include "../define/regfile.vh"
`include "../define/opcode.vh"

module DIV(

    input wire clk,
    input wire rst,

    input wire[`REG_DATA_BUS] operand_1_i,
    input wire[`REG_DATA_BUS] operand_2_i,
    input wire start_div_i,
    input wire signed_div_i,
    input wire discard_div,

    output reg[`DOUBLE_REG_DATA_BUS] div_out,
    output reg div_ready_o 

);

    wire[32:0] div_temp;
    reg[5:0] count;
    reg[64:0] dividend;
    reg[31:0] divisor;
    reg[1:0] state;
    reg[31:0] operand_1_temp;
    reg[31:0] operand_2_temp;

    assign div_temp = {1'b0, dividend[63:32]} - {1'b0, divisor};

    always @ (posedge clk)
    begin
        if(rst == `RST_ENABLE)
        begin
            state <= `DIV_READY;
            div_ready_o <= `DIV_RESULT_NOT_READY;
            div_out <= {`ZEROWORD, `ZEROWORD};
        end else begin
            case(state)
                `DIV_READY: begin
                    if(start_div_i == `DIV_START && discard_div == 1'b0)
                    begin      
                        if(operand_2_i == `ZEROWORD)
                        begin
                            state <= `DIV_BY_ZERO;
                        end else begin            
                            state <= `DIV_EXECUTING;
                            count <= 6'b000000;
                            if(signed_div_i == 1'b1 && operand_1_i[31] == 1'b1)
                            begin
                                operand_1_temp = ~operand_1_i + 1;
                            end else begin
                                operand_1_temp = operand_1_i;
                            end
                            if(signed_div_i == 1'b1 && operand_2_i[31] == 1'b1)
                            begin
                                operand_2_temp = ~operand_2_i + 1;
                            end else begin
                                operand_2_temp = operand_2_i;
                            end
                            dividend <= {`ZEROWORD, `ZEROWORD, 1'b0};
                            dividend[32:1] <= operand_1_temp;
                            divisor <= operand_2_temp;
                        end
                    end else begin
                        div_ready_o <= `DIV_RESULT_NOT_READY;
                        div_out <= {`ZEROWORD, `ZEROWORD};
                    end
                end
                `DIV_BY_ZERO: begin
                    dividend <= {`ZEROWORD, `ZEROWORD};
                    state <= `DIV_END;
                end
                `DIV_EXECUTING: begin
                    if(discard_div == 1'b0)
                    begin
                        if(count != 6'b100000)
                        begin
                            if(div_temp[32] == 1'b1)
                            begin
                                dividend <= {dividend[63:0], 1'b0};
                            end else begin
                                dividend <= {div_temp[31:0], dividend[31:0], 1'b1};
                            end
                            count <= count + 1;
                        end else begin
                            if((signed_div_i == 1'b1) && (operand_1_i[31] ^ operand_2_i[31]) == 1'b1)
                            begin
                                dividend[31:0] <= (~dividend[31:0] +1);
                            end
                            if((signed_div_i == 1'b1) && (operand_1_i[31] ^ dividend[64]) == 1'b1)
                            begin
                                dividend[64:33] <= (~dividend[64:33] +1);
                            end
                            state <= `DIV_END;
                            count <= 6'b000000;
                        end
                    end else begin
                        state <= `DIV_READY;
                    end 
                end
                `DIV_END: begin
                    div_out <= {dividend[64:33], dividend[31:0]};
                    div_ready_o <= `DIV_RESULT_READY;
                    if(start_div_i == `DIV_STOP)
                    begin
                        state <= `DIV_READY;
                        div_ready_o <=`DIV_RESULT_NOT_READY;
                        div_out <= {`ZEROWORD, `ZEROWORD};
                    end
                end     
            endcase
        end 
    end 

endmodule  //DIV