// Copyright (c) 2019, Dmitry Shubin


module jesd204b_core
(
// сигнал сброса и синхронизации для контроллера сброса
    input         rst_ctl_clk,
    input         debug_clk,
    input         pll_locked,
// выводы протокола JESD204B
    input         link_clk,
    input         sysref,
    input         devclk,
    output        adc_sync_b,
    input         dac_sync_b,
    input           scrambler_is_on,
    output        phy_ready,
// serial data
    output        tx_serial_data0,
    output        tx_serial_data1,
    input         rx_serial_data0,
    input         rx_serial_data1,
// данные АЦП в частотном домене link_clk
    output [15:0] rx_data_0_i,
    output [15:0] rx_data_0_q,
    output [15:0] rx_data_1_i,
    output [15:0] rx_data_1_q,
// данные ЦАП в частотном домене link_clk
    input  [15:0] tx_data_0_i,
    input  [15:0] tx_data_0_q,
    input  [15:0] tx_data_1_i,
    input  [15:0] tx_data_1_q,
// loopback link layer
    output [35:0] bus_link_layer_tx0,
    output [35:0] bus_link_layer_tx1,
    input  [35:0] bus_link_layer_rx0,
    input  [35:0] bus_link_layer_rx1,
    input         loopback_link_layer,
// buffer
    output [9:0]  usedw0,
    output [9:0]  usedw1,
// link errors    
    output [31:0] err_link_rx0,
    output [31:0] err_link_rx1,
// отладочные вектора для логического анализатора
    output [67:0] tst,
    output [67:0] tst_core0,
    output [67:0] tst_core1,
    output [67:0] tst_wrapper0,
    output [67:0] tst_wrapper1,
    output [67:0] tst_fsm0,
    output [67:0] tst_fsm1,
    output [67:0] tst_fsm2,
    output [67:0] tst_fsm3,
    output [67:0] tst_prbs0,
    output [67:0] tst_prbs1,
    output [67:0] tst_data_st0,
    output [67:0] tst_data_st1,
    output [67:0] tst_data_st2,
    output [67:0] tst_tx_fsm0
);

wire reset_b;
wire rx_ready[8:0];
wire tx_ready[3:0];
wire pattern_align_en[8:0];
wire adcs_sync_b[8:0];
wire rst_ctl_reset;
wire debug_reset_b;


/////////////// latch by link_clk /////////////////////////////
wire sysref_sync;
wire sync_b_sync;
jesd204b_rx_sync jesd204b_rx_sync_inst
(
    .reset_b    (reset_b),
    .clk        (link_clk),
    .sync_b_i   (dac_sync_b),
    .sync_b_o   (sync_b_sync),
    .sysref_i   (sysref),
    .sysref_o   (sysref_sync)
);
////////////////////////////////////////////////////////////////


////////////// TX Link layer /////////////////////////////////////////
wire [31:0] tx_parallel_data0;
wire [31:0] tx_parallel_data1;
wire [3:0]  tx_datak0;
wire [3:0]  tx_datak1;
wire [7:0] state_out0;
wire [7:0] state_out1;

jesd204b_tx_link_layer  jesd204b_tx_link_layer_inst0
(
    .reset_b         (reset_b),
    .clk             (link_clk),
    .sysref          (sysref_sync),
    .sync_b          (sync_b_sync),
    .tx_data_i       (tx_data_0_i),
    .tx_data_q       (tx_data_0_q),
    .scrambler_is_on (scrambler_is_on),
    .tx_par_data     (tx_parallel_data0),
    .tx_datak        (tx_datak0),
    .state_out       (state_out0)
);

jesd204b_tx_link_layer  jesd204b_tx_link_layer_inst1
(
    .reset_b         (reset_b),
    .clk             (link_clk),
    .sysref          (sysref_sync),
    .sync_b          (sync_b_sync),
    .tx_data_i       (tx_data_1_i),
    .tx_data_q       (tx_data_1_q),
    .scrambler_is_on (scrambler_is_on),
    .tx_par_data     (tx_parallel_data1),
    .tx_datak        (tx_datak1),
    .state_out       (state_out1)
);
///////////////////////////////////////////////////////////////    



//////////////// RX link Layer //////////////////////////////////////////
reg [31:0] rx_data0;
reg [3:0]  rx_ak0;
reg [31:0] rx_data1;
reg [3:0]  rx_ak1;

assign adc_sync_b = adcs_sync_b[0];

jesd204b_rx jesd204b_rx_inst0
(
    .reset_b            (reset_b            ),
    .clk                (link_clk           ),
    .sysref             (sysref_sync        ),
    .adc_sync_b         (adcs_sync_b[0]     ),
    .scrambler_is_on    (scrambler_is_on    ),
    .rx_parallel_data   (rx_data0           ),
    .rx_datak           (rx_ak0             ),
    .rx_data_i          (rx_data_0_i        ),
    .rx_data_q          (rx_data_0_q        ),
    .pattern_align_en   (pattern_align_en[0]),
    .usedw              (usedw0),
    .err_link_rx        (err_link_rx0),
    .tst                (tst_core0)
);

