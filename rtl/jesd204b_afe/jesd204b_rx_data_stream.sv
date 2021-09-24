/*
    Название проекта    : ad9371_jesd24b_debug
    Название файла      : jesd204b_rx_data_stream.sv
    Назначение          :
    Автор               : Александрович Ф.А.
    Дата создания       : 2018.03.02
    Синтаксис           : IEEE 1800-2012 (SystemVerilog HDL 2012)
    Комментарии         :
---------------------------------------------------------------------------------------------------------------------
    Состояние модуля    : [ ] проведена проверка синтаксиса (modelsim)
                          [ ] синтезируется без серьезных предупреждений
                          [ ] проведена функциональная проверка (функциональное моделирование) (modelsim)
                          [ ] проведена проверка в целевом проекте
---------------------------------------------------------------------------------------------------------------------
    Ревизия             : 1.0 - 2018.03.02
*/


`timescale 1ns / 1ns


module jesd204b_rx_data_stream
(
    input         link_reset_n,
    input         link_clk,

    input         sysref,

    input  [15:0] link_adc0,
    input  [15:0] link_adc1,
    input  [15:0] link_adc2,
    input  [15:0] link_adc3,

    input         data_ready0,
    input         data_ready1,

    output [15:0] transport_adc0,
    output [15:0] transport_adc1,
    output [15:0] transport_adc2,
    output [15:0] transport_adc3,

    output [67:0] tst_data_st0,
    output [67:0] tst_data_st1,
    output [67:0] tst_data_st2
);


enum int unsigned {
    IDLE = 0, STRETCH_DATA = 1, STRETCH_DATA_CNT_OFF = 2, SYNC_DONE = 3
} state, next_state;


// локальный счетчик мультифреймов и фреймов
reg [7:0] cnt_lmfc;
reg [7:0] cnt_fc;
reg       cnt_fc_en;

reg sysref_ff0;

reg wrreq;
reg wr_en;

reg rdreq;
reg rd_en;

// задержка в фреймах относительно окончания ILAS
reg [7:0] cnt_delay0;
reg cnt_delay0_en;
reg cnt_delay0_rst;

reg [7:0] cnt_delay1;
reg cnt_delay1_en;
reg cnt_delay1_rst;

reg [15:0] link_adc0_ff0;
reg [15:0] link_adc0_ff1;
reg [15:0] link_adc0_ff2;
reg [15:0] link_adc0_ff3;
reg [15:0] link_adc0_ff4;
reg [15:0] link_adc0_ff5;
reg [15:0] link_adc0_ff6;
reg [15:0] link_adc0_ff7;
reg [15:0] link_adc0_ff8;
reg [15:0] link_adc0_ff9;
reg [15:0] link_adc0_ff10;
reg [15:0] link_adc0_ff11;
reg [15:0] link_adc0_ff12;
reg [15:0] link_adc0_ff13;
reg [15:0] link_adc0_ff14;
reg [15:0] link_adc0_ff15;
reg [15:0] link_adc0_ff16;
reg [15:0] link_adc0_ff17;
reg [15:0] link_adc0_ff18;
reg [15:0] link_adc0_ff19;
reg [15:0] link_adc0_ff20;
reg [15:0] link_adc0_ff21;
reg [15:0] link_adc0_ff22;
reg [15:0] link_adc0_ff23;
reg [15:0] link_adc0_ff24;
reg [15:0] link_adc0_ff25;
reg [15:0] link_adc0_ff26;
reg [15:0] link_adc0_ff27;
reg [15:0] link_adc0_ff28;
reg [15:0] link_adc0_ff29;
reg [15:0] link_adc0_ff30;
reg [15:0] link_adc0_ff31;

reg [15:0] link_adc1_ff0;
reg [15:0] link_adc1_ff1;
reg [15:0] link_adc1_ff2;
reg [15:0] link_adc1_ff3;
reg [15:0] link_adc1_ff4;
reg [15:0] link_adc1_ff5;
reg [15:0] link_adc1_ff6;
reg [15:0] link_adc1_ff7;
reg [15:0] link_adc1_ff8;
reg [15:0] link_adc1_ff9;
reg [15:0] link_adc1_ff10;
reg [15:0] link_adc1_ff11;
reg [15:0] link_adc1_ff12;
reg [15:0] link_adc1_ff13;
reg [15:0] link_adc1_ff14;
reg [15:0] link_adc1_ff15;
reg [15:0] link_adc1_ff16;
reg [15:0] link_adc1_ff17;
reg [15:0] link_adc1_ff18;
reg [15:0] link_adc1_ff19;
reg [15:0] link_adc1_ff20;
reg [15:0] link_adc1_ff21;
reg [15:0] link_adc1_ff22;
reg [15:0] link_adc1_ff23;
reg [15:0] link_adc1_ff24;
reg [15:0] link_adc1_ff25;
reg [15:0] link_adc1_ff26;
reg [15:0] link_adc1_ff27;
reg [15:0] link_adc1_ff28;
reg [15:0] link_adc1_ff29;
reg [15:0] link_adc1_ff30;
reg [15:0] link_adc1_ff31;

reg [15:0] link_adc2_ff0;
reg [15:0] link_adc2_ff1;
reg [15:0] link_adc2_ff2;
reg [15:0] link_adc2_ff3;
reg [15:0] link_adc2_ff4;
reg [15:0] link_adc2_ff5;
reg [15:0] link_adc2_ff6;
reg [15:0] link_adc2_ff7;
reg [15:0] link_adc2_ff8;
reg [15:0] link_adc2_ff9;
reg [15:0] link_adc2_ff10;
reg [15:0] link_adc2_ff11;
reg [15:0] link_adc2_ff12;
reg [15:0] link_adc2_ff13;
reg [15:0] link_adc2_ff14;
reg [15:0] link_adc2_ff15;
reg [15:0] link_adc2_ff16;
reg [15:0] link_adc2_ff17;
reg [15:0] link_adc2_ff18;
reg [15:0] link_adc2_ff19;
reg [15:0] link_adc2_ff20;
reg [15:0] link_adc2_ff21;
reg [15:0] link_adc2_ff22;
reg [15:0] link_adc2_ff23;
reg [15:0] link_adc2_ff24;
reg [15:0] link_adc2_ff25;
reg [15:0] link_adc2_ff26;
reg [15:0] link_adc2_ff27;
reg [15:0] link_adc2_ff28;
reg [15:0] link_adc2_ff29;
reg [15:0] link_adc2_ff30;
reg [15:0] link_adc2_ff31;

reg [15:0] link_adc3_ff0;
reg [15:0] link_adc3_ff1;
reg [15:0] link_adc3_ff2;
reg [15:0] link_adc3_ff3;
reg [15:0] link_adc3_ff4;
reg [15:0] link_adc3_ff5;
reg [15:0] link_adc3_ff6;
reg [15:0] link_adc3_ff7;
reg [15:0] link_adc3_ff8;
reg [15:0] link_adc3_ff9;
reg [15:0] link_adc3_ff10;
reg [15:0] link_adc3_ff11;
reg [15:0] link_adc3_ff12;
reg [15:0] link_adc3_ff13;
reg [15:0] link_adc3_ff14;
reg [15:0] link_adc3_ff15;
reg [15:0] link_adc3_ff16;
reg [15:0] link_adc3_ff17;
reg [15:0] link_adc3_ff18;
reg [15:0] link_adc3_ff19;
reg [15:0] link_adc3_ff20;
reg [15:0] link_adc3_ff21;
reg [15:0] link_adc3_ff22;
reg [15:0] link_adc3_ff23;
reg [15:0] link_adc3_ff24;
reg [15:0] link_adc3_ff25;
reg [15:0] link_adc3_ff26;
reg [15:0] link_adc3_ff27;
reg [15:0] link_adc3_ff28;
reg [15:0] link_adc3_ff29;
reg [15:0] link_adc3_ff30;
reg [15:0] link_adc3_ff31;

reg [15:0] link_adc0_wire;
reg [15:0] link_adc1_wire;
reg [15:0] link_adc2_wire;
reg [15:0] link_adc3_wire;

reg data_ready_reg;


wire [10:0] wrusedw;
wire wrfull;
wire wrempty;

wire rdfull;
wire rdempty;


assign transport_adc0 = link_adc0_wire;
assign transport_adc1 = link_adc1_wire;
assign transport_adc2 = link_adc2_wire;
assign transport_adc3 = link_adc3_wire;

assign tst_data_st2 =
{
    link_clk,
    26'h0,
    cnt_lmfc[7:2],
    1'b0,
    cnt_lmfc[1:0],
    cnt_delay1[7:0],
    cnt_delay0[7:0],
    data_ready1,
    data_ready0,
    data_ready_reg,
    cnt_fc[7:0],
    cnt_fc_en,
    sysref_ff0,
    sysref,
    link_clk,
    link_reset_n
};

always_comb
    case (cnt_delay0)

        8'd0    : {link_adc0_wire, link_adc1_wire} = {link_adc0, link_adc1};

        8'd1    : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff0, link_adc1_ff0};

        8'd2    : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff1, link_adc1_ff1};

        8'd3    : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff2, link_adc1_ff2};

        8'd4    : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff3, link_adc1_ff3};

        8'd5    : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff4, link_adc1_ff4};

        8'd6    : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff5, link_adc1_ff5};

        8'd7    : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff6, link_adc1_ff6};

        8'd8    : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff7, link_adc1_ff7};

        8'd9    : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff8, link_adc1_ff8};

        8'd10   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff9, link_adc1_ff9};

        8'd11   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff10, link_adc1_ff10};

        8'd12   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff11, link_adc1_ff11};

        8'd13   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff12, link_adc1_ff12};

        8'd14   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff13, link_adc1_ff13};

        8'd15   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff14, link_adc1_ff14};

        8'd16   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff15, link_adc1_ff15};

        8'd17   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff16, link_adc1_ff16};

        8'd18   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff17, link_adc1_ff17};

        8'd19   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff18, link_adc1_ff18};

        8'd20   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff19, link_adc1_ff19};

        8'd21   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff20, link_adc1_ff20};

        8'd22   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff21, link_adc1_ff21};

        8'd23   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff22, link_adc1_ff22};

        8'd24   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff23, link_adc1_ff23};

        8'd25   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff24, link_adc1_ff24};

        8'd26   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff25, link_adc1_ff25};

        8'd27   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff26, link_adc1_ff26};

        8'd28   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff27, link_adc1_ff27};

        8'd29   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff28, link_adc1_ff28};

        8'd30   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff29, link_adc1_ff29};

        8'd31   : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff30, link_adc1_ff30};

        default : {link_adc0_wire, link_adc1_wire} = {link_adc0_ff31, link_adc1_ff31};

    endcase

always_comb
    case (cnt_delay1)

        8'd0    : {link_adc2_wire, link_adc3_wire} = {link_adc2, link_adc3};

        8'd1    : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff0, link_adc3_ff0};

        8'd2    : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff1, link_adc3_ff1};

        8'd3    : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff2, link_adc3_ff2};

        8'd4    : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff3, link_adc3_ff3};

        8'd5    : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff4, link_adc3_ff4};

        8'd6    : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff5, link_adc3_ff5};

        8'd7    : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff6, link_adc3_ff6};

        8'd8    : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff7, link_adc3_ff7};

        8'd9    : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff8, link_adc3_ff8};

        8'd10   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff9, link_adc3_ff9};

        8'd11   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff10, link_adc3_ff10};

        8'd12   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff11, link_adc3_ff11};

        8'd13   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff12, link_adc3_ff12};

        8'd14   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff13, link_adc3_ff13};

        8'd15   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff14, link_adc3_ff14};

        8'd16   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff15, link_adc3_ff15};

        8'd17   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff16, link_adc3_ff16};

        8'd18   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff17, link_adc3_ff17};

        8'd19   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff18, link_adc3_ff18};

        8'd20   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff19, link_adc3_ff19};

        8'd21   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff20, link_adc3_ff20};

        8'd22   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff21, link_adc3_ff21};

        8'd23   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff22, link_adc3_ff22};

        8'd24   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff23, link_adc3_ff23};

        8'd25   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff24, link_adc3_ff24};

        8'd26   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff25, link_adc3_ff25};

        8'd27   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff26, link_adc3_ff26};

        8'd28   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff27, link_adc3_ff27};

        8'd29   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff28, link_adc3_ff28};

        8'd30   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff29, link_adc3_ff29};

        8'd31   : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff30, link_adc3_ff30};

        default : {link_adc2_wire, link_adc3_wire} = {link_adc2_ff31, link_adc3_ff31};

    endcase


// последовательная логика со стороны Data Link Layer
// последовательная часть FSM
always_ff @(posedge link_clk, negedge link_reset_n)
    if (!link_reset_n)
        state <= IDLE;
    else
        state <= next_state;

// комбинационная часть FSM
always_comb begin
    next_state = IDLE;
    case (state)

        IDLE :
            if ((cnt_lmfc == 8'd5) && (cnt_fc == 8'd32))
                next_state = STRETCH_DATA;

        STRETCH_DATA :
            if ((cnt_lmfc == 8'd6) && (cnt_fc == 8'd31))
                next_state = STRETCH_DATA_CNT_OFF;
            else
                next_state = STRETCH_DATA;

        STRETCH_DATA_CNT_OFF : next_state = SYNC_DONE;

        SYNC_DONE :
            if ((data_ready0) && (data_ready1))
                next_state = SYNC_DONE;

    endcase
end

// последовательные выходны FSM
always_ff @(posedge link_clk, negedge link_reset_n)
    if(!link_reset_n) begin
        cnt_delay0_en <= 1'b0;
        cnt_delay0_rst <= 1'b1;
        cnt_delay1_en <= 1'b0;
        cnt_delay1_rst <= 1'b1;
        data_ready_reg <= 1'b0;
    end else
        case (next_state)

            IDLE : begin
                cnt_delay0_en <= 1'b0;
                cnt_delay0_rst <= 1'b1;
                cnt_delay1_en <= 1'b0;
                cnt_delay1_rst <= 1'b1;
                data_ready_reg <= 1'b0;
            end

            STRETCH_DATA : begin
                cnt_delay0_en <= 1'b1;
                cnt_delay0_rst <= 1'b0;
                cnt_delay1_en <= 1'b1;
                cnt_delay1_rst <= 1'b0;
            end

            STRETCH_DATA_CNT_OFF : begin
                cnt_delay0_en <= 1'b0;
                cnt_delay1_en <= 1'b0;
            end

            SYNC_DONE : data_ready_reg <= 1'b1;

        endcase

always_ff @(posedge link_clk, negedge link_reset_n)
    if (!link_reset_n)
        cnt_delay0 <= 8'h0;
    else
        if (cnt_delay0_rst)
            cnt_delay0 <= 8'h0;
        else if ((cnt_delay0_en) && (data_ready0))
            cnt_delay0 <= cnt_delay0 + 8'h1;

always_ff @(posedge link_clk, negedge link_reset_n)
    if (!link_reset_n)
        cnt_delay1 <= 8'h0;
    else
        if (cnt_delay1_rst)
            cnt_delay1 <= 8'h0;
        else if ((cnt_delay1_en) && (data_ready1))
            cnt_delay1 <= cnt_delay1 + 8'h1;

always_ff @(posedge link_clk, negedge link_reset_n)
    if (!link_reset_n)
        wr_en <= 1'b0;
    else
        if (wrfull)
            wr_en <= 1'b0;
        else if ((wrempty) && (data_ready_reg))
            wr_en <= 1'b1;

always_ff @(posedge link_clk, negedge link_reset_n)
    if (!link_reset_n)
        wrreq <= 1'b0;
    else
        if (wrfull)
            wrreq <= 1'b0;
        else if (wr_en)
            wrreq <= 1'b1;

always_ff @(posedge link_clk, negedge link_reset_n)
    if (!link_reset_n)
        cnt_fc_en <= 1'b0;
    else
        if ({sysref_ff0, sysref} == 2'h1)
            cnt_fc_en <= 1'b1;

always_ff @(posedge link_clk, negedge link_reset_n)
    if (!link_reset_n)
        cnt_fc <= 8'd1;
    else
        if (({sysref_ff0, sysref} == 2'h1) || (cnt_fc == 8'd32))
            cnt_fc <= 8'h1;
        else if (cnt_fc_en)
            cnt_fc <= cnt_fc + ~&cnt_fc;

always_ff @(posedge link_clk, negedge link_reset_n)
    if (!link_reset_n)
        cnt_lmfc <= 8'd1;
    else
        if ({sysref_ff0, sysref} == 2'h1)
            cnt_lmfc <= 8'd1;
        else if (cnt_fc == 8'd32)
            cnt_lmfc <= cnt_lmfc + 8'd1;

always_ff @(posedge link_clk, negedge link_reset_n)
    if (!link_reset_n)
        sysref_ff0 <= 1'b0;
    else
        sysref_ff0 <= sysref;

// реализация Elastic Buffer на 32 фрейма
always_ff @(posedge link_clk, negedge link_reset_n)
    if (!link_reset_n) begin
        link_adc0_ff0 <= 16'h0;
        link_adc0_ff1 <= 16'h0;
        link_adc0_ff2 <= 16'h0;
        link_adc0_ff3 <= 16'h0;
        link_adc0_ff4 <= 16'h0;
        link_adc0_ff5 <= 16'h0;
        link_adc0_ff6 <= 16'h0;
        link_adc0_ff7 <= 16'h0;
        link_adc0_ff8 <= 16'h0;
        link_adc0_ff9 <= 16'h0;
        link_adc0_ff10 <= 16'h0;
        link_adc0_ff11 <= 16'h0;
        link_adc0_ff12 <= 16'h0;
        link_adc0_ff13 <= 16'h0;
        link_adc0_ff14 <= 16'h0;
        link_adc0_ff15 <= 16'h0;
        link_adc0_ff16 <= 16'h0;
        link_adc0_ff17 <= 16'h0;
        link_adc0_ff18 <= 16'h0;
        link_adc0_ff19 <= 16'h0;
        link_adc0_ff20 <= 16'h0;
        link_adc0_ff21 <= 16'h0;
        link_adc0_ff22 <= 16'h0;
        link_adc0_ff23 <= 16'h0;
        link_adc0_ff24 <= 16'h0;
        link_adc0_ff25 <= 16'h0;
        link_adc0_ff26 <= 16'h0;
        link_adc0_ff27 <= 16'h0;
        link_adc0_ff28 <= 16'h0;
        link_adc0_ff29 <= 16'h0;
        link_adc0_ff30 <= 16'h0;
        link_adc0_ff31 <= 16'h0;
    end else begin
        link_adc0_ff0 <= link_adc0;
        link_adc0_ff1 <= link_adc0_ff0;
        link_adc0_ff2 <= link_adc0_ff1;
        link_adc0_ff3 <= link_adc0_ff2;
        link_adc0_ff4 <= link_adc0_ff3;
        link_adc0_ff5 <= link_adc0_ff4;
        link_adc0_ff6 <= link_adc0_ff5;
        link_adc0_ff7 <= link_adc0_ff6;
        link_adc0_ff8 <= link_adc0_ff7;
        link_adc0_ff9 <= link_adc0_ff8;
        link_adc0_ff10 <= link_adc0_ff9;
        link_adc0_ff11 <= link_adc0_ff10;
        link_adc0_ff12 <= link_adc0_ff11;
        link_adc0_ff13 <= link_adc0_ff12;
        link_adc0_ff14 <= link_adc0_ff13;
        link_adc0_ff15 <= link_adc0_ff14;
        link_adc0_ff16 <= link_adc0_ff15;
        link_adc0_ff17 <= link_adc0_ff16;
        link_adc0_ff18 <= link_adc0_ff17;
        link_adc0_ff19 <= link_adc0_ff18;
        link_adc0_ff20 <= link_adc0_ff19;
        link_adc0_ff21 <= link_adc0_ff20;
        link_adc0_ff22 <= link_adc0_ff21;
        link_adc0_ff23 <= link_adc0_ff22;
        link_adc0_ff24 <= link_adc0_ff23;
        link_adc0_ff25 <= link_adc0_ff24;
        link_adc0_ff26 <= link_adc0_ff25;
        link_adc0_ff27 <= link_adc0_ff26;
        link_adc0_ff28 <= link_adc0_ff27;
        link_adc0_ff29 <= link_adc0_ff28;
        link_adc0_ff30 <= link_adc0_ff29;
        link_adc0_ff31 <= link_adc0_ff30;
    end

always_ff @(posedge link_clk, negedge link_reset_n)
    if (!link_reset_n) begin
        link_adc1_ff0 <= 16'h0;
        link_adc1_ff1 <= 16'h0;
        link_adc1_ff2 <= 16'h0;
        link_adc1_ff3 <= 16'h0;
        link_adc1_ff4 <= 16'h0;
        link_adc1_ff5 <= 16'h0;
        link_adc1_ff6 <= 16'h0;
        link_adc1_ff7 <= 16'h0;
        link_adc1_ff8 <= 16'h0;
        link_adc1_ff9 <= 16'h0;
        link_adc1_ff10 <= 16'h0;
        link_adc1_ff11 <= 16'h0;
        link_adc1_ff12 <= 16'h0;
        link_adc1_ff13 <= 16'h0;
        link_adc1_ff14 <= 16'h0;
        link_adc1_ff15 <= 16'h0;
        link_adc1_ff16 <= 16'h0;
        link_adc1_ff17 <= 16'h0;
        link_adc1_ff18 <= 16'h0;
        link_adc1_ff19 <= 16'h0;
        link_adc1_ff20 <= 16'h0;
        link_adc1_ff21 <= 16'h0;
        link_adc1_ff22 <= 16'h0;
        link_adc1_ff23 <= 16'h0;
        link_adc1_ff24 <= 16'h0;
        link_adc1_ff25 <= 16'h0;
        link_adc1_ff26 <= 16'h0;
        link_adc1_ff27 <= 16'h0;
        link_adc1_ff28 <= 16'h0;
        link_adc1_ff29 <= 16'h0;
        link_adc1_ff30 <= 16'h0;
        link_adc1_ff31 <= 16'h0;
    end else begin
        link_adc1_ff0 <= link_adc1;
        link_adc1_ff1 <= link_adc1_ff0;
        link_adc1_ff2 <= link_adc1_ff1;
        link_adc1_ff3 <= link_adc1_ff2;
        link_adc1_ff4 <= link_adc1_ff3;
        link_adc1_ff5 <= link_adc1_ff4;
        link_adc1_ff6 <= link_adc1_ff5;
        link_adc1_ff7 <= link_adc1_ff6;
        link_adc1_ff8 <= link_adc1_ff7;
        link_adc1_ff9 <= link_adc1_ff8;
        link_adc1_ff10 <= link_adc1_ff9;
        link_adc1_ff11 <= link_adc1_ff10;
        link_adc1_ff12 <= link_adc1_ff11;
        link_adc1_ff13 <= link_adc1_ff12;
        link_adc1_ff14 <= link_adc1_ff13;
        link_adc1_ff15 <= link_adc1_ff14;
        link_adc1_ff16 <= link_adc1_ff15;
        link_adc1_ff17 <= link_adc1_ff16;
        link_adc1_ff18 <= link_adc1_ff17;
        link_adc1_ff19 <= link_adc1_ff18;
        link_adc1_ff20 <= link_adc1_ff19;
        link_adc1_ff21 <= link_adc1_ff20;
        link_adc1_ff22 <= link_adc1_ff21;
        link_adc1_ff23 <= link_adc1_ff22;
        link_adc1_ff24 <= link_adc1_ff23;
        link_adc1_ff25 <= link_adc1_ff24;
        link_adc1_ff26 <= link_adc1_ff25;
        link_adc1_ff27 <= link_adc1_ff26;
        link_adc1_ff28 <= link_adc1_ff27;
        link_adc1_ff29 <= link_adc1_ff28;
        link_adc1_ff30 <= link_adc1_ff29;
        link_adc1_ff31 <= link_adc1_ff30;
    end

always_ff @(posedge link_clk, negedge link_reset_n)
    if (!link_reset_n) begin
        link_adc2_ff0 <= 16'h0;
        link_adc2_ff1 <= 16'h0;
        link_adc2_ff2 <= 16'h0;
        link_adc2_ff3 <= 16'h0;
        link_adc2_ff4 <= 16'h0;
        link_adc2_ff5 <= 16'h0;
        link_adc2_ff6 <= 16'h0;
        link_adc2_ff7 <= 16'h0;
        link_adc2_ff8 <= 16'h0;
        link_adc2_ff9 <= 16'h0;
        link_adc2_ff10 <= 16'h0;
        link_adc2_ff11 <= 16'h0;
        link_adc2_ff12 <= 16'h0;
        link_adc2_ff13 <= 16'h0;
        link_adc2_ff14 <= 16'h0;
        link_adc2_ff15 <= 16'h0;
        link_adc2_ff16 <= 16'h0;
        link_adc2_ff17 <= 16'h0;
        link_adc2_ff18 <= 16'h0;
        link_adc2_ff19 <= 16'h0;
        link_adc2_ff20 <= 16'h0;
        link_adc2_ff21 <= 16'h0;
        link_adc2_ff22 <= 16'h0;
        link_adc2_ff23 <= 16'h0;
        link_adc2_ff24 <= 16'h0;
        link_adc2_ff25 <= 16'h0;
        link_adc2_ff26 <= 16'h0;
        link_adc2_ff27 <= 16'h0;
        link_adc2_ff28 <= 16'h0;
        link_adc2_ff29 <= 16'h0;
        link_adc2_ff30 <= 16'h0;
        link_adc2_ff31 <= 16'h0;
    end else begin
        link_adc2_ff0 <= link_adc2;
        link_adc2_ff1 <= link_adc2_ff0;
        link_adc2_ff2 <= link_adc2_ff1;
        link_adc2_ff3 <= link_adc2_ff2;
        link_adc2_ff4 <= link_adc2_ff3;
        link_adc2_ff5 <= link_adc2_ff4;
        link_adc2_ff6 <= link_adc2_ff5;
        link_adc2_ff7 <= link_adc2_ff6;
        link_adc2_ff8 <= link_adc2_ff7;
        link_adc2_ff9 <= link_adc2_ff8;
        link_adc2_ff10 <= link_adc2_ff9;
        link_adc2_ff11 <= link_adc2_ff10;
        link_adc2_ff12 <= link_adc2_ff11;
        link_adc2_ff13 <= link_adc2_ff12;
        link_adc2_ff14 <= link_adc2_ff13;
        link_adc2_ff15 <= link_adc2_ff14;
        link_adc2_ff16 <= link_adc2_ff15;
        link_adc2_ff17 <= link_adc2_ff16;
        link_adc2_ff18 <= link_adc2_ff17;
        link_adc2_ff19 <= link_adc2_ff18;
        link_adc2_ff20 <= link_adc2_ff19;
        link_adc2_ff21 <= link_adc2_ff20;
        link_adc2_ff22 <= link_adc2_ff21;
        link_adc2_ff23 <= link_adc2_ff22;
        link_adc2_ff24 <= link_adc2_ff23;
        link_adc2_ff25 <= link_adc2_ff24;
        link_adc2_ff26 <= link_adc2_ff25;
        link_adc2_ff27 <= link_adc2_ff26;
        link_adc2_ff28 <= link_adc2_ff27;
        link_adc2_ff29 <= link_adc2_ff28;
        link_adc2_ff30 <= link_adc2_ff29;
        link_adc2_ff31 <= link_adc2_ff30;
    end

always_ff @(posedge link_clk, negedge link_reset_n)
    if (!link_reset_n) begin
        link_adc3_ff0 <= 16'h0;
        link_adc3_ff1 <= 16'h0;
        link_adc3_ff2 <= 16'h0;
        link_adc3_ff3 <= 16'h0;
        link_adc3_ff4 <= 16'h0;
        link_adc3_ff5 <= 16'h0;
        link_adc3_ff6 <= 16'h0;
        link_adc3_ff7 <= 16'h0;
        link_adc3_ff8 <= 16'h0;
        link_adc3_ff9 <= 16'h0;
        link_adc3_ff10 <= 16'h0;
        link_adc3_ff11 <= 16'h0;
        link_adc3_ff12 <= 16'h0;
        link_adc3_ff13 <= 16'h0;
        link_adc3_ff14 <= 16'h0;
        link_adc3_ff15 <= 16'h0;
        link_adc3_ff16 <= 16'h0;
        link_adc3_ff17 <= 16'h0;
        link_adc3_ff18 <= 16'h0;
        link_adc3_ff19 <= 16'h0;
        link_adc3_ff20 <= 16'h0;
        link_adc3_ff21 <= 16'h0;
        link_adc3_ff22 <= 16'h0;
        link_adc3_ff23 <= 16'h0;
        link_adc3_ff24 <= 16'h0;
        link_adc3_ff25 <= 16'h0;
        link_adc3_ff26 <= 16'h0;
        link_adc3_ff27 <= 16'h0;
        link_adc3_ff28 <= 16'h0;
        link_adc3_ff29 <= 16'h0;
        link_adc3_ff30 <= 16'h0;
        link_adc3_ff31 <= 16'h0;
    end else begin
        link_adc3_ff0 <= link_adc3;
        link_adc3_ff1 <= link_adc3_ff0;
        link_adc3_ff2 <= link_adc3_ff1;
        link_adc3_ff3 <= link_adc3_ff2;
        link_adc3_ff4 <= link_adc3_ff3;
        link_adc3_ff5 <= link_adc3_ff4;
        link_adc3_ff6 <= link_adc3_ff5;
        link_adc3_ff7 <= link_adc3_ff6;
        link_adc3_ff8 <= link_adc3_ff7;
        link_adc3_ff9 <= link_adc3_ff8;
        link_adc3_ff10 <= link_adc3_ff9;
        link_adc3_ff11 <= link_adc3_ff10;
        link_adc3_ff12 <= link_adc3_ff11;
        link_adc3_ff13 <= link_adc3_ff12;
        link_adc3_ff14 <= link_adc3_ff13;
        link_adc3_ff15 <= link_adc3_ff14;
        link_adc3_ff16 <= link_adc3_ff15;
        link_adc3_ff17 <= link_adc3_ff16;
        link_adc3_ff18 <= link_adc3_ff17;
        link_adc3_ff19 <= link_adc3_ff18;
        link_adc3_ff20 <= link_adc3_ff19;
        link_adc3_ff21 <= link_adc3_ff20;
        link_adc3_ff22 <= link_adc3_ff21;
        link_adc3_ff23 <= link_adc3_ff22;
        link_adc3_ff24 <= link_adc3_ff23;
        link_adc3_ff25 <= link_adc3_ff24;
        link_adc3_ff26 <= link_adc3_ff25;
        link_adc3_ff27 <= link_adc3_ff26;
        link_adc3_ff28 <= link_adc3_ff27;
        link_adc3_ff29 <= link_adc3_ff28;
        link_adc3_ff30 <= link_adc3_ff29;
        link_adc3_ff31 <= link_adc3_ff30;
    end


endmodule


