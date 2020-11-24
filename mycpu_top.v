`timescale 1ns / 1ps
`include "./define/global.vh"
`include "./define/regfile.vh"
`include "./define/rom.vh"

module mycpu_top(

    input         aclk         ,
    input         aresetn      ,
    input  [5 :0] ext_int      ,
    //axi
    //ar
    output [3 :0] arid         ,
    output [31:0] araddr       ,
    output [7 :0] arlen        ,
    output [2 :0] arsize       ,
    output [1 :0] arburst      ,
    output [1 :0] arlock       ,
    output [3 :0] arcache      ,
    output [2 :0] arprot       ,
    output        arvalid      ,
    input         arready      ,
    //r           
    input  [3 :0] rid          ,
    input  [31:0] rdata        ,
    input  [1 :0] rresp        ,
    input         rlast        ,
    input         rvalid       ,
    output        rready       ,
    //aw          
    output [3 :0] awid         ,
    output [31:0] awaddr       ,
    output [7 :0] awlen        ,
    output [2 :0] awsize       ,
    output [1 :0] awburst      ,
    output [1 :0] awlock       ,
    output [3 :0] awcache      ,
    output [2 :0] awprot       ,
    output        awvalid      ,
    input         awready      ,
    //w          
    output [3 :0] wid          ,
    output [31:0] wdata        ,
    output [3 :0] wstrb        ,
    output        wlast        ,
    output        wvalid       ,
    input         wready       ,
    //b           
    input  [3 :0] bid          ,
    input  [1 :0] bresp        ,
    input         bvalid       ,
    output        bready       ,

    output [31:0] debug_wb_pc       ,
    output [3 :0] debug_wb_rf_wen   ,
    output [4 :0] debug_wb_rf_wnum  ,
    output [31:0] debug_wb_rf_wdata

);

    wire[`INST_ADDR_BUS] inst_addr_from_core; 
    wire[`INST_DATA_BUS] inst;
    wire[`REG_DATA_BUS] ram_addr_o;
    wire[`REG_DATA_BUS] ram_write_data_o;
    wire[3:0] ram_sel_o;
    wire ram_write_en_o;
    wire[`REG_DATA_BUS] data_o;
    wire rom_ce;
    wire ram_ce;
    wire[5:0] interrupt;
    wire timer_interrupt;

    //connect sram_like_arbiter to cpu_axi_interface
    wire inst_req;
    wire inst_wr;
    wire[2:0] inst_size;
    wire[31:0] inst_addr_from_arbiter;
    wire[31:0] inst_rdata;
    wire[31:0] inst_wdata;
    wire data_req;
    wire data_wr;
    wire[2:0] data_size;
    wire[31:0] data_addr;
    wire[31:0] data_rdata;
    wire[31:0] data_wdata;    

    //connect cpu_axi_interface to sram_like_arbiter
    wire inst_addr_ok;
    wire inst_data_ok; 
    wire data_addr_ok;
    wire data_data_ok;  

    //connect cpu_axi_interface to MMU
    wire[31:0] araddr_o;
    wire[31:0] awaddr_o;

    //connect sram_axi_arbiter to core
    wire arbiter_stall_req;

    assign interrupt = ext_int;

    core core0(

        //INPUT
        .clk(aclk),
        .rst(aresetn),
        .rom_data_i(inst),
        .ram_read_data_i(data_o),
        .interrupt_i(interrupt),
        .arbiter_stall_req(arbiter_stall_req),

        //OUTPUT TO ROM
        .rom_addr_o(inst_addr_from_core),
        .rom_ce_o(rom_ce),

        //OUTPUT TO RAM
        .ram_addr_o(ram_addr_o),
        .ram_write_data_o(ram_write_data_o),
        .ram_write_en_o(ram_write_en_o),
        .ram_sel_o(ram_sel_o),
        .ram_ce_o(ram_ce),
        .timer_interrupt_o(timer_interrupt),

        .debug_wb_pc(debug_wb_pc),
        .debug_wb_rf_wen(debug_wb_rf_wen),
        .debug_wb_rf_wnum(debug_wb_rf_wnum),
        .debug_wb_rf_wdata(debug_wb_rf_wdata)

    );

    sram_like_arbiter sram_like_arbiter0(

        //INPUT
        .clk(aclk),
        .rst(aresetn),
        .exception_flag(1'b0),

        //SRAM ROM interface
        //INPUT FROM core
        .inst_en_sram(rom_ce),
        .inst_addr_sram(inst_addr_from_core),
        .inst_wen_sram(4'b0000),
        .inst_din_sram(`ZEROWORD),

        //SRAM ROM interface
        //OUTPUT TO core
        .inst_dout_sram(inst),

        //SRAM RAM interface
        //INPUT FROM core
        .data_en_sram(ram_ce),
        .data_addr_sram(ram_addr_o),
        .data_wen_sram(ram_sel_o),
        .data_din_sram(ram_write_data_o),
        
        //SRAM RAM interface
        //OUTPUT TO core
        .data_dout_sram(data_o),

        //SRAM-like inst interface
        //INPUT FROM cpu_axi_interface
        .inst_addr_ok(inst_addr_ok),
        .inst_data_ok(inst_data_ok),
        .inst_rdata(inst_rdata),

        //OUTPUT TO cpu_axi_interface
        .inst_req(inst_req),
        .inst_wr(inst_wr),
        .inst_size(inst_size),
        .inst_addr(inst_addr_from_arbiter),
        .inst_wdata(inst_wdata),

        //SRAM-like data interface
        //INPUT FROM cpu_axi_interface
        .data_addr_ok(data_addr_ok),
        .data_data_ok(data_data_ok),
        .data_rdata(data_rdata),

        //OUTPUT TO cpu_axi_interface
        .data_req(data_req),
        .data_wr(data_wr),
        .data_size(data_size),
        .data_addr(data_addr),
        .data_wdata(data_wdata),

        //OUTPUT TO CTRL
        .arbiter_stall_req(arbiter_stall_req)

    );

    cpu_axi_interface cpu_axi_interface0(

        //INPUT
        .clk(aclk),
        .resetn(aresetn),

        //SRAM-like inst interface
        //INPUT FROM arbiter
        .inst_req(inst_req),
        .inst_wr(inst_wr),
        .inst_size(inst_size),
        .inst_addr(inst_addr_from_arbiter),
        .inst_wdata(inst_wdata),

        //OUTPUT TO arbiter
        .inst_addr_ok(inst_addr_ok),
        .inst_data_ok(inst_data_ok),
        .inst_rdata(inst_rdata),

        //SRAM-like data interface
        //INPUT FROM arbiter
        .data_req(data_req),
        .data_wr(data_wr),
        .data_size(data_size),
        .data_addr(data_addr),
        .data_wdata(data_wdata),

        //OUTPUT TO arbiter
        .data_addr_ok(data_addr_ok),
        .data_data_ok(data_data_ok),
        .data_rdata(data_rdata),

        //axi
        //ar
        .arid(arid),
        .araddr(araddr_o),
        .arlen(arlen),
        .arsize(arsize),
        .arburst(arburst),
        .arlock(arlock),
        .arcache(arcache),
        .arprot(arprot),
        .arvalid(arvalid),
        .arready(arready),
        //r           
        .rid(rid),
        .rdata(rdata),
        .rresp(rresp),
        .rlast(rlast),
        .rvalid(rvalid),
        .rready(rready),
        //aw          
        .awid(awid),
        .awaddr(awaddr_o),
        .awlen(awlen),
        .awsize(awsize),
        .awburst(awburst),
        .awlock(awlock),
        .awcache(awcache),
        .awprot(awprot),
        .awvalid(awvalid),
        .awready(awready),
        //w          
        .wid(wid),
        .wdata(wdata),
        .wstrb(wstrb),
        .wlast(wlast),
        .wvalid(wvalid),
        .wready(wready),
        //b           
        .bid(bid),
        .bresp(bresp),
        .bvalid(bvalid),
        .bready(bready)       

    );

    MMU MMU0(

        //INPUT 
        .resetn(aresetn),

        //INPUT FROM cpu_axi_interface
        .read_addr_i(araddr_o),
        .write_addr_i(awaddr_o),

        //OUTPUT TO mycpu_top
        .read_addr_o(araddr),
        .write_addr_o(awaddr)

    );

    /*
    inst_ram inst_ram0(

        .addra(inst_addr[17:2]),
        .clka(clk),
        .dina(`ZEROWORD),
        .douta(inst),
        .ena(rom_ce),
        .wea(4'b0000)

    ); 

    ROM ROM0(
        
        .ce(rom_ce),
        .addr(inst_addr),
        .inst(inst)

    );
    
    RAM RAM0(

        //INPUT
        .clk(clk),
        .ce(ram_ce),
        .write_en(ram_write_en_o),
        .addr(ram_addr_o),
        .sel(ram_sel_o),
        .data_i(ram_write_data_o),

        //OUTPUT
        .data_o(data_o)

    );
    */

endmodule