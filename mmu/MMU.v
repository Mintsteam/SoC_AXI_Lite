`timescale 1ns / 1ps

`define IN_RANGE(lower_bound, upper_bound, x) x[31:28] >= (lower_bound) && x[31:28] <= (upper_bound)

module MMU
(
    input           resetn,
    input   [31:0]  read_addr_i,
    input   [31:0]  write_addr_i,
    output reg [31:0]  read_addr_o,
    output reg [31:0]  write_addr_o
);

    always @(*) 
    begin
        if(!resetn) 
        begin
            read_addr_o = 0;
        end else begin
            if(`IN_RANGE( 4'h0, 4'h7, read_addr_i)) 
            begin
                read_addr_o = read_addr_i;
            end else if(`IN_RANGE(4'h8, 4'h9, read_addr_i)) begin
                read_addr_o = {read_addr_i[31:28] - 4'h8, read_addr_i[27:0]};
            end else if(`IN_RANGE(4'ha, 4'hb, read_addr_i)) begin
                read_addr_o = {read_addr_i[31:28] - 4'ha, read_addr_i[27:0]};
            end else if(`IN_RANGE(4'hc, 4'hd, read_addr_i)) begin
                read_addr_o = read_addr_i;
            end else begin   // 32'he000_0000, 32'hffff_ffff
                read_addr_o = read_addr_i;
            end
        end
    end

    always @(*) 
    begin
        if(!resetn) 
        begin
            write_addr_o = 0;
        end else begin
            if(`IN_RANGE(4'h0, 4'h7, write_addr_i)) 
            begin
                write_addr_o = write_addr_i;
            end else if(`IN_RANGE(4'h8, 4'h9, write_addr_i)) begin
                write_addr_o = {write_addr_i[31:28] - 4'h8, write_addr_i[27:0]};
            end else if(`IN_RANGE(4'ha, 4'hb, write_addr_i)) begin
                write_addr_o = {write_addr_i[31:28] - 4'ha, write_addr_i[27:0]};
            end else if(`IN_RANGE(4'hc, 4'hd, write_addr_i)) begin
                write_addr_o = write_addr_i;
            end else begin   // 32'he000_0000, 32'hffff_ffff
                write_addr_o = write_addr_i;
            end
        end
    end

endmodule  //MMU