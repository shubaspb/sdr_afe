
module jesd204b_rx
(
    input           reset_b,
    input           clk,
    input           sysref,
    output          adc_sync_b,
    input           scrambler_is_on,
    input   [31:0]  rx_parallel_data,
    input   [3:0]   rx_datak,
    output  [15:0]  rx_data_i,
    output  [15:0]  rx_data_q,
    output          pattern_align_en,
    output  [9:0]   usedw,
    output  [31:0]  err_link_rx,
    output  [67:0]  tst
);


////////////// Link Layer /////////////////////////////////////
wire [15:0] link_adc0;
wire [15:0] link_adc1;
wire        data_ready;

jesd204b_rx_link_layer jesd204b_rx_link_layer_inst0
(
    .reset_b                (reset_b),
    .clk                    (clk),
    .rx_parallel_data       (rx_parallel_data),
    .rx_datak               (rx_datak),
    .sysref                 (sysref),
    .sync_b                 (adc_sync_b),
    .pattern_align_en       (pattern_align_en),
    .adc_data0              (link_adc0),
    .adc_data1              (link_adc1),
    .data_ready             (data_ready),
    .scrambler_is_on        (scrambler_is_on),
    .err_link_rx            (err_link_rx),
    .tst                    (tst)
);


///////////////// elastic buffer ///////////////////////////////
wire [31:0] data_in_buf = {link_adc0, link_adc1};
wire [31:0] data_out_buf;    
elastic_buffer elastic_buffer_inst (
    .reset_b    (reset_b        ),
    .clk        (clk            ),
    .data_ready (data_ready     ),
    .sysref     (sysref         ),
    .data_in    (data_in_buf    ),
    .data_out   (data_out_buf   ),
    .usedw      (usedw          )
);
assign {rx_data_i, rx_data_q} = data_out_buf;


/* assign tst = {
    clk,
    reset_b,
    sysref, 
    adc_sync_b,
    rx_parallel_data[15:0],
    link_adc0[15:0],
    rx_data_i[15:0],
    rx_datak[3:0],
    data_ready,
    data_ready,
    usedw[9:0]
    }; */


endmodule