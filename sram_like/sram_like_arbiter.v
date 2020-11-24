`timescale 1ns / 1ps

`include "../define/global.vh"

module sram_like_arbiter
(
    input wire          clk             ,
    input wire          rst             ,

    //SRAM interface for ROM
    input wire          inst_en_sram    ,
    input wire  [31:0]  inst_addr_sram  ,
    input wire  [3 :0]  inst_wen_sram   ,
    input wire  [31:0]  inst_din_sram   ,
    output wire [31:0]  inst_dout_sram  ,

    //SRAM interface for RAM
    input wire          data_en_sram    ,
    input wire  [31:0]  data_addr_sram  ,
    input wire  [3 :0]  data_wen_sram   ,
    input wire  [31:0]  data_din_sram   ,
    output wire [31:0]  data_dout_sram  ,

    //SRAM-like interface for ROM
    output wire         inst_req        ,
    output wire         inst_wr         ,
    output wire [1 :0]  inst_size       ,
    output wire [31:0]  inst_addr       ,
    output wire [31:0]  inst_wdata      ,
    input wire          inst_addr_ok    ,
    input wire          inst_data_ok    ,
    input wire  [31:0]  inst_rdata      ,
    
    //SRAM-like interface for RAM
    output wire         data_req        ,
    output wire         data_wr         ,
    output wire [1 :0]  data_size       ,
    output wire [31:0]  data_addr       ,
    output wire [31:0]  data_wdata      ,
    input wire          data_addr_ok    ,
    input wire          data_data_ok    ,
    input wire  [31:0]  data_rdata      ,

    input wire          exception_flag  ,
    output wire         arbiter_stall_req
);

//�ݴ����ɵ�req�ź�
reg inst_req_temp;    
reg data_req_temp;
//�ݴ���Ӧsram-like�ӿڵ�ram�������ֽ���
reg [1:0] data_size_adapt;    
//�ݴ�ram�ķ��ʵ�ַ
reg[31:0] data_addr_temp;

//ʹ��SRAM�˿��ź�ΪSRAM-like�˿��źŸ�ֵ
assign inst_req   = inst_req_temp;
assign inst_wr    = 1'b0;
assign inst_size  = 2'b10;
assign inst_addr  = inst_addr_sram;
assign inst_wdata = 32'h0000;

assign data_req   = data_req_temp;
assign data_wr    = data_en_sram;
assign data_size  = data_size_adapt;
assign data_addr  = data_addr_temp;
assign data_wdata = data_din_sram;

reg [31:0] last_data_addr, last_inst_addr;
reg [31:0] last_data_data, last_inst_data;
reg [31:0] last_data_addr_temp, last_inst_addr_temp;
reg [31:0] last_data_data_temp, last_inst_data_temp;
reg ram_data_dirty_flag;
reg ram_data_dirty_flag_temp;

assign inst_dout_sram = last_inst_data_temp;
assign data_dout_sram = last_data_data_temp;

reg next_data_access_flag, next_inst_access_flag;
reg data_access_flag, inst_access_flag;

//״̬ת�Ƶ�ǰ��
wire inst_access_valid;  
wire data_access_valid;

assign inst_access_valid = inst_en_sram && inst_addr_sram != last_inst_addr;
assign data_access_valid = data_en_sram && (data_addr_sram != last_data_addr || (data_addr_sram[31:28] >= 4'ha && data_addr_sram[31:28] <= 4'hb) || (data_wen_sram ? data_din_sram != last_data_data : ram_data_dirty_flag)) && rst;

localparam state_idle    = 2'b00,        //�ٲ�������
           state_access  = 2'b01,        //�ٲ������շô��ź�
           state_data    = 2'b10,        //�ٲ�������ָ��ô��ź�
           state_inst    = 2'b11;        //�ٲ����������ݷô��ź�

reg[1:0] current_state;
reg[1:0] next_state;

//����SRAM-like��ram�������ֽ�������ʵ�ַ
always @(*) 
begin
    if (rst == `RST_ENABLE) 
    begin
        data_size_adapt <= 0;
        data_addr_temp <= 0;
    end else if (!data_wr) begin
        data_size_adapt <= 2'b10;
        data_addr_temp <= data_addr_sram;
    end else begin
        case (data_wen_sram)
            4'b0001: begin
                data_size_adapt <= 2'b00;
                data_addr_temp <= {data_addr_sram[31:2], 2'b00};
            end 
            4'b0010: begin
                data_size_adapt <= 2'b00;
                data_addr_temp <= {data_addr_sram[31:2], 2'b01};
            end 
            4'b0100: begin
                data_size_adapt <= 2'b00;
                data_addr_temp <= {data_addr_sram[31:2], 2'b10};
            end 
            4'b1000: begin
                data_size_adapt <= 2'b00;
                data_addr_temp <= {data_addr_sram[31:2], 2'b11};
            end 
            4'b0011: begin
                data_size_adapt <= 2'b01;
                data_addr_temp <= {data_addr_sram[31:2], 2'b00};
            end 
            4'b1100: begin
                data_size_adapt <= 2'b01;
                data_addr_temp <= {data_addr_sram[31:2], 2'b10};
            end 
            4'b1111: begin
                data_size_adapt <= 2'b10;
                data_addr_temp <= {data_addr_sram[31:2], 2'b00};
            end 
            default: begin
                data_size_adapt <= 0;
                data_addr_temp <= 0;
            end
        endcase
    end
end

reg[3:0] debug;

//����req�ź�
always @(*) 
begin
    if(rst == `RST_ENABLE) 
    begin
        data_req_temp <= 0;
        inst_req_temp <= 0;
        debug <= 3'b000;
    end else if((current_state == state_idle && next_state == state_access && data_access_valid)) begin //��������״̬ת�������ʾ�������źŲ���
        data_req_temp <= data_access_valid;
        debug <= 3'b010;
    end else if(data_addr_ok && (current_state == state_access && next_state == state_data)) begin //����req�źţ���ֹ��������ַ�ٴ�����
        data_req_temp <= 0;
        debug <= 3'b001;
    end else if((current_state == state_idle && next_state == state_access && inst_access_valid) || (current_state == state_inst && inst_addr_ok)) begin //��������״̬ת�������ʾ�������źŲ���
        inst_req_temp <= inst_access_valid;
        debug <= 3'b100;
    end else if(inst_addr_ok && (current_state == state_access && next_state == state_inst)) begin
        inst_req_temp <= 0;
        debug <= 3'b011;
    end else begin
        debug <= 3'b101;
        data_req_temp <= 0;
        inst_req_temp <= 0;
    end
