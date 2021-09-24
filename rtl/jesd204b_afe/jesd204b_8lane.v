//
//    Название проекта    : ad9371_jesd204b_debug
//    Название файла      : jesd204b_tcas.v
//    Назначение          : Головной модуль протокола JESD204B для проекта TCAS.
//    Автор               : Шубин Д.А.
//    Дата создания       : 2018.10.22
//    Синтаксис           : IEEE 1364-2001 (Verilog HDL 2001)
//    Комментарии         :
//---------------------------------------------------------------------------------------------------------------------
//    Состояние модуля    : [ ] проведена проверка синтаксиса (modelsim)
//                          [ ] синтезируется без серьезных предупреждений
//                          [ ] проведена функциональная проверка (функциональное моделирование) (modelsim)
//                          [ ] проведена проверка в целевом проекте
//---------------------------------------------------------------------------------------------------------------------



`timescale 1ns / 1ns

module jesd204b_8lane
(
// сигнал сброса и синхронизации для контроллера сброса
    input         rst_ctl_clk,
    input         pll_locked,
// выводы протокола JESD204B
    output        link_clk_out,
    input         sysref,
    input         devclk,
    output        adc_sync_b,
    input         dac_sync_b,
	input 		  scrambler_is_on,	
	output        phy_ready,
// serial data
    input 	[7:0]	rxn_in,
    input 	[7:0]	rxp_in,
    output 	[7:0]	txn_out,
    output 	[7:0]	txp_out,
// RX
    output [15:0] rx_data_0_i,
    output [15:0] rx_data_0_q,
    output [15:0] rx_data_1_i,
    output [15:0] rx_data_1_q,
    output [15:0] rx_data_2_i,
    output [15:0] rx_data_2_q,
    output [15:0] rx_data_3_i,
    output [15:0] rx_data_3_q,	
// ORX
    output [15:0] orx_data_0_i,
    output [15:0] orx_data_0_q,
    output [15:0] orx_data_1_i,
    output [15:0] orx_data_1_q,
// TX
    input  [15:0] tx_data_0_i,
    input  [15:0] tx_data_0_q,
    input  [15:0] tx_data_1_i,
    input  [15:0] tx_data_1_q,
    input  [15:0] tx_data_2_i,
    input  [15:0] tx_data_2_q,
    input  [15:0] tx_data_3_i,
    input  [15:0] tx_data_3_q,
// buffer
    input [3:0]   rx_channel,
	output reg [9:0]  usedw,		
	output reg [31:0]  err_link_rx,
	output [67:0] tst,
	output [67:0] tst1,
	output [67:0] tst2
);


	wire reset_b = pll_locked;
	wire [3:0] rx_ready;
	wire [3:0] tx_ready;
	wire [7:0] pattern_align_en;
	wire rst_ctl_reset;
	wire debug_reset_b;
	wire reset_b_0;
	wire reset_b_1;
	wire reset_b_2;
	wire reset_b_3;

/////////////// latch by link_clk /////////////////////////////
	wire sysref_sync;
	wire [3:0] sync_b_i = {(4){dac_sync_b}};
	wire [3:0] sync_b_sync;
	jesd204b_rx_sync jesd204b_rx_sync_inst
	(
		.reset_b    (reset_b),
		.clk        (link_clk),

		.sync_b_i   (sync_b_i),
		.sync_b_o   (sync_b_sync),

		.sysref_i   (sysref),
		.sysref_o   (sysref_sync)
	);
////////////////////////////////////////////////////////////////



////////////// TX Link layer /////////////////////////////////////////
	wire [31:0] tx_parallel_data0;
	wire [31:0] tx_parallel_data1;
	wire [31:0] tx_parallel_data2;
	wire [31:0] tx_parallel_data3;
	
	wire [3:0]  tx_datak0;
	wire [3:0]  tx_datak1;	
	wire [3:0]  tx_datak2;
	wire [3:0]  tx_datak3;		
	
	wire [7:0] state_out0;
	wire [7:0] state_out1;
	
	jesd204b_tx_link_layer  jesd204b_tx_link_layer_inst0
	(
		.reset_b         (reset_b_0),
		.clk             (link_clk),
		.sysref          (sysref_sync),
		.sync_b          (sync_b_sync[0]),
		.tx_data_i       (tx_data_0_i),
		.tx_data_q       (tx_data_0_q),
		.scrambler_is_on (scrambler_is_on),
		.tx_par_data     (tx_parallel_data0),
		.tx_datak        (tx_datak0),
		.state_out       (state_out0),
		.tst             (tst)
	);

	jesd204b_tx_link_layer  jesd204b_tx_link_layer_inst1
	(
		.reset_b         (reset_b_0),
		.clk             (link_clk),
		.sysref          (sysref_sync),
		.sync_b          (sync_b_sync[0]),
		.tx_data_i     	 (tx_data_1_i),
		.tx_data_q     	 (tx_data_1_q),
		.scrambler_is_on (scrambler_is_on),
		.tx_par_data     (tx_parallel_data1),
		.tx_datak        (tx_datak1),
		.state_out       (state_out1)
	);
	
	jesd204b_tx_link_layer  jesd204b_tx_link_layer_inst2
	(
		.reset_b         (reset_b_0),
		.clk             (link_clk),
		.sysref          (sysref_sync),
		.sync_b          (sync_b_sync[0]),
		.tx_data_i     	 (tx_data_2_i),
		.tx_data_q     	 (tx_data_2_q),
		.scrambler_is_on (scrambler_is_on),
		.tx_par_data     (tx_parallel_data2),
		.tx_datak        (tx_datak2),
		.state_out       ()
	);	
	
	jesd204b_tx_link_layer  jesd204b_tx_link_layer_inst3
	(
		.reset_b         (reset_b_0),
		.clk             (link_clk),
		.sysref          (sysref_sync),
		.sync_b          (sync_b_sync[0]),
		.tx_data_i     	 (tx_data_3_i),
		.tx_data_q     	 (tx_data_3_q),
		.scrambler_is_on (scrambler_is_on),
		.tx_par_data     (tx_parallel_data3),
		.tx_datak        (tx_datak3),
		.state_out       ()
	);	
///////////////////////////////////////////////////////////////	



//////////////// RX link Layer //////////////////////////////////////////

	/////////////// link control //////////////////////////////////
	wire [9:0] usedw0;
	wire [9:0] usedw1;
	wire [9:0] usedw2;
	wire [9:0] usedw3;

	
	wire [31:0] err_link_rx0;
	wire [31:0] err_link_rx1;
	wire [31:0] err_link_rx2;
	wire [31:0] err_link_rx3;


	always @(posedge link_clk, negedge reset_b)
	if (~reset_b) begin
		{usedw, err_link_rx} <= {10'd0, 32'd0};
	end else begin
		case (rx_channel)
        4'd1    : {usedw, err_link_rx} <= {usedw0, err_link_rx0};
        4'd2    : {usedw, err_link_rx} <= {usedw1, err_link_rx1};
        4'd3    : {usedw, err_link_rx} <= {usedw2, err_link_rx2};
        4'd4    : {usedw, err_link_rx} <= {usedw3, err_link_rx3};
        default : {usedw, err_link_rx} <= {10'd0, 32'd0};
		endcase
	end
	////////////////////////////////////////////////////////////////



	wire [31:0] rx_parallel_data0;
	wire [31:0] rx_parallel_data1;
	wire [31:0] rx_parallel_data2;
	wire [31:0] rx_parallel_data3;
	wire [3:0] rx_datak0;
	wire [3:0] rx_datak1;
	wire [3:0] rx_datak2;
	wire [3:0] rx_datak3;	

	wire [7:0] adc_sync_b_rx;
	
	assign adc_sync_b = adc_sync_b_rx[0] & adc_sync_b_rx[1] & adc_sync_b_rx[2] & adc_sync_b_rx[3];// & adc_sync_b_rx[4] & adc_sync_b_rx[5];		

	jesd204b_rx jesd204b_rx_inst0
	(
		.reset_b			(reset_b_0			),
		.clk				(link_clk			),
		.sysref				(sysref_sync		),
		.adc_sync_b			(adc_sync_b_rx[0]	),
		.scrambler_is_on	(scrambler_is_on	),
		.rx_parallel_data	(rx_parallel_data0	),
		.rx_datak			(rx_datak0			),
		.rx_data_i			(rx_data_0_i		),
		.rx_data_q			(rx_data_0_q		),
		.pattern_align_en   (pattern_align_en[0]),
		.usedw 				(usedw0),
		.err_link_rx 		(err_link_rx0)
	);

	jesd204b_rx jesd204b_rx_inst1
	(
		.reset_b			(reset_b_0			),
		.clk				(link_clk			),
		.sysref				(sysref_sync		),
		.adc_sync_b			(adc_sync_b_rx[1]	),
		.scrambler_is_on	(scrambler_is_on    ),
		.rx_parallel_data	(rx_parallel_data1	),
		.rx_datak			(rx_datak1			),
		.rx_data_i			(rx_data_1_i   		),
		.rx_data_q			(rx_data_1_q   		),
		.pattern_align_en   (pattern_align_en[1]),
		.usedw 				(usedw1),
		.err_link_rx 		(err_link_rx1)
	);

	jesd204b_rx jesd204b_rx_inst2
	(
		.reset_b			(reset_b_0			),
		.clk				(link_clk			),
		.sysref				(sysref_sync		),
		.adc_sync_b			(adc_sync_b_rx[2]	),
		.scrambler_is_on	(scrambler_is_on	),
		.rx_parallel_data	(rx_parallel_data2	),
		.rx_datak			(rx_datak2			),
		.rx_data_i			(rx_data_2_i		),
		.rx_data_q			(rx_data_2_q		),
		.pattern_align_en   (pattern_align_en[2]),
		.usedw 				(usedw2),
		.err_link_rx 		(err_link_rx2)
	);

	jesd204b_rx jesd204b_rx_inst3
	(
		.reset_b			(reset_b_0			),
		.clk				(link_clk			),
		.sysref				(sysref_sync		),
		.adc_sync_b			(adc_sync_b_rx[3]	),
		.scrambler_is_on	(scrambler_is_on    ),
		.rx_parallel_data	(rx_parallel_data3	),
		.rx_datak			(rx_datak3			),
		.rx_data_i			(rx_data_3_i   		),
		.rx_data_q			(rx_data_3_q   		),
		.pattern_align_en   (pattern_align_en[3]),
		.usedw 				(usedw3),
		.err_link_rx 		(err_link_rx3)
	);
//////////////////////////////////////////////////////////////////////////



/////////////////////// ORX ////////////////////////////////////////////////
	jesd204b_rx jesd204b_rx_inst4
	(
		.reset_b			(reset_b_0			),
		.clk				(link_clk			),
		.sysref				(sysref_sync		),
		.adc_sync_b			(adc_sync_b_rx[4]	),
		.scrambler_is_on	(scrambler_is_on	),
		.rx_parallel_data	(rx_parallel_data4	),
		.rx_datak			(rx_datak4			),
		.rx_data_i			(orx_data_0_i		),
		.rx_data_q			(orx_data_0_q		),
		.pattern_align_en   (pattern_align_en[4]),
		.usedw 				(),
		.err_link_rx 		(),
		.tst()
	);
	
	jesd204b_rx jesd204b_rx_inst5
	(
		.reset_b			(reset_b_0			),
		.clk				(link_clk			),
		.sysref				(sysref_sync		),
		.adc_sync_b			(adc_sync_b_rx[5]	),
		.scrambler_is_on	(scrambler_is_on	),
		.rx_parallel_data	(rx_parallel_data5	),
		.rx_datak			(rx_datak5			),
		.rx_data_i			(		),
		.rx_data_q			(		),
		.pattern_align_en   (pattern_align_en[5]),
		.usedw 				(),
		.err_link_rx 		(),
		.tst()
	);
	
	jesd204b_rx jesd204b_rx_inst6
	(
		.reset_b			(reset_b_0			),
		.clk				(link_clk			),
		.sysref				(sysref_sync		),
		.adc_sync_b			(adc_sync_b_rx[6]	),
		.scrambler_is_on	(scrambler_is_on	),
		.rx_parallel_data	(rx_parallel_data6	),
		.rx_datak			(rx_datak6			),
		.rx_data_i			(orx_data_1_i		),
		.rx_data_q			(orx_data_1_q		),
		.pattern_align_en   (pattern_align_en[6]),
		.usedw 				(),
		.err_link_rx 		(),
		.tst(tst2)
	);
	
	jesd204b_rx jesd204b_rx_inst7
	(
		.reset_b			(reset_b_0			),
		.clk				(link_clk			),
		.sysref				(sysref_sync		),
		.adc_sync_b			(adc_sync_b_rx[7]	),
		.scrambler_is_on	(scrambler_is_on	),
		.rx_parallel_data	(rx_parallel_data7	),
		.rx_datak			(rx_datak7			),
		.rx_data_i			(		),
		.rx_data_q			(		),
		.pattern_align_en   (pattern_align_en[7]),
		.usedw 				(),
		.err_link_rx 		(),
		.tst()
	);
///////////////////////////////////////////////////////////////////////////////




/////////////////////// PHY /////////////////////////////////////////////////////////

	////////////////// reset phy //////////////////
	reg [31:0] cnt_rp;
	wire reset_phy_b = pll_locked & gt_powergood; 
	always @(posedge rst_ctl_clk, negedge reset_phy_b)
        if (~reset_phy_b) begin
            cnt_rp <= 32'd0;
        end else begin
		    cnt_rp <= cnt_rp + ~&cnt_rp; //32'd1; //			
        end

	reg gt_sys_reset;	
	reg gt_data_reset;	
	always @(posedge rst_ctl_clk, negedge pll_locked)
        if (~pll_locked) begin
			gt_sys_reset  <= 1'b0;	
			gt_data_reset <= 1'b0;
        end else begin
			gt_sys_reset  <= (cnt_rp>=24'd100000)&(cnt_rp<=24'd110000);	
			gt_data_reset <= (cnt_rp>=24'd200000)&(cnt_rp<=24'd210000);
        end
	/////////////////////////////////////////////



	wire tx_reset_done;
	wire rx_reset_done;
	wire gt_powergood;


	wire  [3:0] gt0_rxdisperr;
	wire  [3:0] gt0_rxnotintable;  
	wire  [3:0] gt1_rxdisperr;
	wire  [3:0] gt1_rxnotintable;  
	wire  [3:0] gt2_rxdisperr;
	wire  [3:0] gt2_rxnotintable;  
	wire  [3:0] gt3_rxdisperr;
	wire  [3:0] gt3_rxnotintable;  
	wire  [3:0] gt4_rxdisperr;
	wire  [3:0] gt4_rxnotintable; 
	
	
    wire common0_qpll1_lock_out;
    wire common0_qpll1_refclk_out;
    wire common0_qpll1_clk_out;
	

	
	
	//Buffers
	wire txoutclk;
	wire rxoutclk;
	wire tx_core_clk;
	wire rx_core_clk;
	wire link_clk;
    assign link_clk_out = link_clk;
	
	BUFG_GT refclk_bufg_gt_1
	(
	  .I       (txoutclk),
	  .CE      (1'b1),
	  .CEMASK  (1'b1),
	  .CLR     (1'b0),
	  .CLRMASK (1'b1),
	  .DIV     (3'b000),
	  .O       (tx_core_clk)
	);
	
	BUFG_GT refclk_bufg_gt_2
	(
	  .I       (rxoutclk),
	  .CE      (1'b1),
	  .CEMASK  (1'b1),
	  .CLR     (1'b0),
	  .CLRMASK (1'b1),
	  .DIV     (3'b000),
	  .O       (rx_core_clk)
	);	
	
	
	BUFG_GT refclk_bufg_gt_3
	(
	  .I       (rxoutclk),
	  .CE      (1'b1),
	  .CEMASK  (1'b1),
	  .CLR     (1'b0),
	  .CLRMASK (1'b1),
	  .DIV     (3'b000),
	  .O       (link_clk)
	);	
	
	
	wire rxencommaalign = ~adc_sync_b;
	

	wire [31:0] rx_parallel_data4;
	wire [31:0] rx_parallel_data5;
	wire [31:0] rx_parallel_data6;
	wire [31:0] rx_parallel_data7;
	wire [3:0] rx_datak4;
	wire [3:0] rx_datak5;
	wire [3:0] rx_datak6;
	wire [3:0] rx_datak7;


	jesd204_phy_4_lane jesd204_phy_4_lane_inst(
		.tx_sys_reset	(gt_sys_reset),
		.rx_sys_reset	(gt_sys_reset),
		.tx_reset_gt	(gt_data_reset),
		.rx_reset_gt	(gt_data_reset),
		.tx_reset_done	(tx_reset_done	),
		.rx_reset_done	(rx_reset_done	),
		.gt_powergood	(gt_powergood	),
		
		.qpll1_refclk	(devclk),
		.common0_qpll1_lock_out   (common0_qpll1_lock_out  ),
		.common0_qpll1_refclk_out (common0_qpll1_refclk_out),
		.common0_qpll1_clk_out    (common0_qpll1_clk_out   ),	
		
		.rxencommaalign (rxencommaalign),
		.tx_core_clk	(tx_core_clk),
		.txoutclk		(txoutclk),
		.rx_core_clk	(rx_core_clk),
		.rxoutclk		(rxoutclk),
		.drpclk 		(rst_ctl_clk),
		.gt_prbssel     (4'd0),

		.gt0_txcharisk	(tx_datak0),         
		.gt0_txdata		(tx_parallel_data0), 
		.gt1_txcharisk	(tx_datak1),         
		.gt1_txdata		(tx_parallel_data1), 
		.gt2_txcharisk	(tx_datak2),         
		.gt2_txdata		(tx_parallel_data2), 
		.gt3_txcharisk	(tx_datak3),         
		.gt3_txdata		(tx_parallel_data3), 

		.gt4_txcharisk	(tx_datak0),         
		.gt4_txdata		(tx_parallel_data0), 
		.gt5_txcharisk	(tx_datak1),         
		.gt5_txdata		(tx_parallel_data1), 
		.gt6_txcharisk	(tx_datak2),         
		.gt6_txdata		(tx_parallel_data2), 
		.gt7_txcharisk	(tx_datak3),         
		.gt7_txdata		(tx_parallel_data3), 

		.gt4_rxcharisk		(rx_datak4			), 
		.gt4_rxdisperr		(gt4_rxdisperr		),
		.gt4_rxnotintable	(gt4_rxnotintable	),  
		.gt4_rxdata			(rx_parallel_data4	),
		.gt5_rxcharisk		(rx_datak5			), 
		.gt5_rxdata			(rx_parallel_data5	),
		.gt6_rxcharisk		(rx_datak6			),
		.gt6_rxdata			(rx_parallel_data6	),
		.gt7_rxcharisk		(rx_datak7			),
		.gt7_rxdata			(rx_parallel_data7	),  


		.gt0_rxcharisk		(rx_datak0			),
		.gt0_rxdisperr		(gt0_rxdisperr		),
		.gt0_rxnotintable	(gt0_rxnotintable	),  
		.gt0_rxdata			(rx_parallel_data0	),
		.gt1_rxcharisk		(rx_datak1			),
		.gt1_rxdisperr		(gt1_rxdisperr		),
		.gt1_rxnotintable	(gt1_rxnotintable	),  
		.gt1_rxdata			(rx_parallel_data1	),
		.gt2_rxcharisk		(rx_datak2			),
		.gt2_rxdisperr		(gt2_rxdisperr		),
		.gt2_rxnotintable	(gt2_rxnotintable	),  
		.gt2_rxdata			(rx_parallel_data2	),
		.gt3_rxcharisk		(rx_datak3			),
		.gt3_rxdisperr		(gt3_rxdisperr		),
		.gt3_rxnotintable	(gt3_rxnotintable	),  
		.gt3_rxdata			(rx_parallel_data3	),  

	    .rxn_in				(rxn_in	),
	    .rxp_in				(rxp_in	),
	    .txn_out			(txn_out),
	    .txp_out            (txp_out)
	);
///////////////////////////////////////////////////////////////////////////////////



////////////// PHY ready //////////////////////////////////////////////////////
    wire reset_b_0123;
	jesd204b_rst_ctl jesd204b_rst_ctl_inst0
	(
		.link_clk	(rst_ctl_clk),
		.tx_en0		(tx_reset_done), 
		.tx_en1		(gt_powergood), 
		.rx_en0		(rx_reset_done), 
		.rx_en1		(gt_powergood), 
		.reset_b	(reset_b_0123)	
	);
    assign reset_b_0 = reset_b_0123;
	assign reset_b_1 = reset_b_0123;
	assign reset_b_2 = reset_b_0123;
	assign reset_b_3 = reset_b_0123;

	assign tst1 = {
		40'd0,
		gt4_rxdisperr[3:0],		
		gt4_rxnotintable[3:0],	
		cnt_rp[23:20],
		adc_sync_b_rx[5:0], 
		common0_qpll1_lock_out,
		gt_sys_reset,
		link_clk,
		tx_reset_done, 
		gt_powergood, 
		rx_reset_done, 
		gt_powergood, 
		rst_ctl_clk,
		gt_data_reset,	
		pll_locked
	};
	
	
     ////////////// PHY ready to SOFTWARE /////////////////////////////
	wire phy_ready_ena = (&tx_ready) & (&rx_ready);
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

	

endmodule

































