`include "../define/global.vh"
`include "../define/rom.vh"

module IF_ID(

    input wire clk,
    input wire rst,

    input wire [`INST_ADDR_BUS] if_pc,
    input wire [`INST_DATA_BUS] if_inst,

    input wire[5:0] stall,
    input wire flush,

    output reg[`INST_ADDR_BUS] id_pc,
    output reg[`INST_DATA_BUS] id_inst

);

    always @ (posedge clk)
    begin
        if(rst == `RST_ENABLE)
        begin
            id_pc <= `ZEROWORD;
            id_inst <= `ZEROWORD;
        end else if(flush == 1'b1) begin
            id_pc <= `ZEROWORD;
            id_inst <= `ZEROWORD;
        end else if(stall[1] == `STOP && stall[2] == `NOT_STOP) begin
            id_pc <= `ZEROWORD;
            id_inst <= `ZEROWORD;
        end else if(stall[1] == `NOT_STOP) begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end

endmodule
