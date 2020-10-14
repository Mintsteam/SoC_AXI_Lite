`include "../define/global.vh"
`include "../define/rom.vh"

module IF_ID(

    input wire clk,
    input wire rst,

    input wire [`INST_ADDR_BUS] if_pc,
    input wire [`INST_DATA_BUS] if_inst,

    output reg[`INST_ADDR_BUS] id_pc,
    output reg[`INST_DATA_BUS] id_inst

);

    always @ (posedge clk)
    begin
        id_pc <= ( rst ? `ZEROWORD : if_pc );
        id_inst <= ( rst ? `ZEROWORD : if_inst ); 
    end

endmodule