jesd204b_rx jesd204b_rx_inst1
(
    .reset_b            (reset_b            ),
    .clk                (link_clk           ),
    .sysref             (sysref_sync        ),
    .adc_sync_b         (adcs_sync_b[1]     ),
    .scrambler_is_on    (scrambler_is_on    ),
    .rx_parallel_data   (rx_data1           ),
    .rx_datak           (rx_ak1             ),
    .rx_data_i          (rx_data_1_i        ),
    .rx_data_q          (rx_data_1_q        ),
    .pattern_align_en   (pattern_align_en[1]),
    .err_link_rx        (err_link_rx1),
    .usedw              (usedw1)
);
//////////////////////////////////////////////////////////////////////////


////////////////////// PHY ///////////////////////////////////////////////
wire [31:0] rx_parallel_data0;
wire [31:0] rx_parallel_data1;
wire [3:0] rx_datak0;
wire [3:0] rx_datak1;
wire [3:0] rx_patterndetect0;
wire [3:0] rx_patterndetect1;
jesd204b_phy_wrapper jesd204b_phy_wrapper_inst
(
    // сигнал сброса и синхронизации для контроллера сброса
    .rst_ctl_reset              (rst_ctl_reset),
    .rst_ctl_clk                (rst_ctl_clk),
    // сигналы синхронизации для PHY
    .ext_pll_refclk             (devclk),
    .rx_cdr_refclk              (devclk),
    .pll_locked                 (pll_locked),
    // параллельные данные и их сигналы синхронизации
    .tx_parallel_d0             (tx_parallel_data0),
    .tx_parallel_d1             (tx_parallel_data1),
    .rx_parallel_d0             (rx_parallel_data0),
    .rx_parallel_d1             (rx_parallel_data1),
    .parallel_clk               (link_clk),
    // контрольные выводы PHY
    .tx_ready0                  (tx_ready[0]),
    .tx_d_k0                    (tx_datak0),
    .tx_ready1                  (tx_ready[1]),
    .tx_d_k1                    (tx_datak1),
    .rx_ready0                  (rx_ready[0]),
    .rx_d_k0                    (rx_datak0),
    .rx_patterndetect0          (rx_patterndetect0),
    .rx_std_wa_patternalign0    (pattern_align_en0),
    .rx_ready1                  (rx_ready[1]),
    .rx_d_k1                    (rx_datak1),
    .rx_patterndetect1          (rx_patterndetect1),
    .rx_std_wa_patternalign1    (pattern_align_en1),
    .reconfig_busy              (),
    // последовательные данные
    .tx_serial_data0            (tx_serial_data0),
    .tx_serial_data1            (tx_serial_data1),
    .rx_serial_data0            (rx_serial_data0),
    .rx_serial_data1            (rx_serial_data1),
    .tst_wrapper0               (tst_wrapper0),
    .tst_wrapper1               (tst_wrapper1)
);
//////////////////////////////////////////////////////////////////////////



//////////// loopback ////////////////////////////////////////////////
always @ (posedge link_clk, negedge reset_b)
    if(~reset_b) begin
        {rx_data0, rx_ak0} <= 36'd0;
        {rx_data1, rx_ak1} <= 36'd0;
    end else begin
        if (loopback_link_layer) begin
            {rx_data0, rx_ak0} <= bus_link_layer_rx0;    
            {rx_data1, rx_ak1} <= bus_link_layer_rx1;
        end else begin
            {rx_data0, rx_ak0} <= {rx_parallel_data0, rx_datak0};
            {rx_data1, rx_ak1} <= {rx_parallel_data1, rx_datak1};
        end
    end

assign  bus_link_layer_tx0 = {tx_parallel_data0, tx_datak0};
assign  bus_link_layer_tx1 = {tx_parallel_data1, tx_datak1};
/////////////////////////////////////////////////////////////////////////    
    
    
    


////////////// PHY ready //////////////////////////////////////////////////////
jesd204b_rst_ctl jesd204b_rst_ctl_inst
(
    .pll_locked    (pll_locked),
    .rst_ctl_clk   (rst_ctl_clk),
    .rst_ctl_reset (rst_ctl_reset),
    .debug_clk     (debug_clk),
    .debug_reset_b (debug_reset_b),
    .tx_en0        (tx_ready[0]),
    .tx_en1        (tx_ready[1]),
    .rx_en0        (rx_ready[0]),
    .rx_en1        (rx_ready[1]),
    .link_clk      (link_clk),
    .reset_b       (reset_b)
);  

////////////// PHY ready to SOFTWARE /////////////////////////////////////////
wire phy_ready_ena = tx_ready[0] & tx_ready[1] & rx_ready[0] & rx_ready[1];
reg [23:0] cnt_phy_ready;
always @(posedge rst_ctl_clk, negedge pll_locked)
    if (~pll_locked) begin
        cnt_phy_ready <= 24'd0;
    end else begin
        if (phy_ready_ena)
            cnt_phy_ready <= cnt_phy_ready + ~&cnt_phy_ready;        
        else
            cnt_phy_ready <= 24'd0;
    end
assign phy_ready = &cnt_phy_ready;
//////////////////////////////////////////////////////////////////////////////    


assign tst={
    rst_ctl_clk,
    debug_clk,
    debug_reset_b,
    rst_ctl_reset,
    pll_locked,
    link_clk,
    sysref,
    devclk,
    reset_b,
    tx_ready[0],
    tx_ready[1],
    rx_ready[0],
    phy_ready,
    dac_sync_b,
    sync_b_sync,
    sysref,
    sysref_sync,
    adc_sync_b,
    tst_wrapper0[54],
    tst_wrapper0[53],
    state_out0[7:0],
    usedw0[9:0],
    usedw1[9:0],
    20'd0
};

endmodule