end

reg arbiter_stall_req_temp;

//�ڷô�ʱ����CPU������
always @(*)
begin
    if(current_state == state_idle && data_req)
    begin
        arbiter_stall_req_temp <= 1'b1;
    end else if(current_state == state_idle && inst_req) begin
        arbiter_stall_req_temp <= 1'b1;
    end else if(current_state == state_inst && next_state == state_idle) begin
        arbiter_stall_req_temp <= 1'b0;
    end else if(current_state != state_idle) begin
        arbiter_stall_req_temp <= 1'b1;
    end else begin
        arbiter_stall_req_temp <= 1'b0;
    end
end

assign arbiter_stall_req =  arbiter_stall_req_temp;

//----------------------------------------------------------------------
//Synchronous State-Transition always @(posedge clk) block
//----------------------------------------------------------------------
always @(posedge clk) 
begin
    if(rst == `RST_ENABLE)
        current_state <= state_idle;
    else begin
        current_state <= next_state;
    end
end
//----------------------------------------------------------------------

//----------------------------------------------------------------------
//Conditional State-Transition always @(*) block
//----------------------------------------------------------------------
always @(*)
begin
    next_state <= current_state;
    case (current_state)
        state_idle: begin
            next_state <= state_access;
        end
        state_access: begin
            if(data_access_valid)
            begin
                next_state <= state_data;
            end else if(inst_access_valid) begin
                next_state <= state_inst;
            end
        end
        state_data: begin
            if(data_data_ok) 
            begin
                if(inst_access_valid)
                begin
                    next_state <= state_inst;
                end else begin
                    next_state <= state_idle;
                end
            end
        end
        state_inst: begin
            if(inst_data_ok)
            begin
                next_state <= state_idle;
            end
        end
    endcase
end
//----------------------------------------------------------------------

//����req�ĳ����ź�
always @(*)
begin
    if(data_req && data_addr_ok) 
    begin
        next_data_access_flag <= 1;
    end else if(inst_req && inst_addr_ok) begin
        next_inst_access_flag <= 1;
    end else if(data_access_flag && data_data_ok) begin
        next_data_access_flag <= 0;
    end else if(inst_access_flag && inst_data_ok) begin
        next_inst_access_flag <= 0;
    end else begin
        next_data_access_flag <= data_access_flag;
        next_inst_access_flag <= inst_access_flag;
    end
end

//�ô��־λ������ڷô���inst/data
always @(posedge clk) 
begin
    if(!rst)
    begin
        data_access_flag <= 0;
        inst_access_flag <= 0;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  ;
    end else begin
        data_access_flag <= next_data_access_flag;
        inst_access_flag <= next_inst_access_flag;
    end 
end

//�����ϴη���RAM�ĵ�ַ
always @(posedge clk)
begin
    if(!rst) 
    begin
        last_data_addr <= 0;
        last_inst_addr <= 0;
    end else if(data_data_ok) begin
        last_data_addr <= data_addr;
    end else if(inst_data_ok) begin
        last_inst_addr <= inst_addr;
    end
end

//�ж��Ƿ�д�������ݣ��Ƿ���������д��RAM
always @(*)
begin
    if(rst == `RST_ENABLE) 
    begin
        last_data_data_temp <= 0;
        last_inst_data_temp <= 0;
        ram_data_dirty_flag_temp <= 0;
    end else if(data_en_sram && data_data_ok) begin
        if(data_wr) 
        begin
            last_data_data_temp <= data_wdata;
            ram_data_dirty_flag_temp <= data_size != 2'b10;
        end else begin
            last_data_data_temp <= data_rdata;
            ram_data_dirty_flag_temp <= 0;
        end
    end else if(inst_en_sram && inst_data_ok) begin
        last_inst_data_temp <= inst_rdata;
    end else begin
        last_data_data_temp <= 0;
        last_inst_data_temp <= 0;
        ram_data_dirty_flag_temp <= 0;
    end
end

//�����ϴν��յ����ݣ������Ƿ�д����������RAM
always @(posedge clk) 
begin
    if(rst == `RST_ENABLE) begin
        last_data_data <= 0;
        last_inst_data <= 0;
        ram_data_dirty_flag <= 0;
    end else begin
        last_data_data <= last_data_data_temp;
        last_inst_data <= last_inst_data_temp;
        ram_data_dirty_flag <= ram_data_dirty_flag_temp;
    end
end




endmodule