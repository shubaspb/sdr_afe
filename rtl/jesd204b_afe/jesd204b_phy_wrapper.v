/*
    Название проекта    : tcas_bsps
    Название файла      : gxb_phy_wrapper.v
    Назначение          : Оберточный-модуль физического уровня протокола JESD204B.
    Автор               : Александрович Ф.А.
    Дата создания       : 2018.10.22
    Синтаксис           : IEEE 1364-2001 (Verilog HDL 2001)
    Комментарии         :
*/


`timescale 1ns / 1ns


module jesd204b_phy_wrapper
(
    // сигнал сброса и синхронизации для контроллера сброса
    input         rst_ctl_reset,
    input         rst_ctl_clk,

    // сигналы синхронизации для PHY
    input         tx_pll_refclk,
    input         rx_cdr_refclk,

    // параллельные данные, сигналы синхронизации и признаки служебных данных
    input         link_clk,

    output  [3:0] tx_ready,
    output  [8:0] rx_ready,

    input  [31:0] tx_parallel_data_0,
    input  [31:0] tx_parallel_data_1,
    input  [31:0] tx_parallel_data_2,
    input  [31:0] tx_parallel_data_3,

    input   [3:0] tx_datak_0,
    input   [3:0] tx_datak_1,
    input   [3:0] tx_datak_2,
    input   [3:0] tx_datak_3,

    output [31:0] rx_parallel_data_0,
    output [31:0] rx_parallel_data_1,
    output [31:0] rx_parallel_data_2,
    output [31:0] rx_parallel_data_3,
    output [31:0] rx_parallel_data_4,
    output [31:0] rx_parallel_data_5,
    output [31:0] rx_parallel_data_6,
    output [31:0] rx_parallel_data_7,
    output [31:0] rx_parallel_data_8,

    output  [3:0] rx_datak_0,
    output  [3:0] rx_datak_1,
    output  [3:0] rx_datak_2,
    output  [3:0] rx_datak_3,
    output  [3:0] rx_datak_4,
    output  [3:0] rx_datak_5,
    output  [3:0] rx_datak_6,
    output  [3:0] rx_datak_7,
    output  [3:0] rx_datak_8,

    // последовательные данные
    output  [3:0] tx_serial_data,
    input   [8:0] rx_serial_data,

    output [67:0] tst_wrapper0,
    output [67:0] tst_wrapper1,
    output [67:0] tst_wrapper2,
    output [67:0] tst_wrapper3,
    output [67:0] tst_wrapper4,
    output [67:0] tst_wrapper5,
    output [67:0] tst_wrapper6
);


wire [3:0] tx_digitalreset;
wire [3:0] tx_analogreset;
wire [8:0] rx_digitalreset;
wire [8:0] rx_analogreset;
wire [3:0] tx_cal_busy;
wire [8:0] rx_cal_busy;
wire [8:0] rx_is_lockedtodata_wire;
wire [8:0] rx_is_lockedtoref_wire;

wire [1:0] pll_select;

// сигналы для SerDes различных банков
wire [31:0] tx_parallel_data_wire[3:0];
wire  [3:0] tx_datak_wire[3:0];

wire [31:0] rx_parallel_data_wire[8:0];
wire  [3:0] rx_datak_wire[8:0];

wire tx_pll_clk0;
wire tx_pll_clk1;
wire tx_pll_clk2;

wire [2:0] tx_pll_locked;
wire [2:0] pll_powerdown;


assign pll_select = 2'd1;


gxb_phy_reset_ctl gxb_phy_reset_ctl_inst
(
    // сигналы сброса и синхронизации контроллера
    .reset                  (rst_ctl_reset),
    .clock                  (rst_ctl_clk),

    // управление GXB
    .tx_digitalreset        (tx_digitalreset),
    .tx_analogreset         (tx_analogreset),
    .rx_digitalreset        (rx_digitalreset),
    .rx_analogreset         (rx_analogreset),

    // статусы от GXB
    .pll_powerdown          (pll_powerdown),
    .pll_locked             (tx_pll_locked),
    .tx_cal_busy            ({5'd0, tx_cal_busy}),
    .rx_cal_busy            (rx_cal_busy),
    .pll_select             (pll_select),
    .tx_ready               (tx_ready),
    .rx_ready               (rx_ready),
    .rx_is_lockedtodata     (rx_is_lockedtodata_wire)
);

jesd204b_tx_pll jesd204b_tx_pll_inst0
(
    .pll_powerdown       (pll_powerdown[0]),
    .pll_refclk          (tx_pll_refclk),

    .pll_clkout          (tx_pll_clk0),
    .pll_locked          (tx_pll_locked[0]),

    .pll_fbclk           (),
    .fboutclk            (),
    .hclk                (),

    .reconfig_to_xcvr    (),
    .reconfig_from_xcvr  ()
);

// SDR1
jesd204b_tx_phy jesd204b_tx_phy_inst0
(
    .ext_pll_clk                (tx_pll_clk0),
    .tx_std_clkout              (),
    .tx_std_coreclkin           (link_clk),

    .pll_powerdown              (1'b0),
    .tx_analogreset             (tx_analogreset[0]),
    .tx_digitalreset            (tx_digitalreset[0]),

    .tx_parallel_data           (tx_parallel_data_0),
    .tx_datak                   (tx_datak_0),
    .unused_tx_parallel_data    (),

    .tx_serial_data             (tx_serial_data[0]),

    .tx_cal_busy                (tx_cal_busy[0]),
    .reconfig_to_xcvr           (),
    .reconfig_from_xcvr         ()
);

// SDR2
jesd204b_tx_phy jesd204b_tx_phy_inst1
(
    .ext_pll_clk                (tx_pll_clk0),
    .tx_std_clkout              (),
    .tx_std_coreclkin           (link_clk),

    .pll_powerdown              (1'b0),
    .tx_analogreset             (tx_analogreset[1]),
    .tx_digitalreset            (tx_digitalreset[1]),

    .tx_parallel_data           (tx_parallel_data_1),
    .tx_datak                   (tx_datak_1),
    .unused_tx_parallel_data    (),

    .tx_serial_data             (tx_serial_data[1]),

    .tx_cal_busy                (tx_cal_busy[1]),
    .reconfig_to_xcvr           (),
    .reconfig_from_xcvr         ()
);

jesd204b_tx_pll jesd204b_tx_pll_inst1
(
    .pll_powerdown       (pll_powerdown[1]),
    .pll_refclk          (tx_pll_refclk),

    .pll_clkout          (tx_pll_clk1),
    .pll_locked          (tx_pll_locked[1]),

    .pll_fbclk           (),
    .fboutclk            (),
    .hclk                (),

    .reconfig_to_xcvr    (),
    .reconfig_from_xcvr  ()
);

// SDR3
jesd204b_tx_phy jesd204b_tx_phy_inst2
(
    .ext_pll_clk                (tx_pll_clk1),
    .tx_std_clkout              (),
    .tx_std_coreclkin           (link_clk),

    .pll_powerdown              (1'b0),
    .tx_analogreset             (tx_analogreset[2]),
    .tx_digitalreset            (tx_digitalreset[2]),

    .tx_parallel_data           (tx_parallel_data_2),
    .tx_datak                   (tx_datak_2),
    .unused_tx_parallel_data    (),

    .tx_serial_data             (tx_serial_data[2]),

    .tx_cal_busy                (tx_cal_busy[2]),
    .reconfig_to_xcvr           (),
    .reconfig_from_xcvr         ()
);

jesd204b_tx_pll jesd204b_tx_pll_inst2
(
    .pll_powerdown       (pll_powerdown[2]),
    .pll_refclk          (tx_pll_refclk),

    .pll_clkout          (tx_pll_clk2),
    .pll_locked          (tx_pll_locked[2]),

    .pll_fbclk           (),
    .fboutclk            (),
    .hclk                (),

    .reconfig_to_xcvr    (),
    .reconfig_from_xcvr  ()
);

// SDR4
jesd204b_tx_phy jesd204b_tx_phy_inst3
(
    .ext_pll_clk                (tx_pll_clk2),
    .tx_std_clkout              (),
    .tx_std_coreclkin           (link_clk),

    .pll_powerdown              (1'b0),
    .tx_analogreset             (tx_analogreset[3]),
    .tx_digitalreset            (tx_digitalreset[3]),

    .tx_parallel_data           (tx_parallel_data_3),
    .tx_datak                   (tx_datak_3),
    .unused_tx_parallel_data    (),

    .tx_serial_data             (tx_serial_data[3]),

    .tx_cal_busy                (tx_cal_busy[3]),
    .reconfig_to_xcvr           (),
    .reconfig_from_xcvr         ()
);


assign rx_parallel_data_8 = rx_parallel_data_wire[8];
assign rx_parallel_data_7 = rx_parallel_data_wire[7];
assign rx_parallel_data_6 = rx_parallel_data_wire[6];
assign rx_parallel_data_5 = rx_parallel_data_wire[5];
assign rx_parallel_data_4 = rx_parallel_data_wire[4];
assign rx_parallel_data_3 = rx_parallel_data_wire[3];
assign rx_parallel_data_2 = rx_parallel_data_wire[2];
assign rx_parallel_data_1 = rx_parallel_data_wire[1];
assign rx_parallel_data_0 = rx_parallel_data_wire[0];

assign rx_datak_8 = rx_datak_wire[8];
assign rx_datak_7 = rx_datak_wire[7];
assign rx_datak_6 = rx_datak_wire[6];
assign rx_datak_5 = rx_datak_wire[5];
assign rx_datak_4 = rx_datak_wire[4];
assign rx_datak_3 = rx_datak_wire[3];
assign rx_datak_2 = rx_datak_wire[2];
assign rx_datak_1 = rx_datak_wire[1];
assign rx_datak_0 = rx_datak_wire[0];


genvar i;


generate for (i = 0; i < 9; i = i + 1) begin : rx_phy_seq
jesd204b_rx_phy jesd204b_rx_phy_inst0
(
    // входные/выходные сигналы тактирования
    .rx_cdr_refclk              (rx_cdr_refclk),
    .rx_std_clkout              (),
    .rx_std_coreclkin           (link_clk),

    // сигналы сброса
    .rx_analogreset             (rx_analogreset[i]),
    .rx_digitalreset            (rx_digitalreset[i]),

    // параллельные данные
    .rx_parallel_data           (rx_parallel_data_wire[i]),
    .unused_rx_parallel_data    (),

    // последовательные данные
    .rx_serial_data             (rx_serial_data[i]),

    // контрольно-статусные данные
    .rx_is_lockedtodata         (rx_is_lockedtodata_wire[i]),
    .rx_is_lockedtoref          (rx_is_lockedtoref_wire[i]),
    .rx_datak                   (rx_datak_wire[i]),
    .rx_errdetect               (),
    .rx_disperr                 (),
    .rx_runningdisp             (),
    .rx_patterndetect           (),
    .rx_syncstatus              (),

    // рекофигурационный интерфейс
    .reconfig_to_xcvr           (),
    .reconfig_from_xcvr         (),
    .rx_cal_busy                (rx_cal_busy[i])
);
end endgenerate


assign tst_wrapper0 =
{
    rx_ready[8:0],
    tx_ready[3:0],
    tx_pll_locked[2:0],
    pll_powerdown[2:0],
    tx_pll_refclk,
    link_clk,
    rst_ctl_clk,
    rst_ctl_reset
};

assign tst_wrapper2 =
{
    link_clk,
    link_clk,
    8'd0,
    tx_digitalreset[3:0],
    tx_analogreset[3:0],
    rx_digitalreset[8:0],
    rx_analogreset[8:0],
    tx_cal_busy[3:0],
    rx_cal_busy[8:0],
    rx_is_lockedtodata_wire[8:0],
    rx_is_lockedtoref_wire[8:0],
    1'b0
};

assign tst_wrapper3 =
{
    link_clk,
    3'd0,
    rx_parallel_data_0[31:0],
    rx_parallel_data_1[31:0]
};


endmodule