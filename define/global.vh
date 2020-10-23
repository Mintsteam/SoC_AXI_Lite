`define RST_ENABLE 1'b1
`define RST_DISABLE 1'b0
`define ZEROWORD 32'h00000000
`define WRITE_ENABLE 1'b1
`define WRITE_DISABLE 1'b0
`define READ_ENABLE 1'b1
`define READ_DISABLE 1'b0
`define ALU_OP_BUS 7:0
`define ALU_SEL_BUS 2:0
`define INST_VALID 1'b0
`define INST_DISVALID 1'b1
`define TRUE 1'b1
`define FALSE 1'b0
`define CHIP_ENABLE 1'b1
`define CHIP_DISABLE 1'b0
`define STOP 1'b1
`define NOT_STOP 1'b0

//³ý·¨div
`define DIV_READY 2'b00
`define DIV_BY_ZERO 2'b01
`define DIV_EXECUTING 2'b10
`define DIV_END 2'b11
`define DIV_RESULT_READY 1'b1
`define DIV_RESULT_NOT_READY 1'b0
`define DIV_START 1'b1
`define DIV_STOP 1'b0

//stage > component > operation > num
//data > addr > en

/*

pipeline regs naming rules:

INPUT: (last stage)_(component)_(op)_(data type by function)
OUTPUT: (next_stage)_(component)_(op)_(data type by function)

*/