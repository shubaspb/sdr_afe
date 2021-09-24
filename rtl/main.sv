//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Mon Apr 20 02:12:16 2020
//Host        : HSP_DT002 running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module main
   (
    input           osc_p,				// 300 MHz
	input           osc_n,
    //input 			refclk_n,
    //input 			refclk_p,
    input 			refauxclk_n,
    input 			refauxclk_p,
    //output 			rx_alt_syncn,
    //output 			rx_alt_syncp,
    //input 			rx_reset,
    output 			rx_syncn,
    output 			rx_syncp,
    input 			sysrefn,
    input 			sysrefp,
    input 			tx_sync_n,
    input 			tx_sync_p,
    input 	[7:0]	rxn_in,
    input 	[7:0]	rxp_in,
    output 	[7:0]	txn_out,
    output 	[7:0]	txp_out,
	input           reset_sw,
	input 			if_sel,
	output			pa_en
	);
	
	
	wire adapt_out; 
	gva_ctrl gva_ctrl_inst
	   (.clk		(clk_125), 
		.reset_b	(dsp_pll_locked), 
		.adapt_in	(if_sel),
		.adapt_out	(adapt_out),
		.gva_on     (pa_en)
		);
		


	wire sysref;
    IBUFDS IBUFDS_inst4 (
      .O(sysref),  
      .I(sysrefp),
      .IB(sysrefn)
    ); 
	
 	wire rx_sync;
    OBUFDS OBUFDS_inst4 (
      .I(rx_sync),  
      .O(rx_syncp),
      .OB(rx_syncn)
    );  
	
	//assign rx_syncp = rx_sync; 
	//assign rx_syncn = rx_sync; 
	
 	wire tx_sync;
    IBUFDS IBUFDS_inst5 (
      .O(tx_sync),  
      .I(tx_sync_p),
      .IB(tx_sync_n)
    ); 
	 
	//assign tx_sync = tx_sync_p;
	
/////////////// local clock //////////////////////////////////////// 
	wire osc;
    IBUFDS IBUFDS_inst2 (
      .O(osc),  
      .I(osc_p),
      .IB(osc_n)
    ); 

	wire clk_main_100;
	wire pll_locked;	
 	pll_main pll_main_inst
	 (
	    .clk_out1 (clk_main_100),
	    .reset    (1'b0),
	    .locked   (pll_locked),
	    .clk_in1  (osc)
	 ); 
	 
    reg [19:0] cntx;
    always @(posedge clk_main_100, negedge pll_locked)
        if (!pll_locked) begin
                cntx <= 20'd0;
        end else begin
                cntx <= cntx + ~&cntx;        
            end    
    assign reset_b = &cntx;  // 10 ms
///////////////////////////////////////////////////////////////////	
	
	
	
///////////////// jesd clock //////////////////////////////////////
	wire refclk;
	wire refclk_copy;
	//Reference clock LVDS to single ended signal. ODIV2 will be the same as O output.
	IBUFDS_GTE4 ibufds_refclk_c (
	  .O     (refclk),
	  .ODIV2 (refclk_copy),
	  .CEB   (1'b0),
	  .I     (refauxclk_p),
	  .IB    (refauxclk_n)
	);

	//Buffer
	wire clk_reset_gt0;	
	BUFG_GT refclk_bufg_gt_c
	(
	  .I       (refclk_copy),
	  .CE      (1'b1),
	  .CEMASK  (1'b1),
	  .CLR     (1'b0),
	  .CLRMASK (1'b1),
	  .DIV     (3'b000),
	  .O       (clk_reset_gt0)
	);
	
	wire rst_ctl_clk;	
	wire rst_ctl_pll_locked;
	wire reset_pll_test = ~pll_locked;
 	pll_test pll_test_inst
	 (
	    .clk_out1 (rst_ctl_clk),
	    .reset    (reset_pll_test),
	    .locked   (rst_ctl_pll_locked),
	    .clk_in1  (clk_reset_gt0)
	 ); 


    wire reset_jesd_b = rst_ctl_pll_locked & (~reset_sw);
	
	
	
	wire link_clk;	
	wire clk_125;
    wire clk_25;
    wire clk_100;
    wire clk_20;
    wire dsp_pll_locked;
	clk_wiz_0 clk_wiz_0_inst(
		.reset		(reset_pll_test),
		.clk_in1 	(link_clk),
		.clk_out1	(clk_125),
		.clk_out2	(clk_25),
		.clk_out3	(clk_100),
		.clk_out4	(clk_20),
		.locked		(dsp_pll_locked)
	);
/////////////////////////////////////////////////////////////////////
	
	

/////////////////// JESD ////////////////////////////////////////////
    wire [15:0] rx_data_0_i;
    wire [15:0] rx_data_0_q;
    wire [15:0] rx_data_1_i;
    wire [15:0] rx_data_1_q;
    wire [15:0] rx_data_2_i;
    wire [15:0] rx_data_2_q;
    wire [15:0] rx_data_3_i;
    wire [15:0] rx_data_3_q;	
    wire [15:0] tx_data_0_i;
    wire [15:0] tx_data_0_q;
    wire [15:0] tx_data_1_i;
    wire [15:0] tx_data_1_q;
    wire [15:0] tx_data_2_i;
    wire [15:0] tx_data_2_q;
    wire [15:0] tx_data_3_i;
    wire [15:0] tx_data_3_q;	
// ORX
    wire [15:0] orx_data_0_i;
    wire [15:0] orx_data_0_q;
    wire [15:0] orx_data_1_i;
    wire [15:0] orx_data_1_q;
	
	wire [67:0] tst;
	wire [67:0] tst1;
	wire [67:0] tst2;
    jesd204b_8lane jesd204b_8lane_inst(
        .rst_ctl_clk        (rst_ctl_clk),
        .pll_locked         (reset_jesd_b),
        //
        .link_clk_out       (link_clk),
        .sysref             (sysref),
        .devclk             (refclk),
        .adc_sync_b         (rx_sync),
        .dac_sync_b         (tx_sync),
        .scrambler_is_on    (1'b1),
        // serial
		.rxn_in				(rxn_in[7:0]),
		.rxp_in				(rxp_in[7:0]),
		.txn_out			(txn_out[7:0]),
		.txp_out			(txp_out[7:0]),	
        // rx
        .rx_data_0_i        (rx_data_0_i),
        .rx_data_0_q        (rx_data_0_q),
        .rx_data_1_i        (rx_data_1_i),
        .rx_data_1_q        (rx_data_1_q),
        .rx_data_2_i        (rx_data_2_i),
        .rx_data_2_q        (rx_data_2_q),
        .rx_data_3_i        (rx_data_3_i),
        .rx_data_3_q        (rx_data_3_q),
        // tx
        .tx_data_0_i        (tx_data_0_i),
        .tx_data_0_q        (tx_data_0_q),
        .tx_data_1_i        (tx_data_1_i),
        .tx_data_1_q        (tx_data_1_q),
        .tx_data_2_i        (tx_data_2_i),
        .tx_data_2_q        (tx_data_2_q),
        .tx_data_3_i        (tx_data_3_i),
        .tx_data_3_q        (tx_data_3_q),
		// orx
		.orx_data_0_i       (orx_data_0_i),
		.orx_data_0_q       (orx_data_0_q),
		.orx_data_1_i       (orx_data_1_i),
		.orx_data_1_q       (orx_data_1_q),
        // link control
        .rx_channel         (),        
        .usedw              (),
        .err_link_rx        (),
		.tst(tst),
		.tst1(tst1),
		.tst2(tst2)
        );    
///////////////////////////////////////////////////////////////////////	
		
		

	
	wire [15:0] het_1030_i;
	wire [15:0] het_1030_q;
	wire [15:0] het_1090_i;
	wire [15:0] het_1090_q;
    gen_heterodyne gen_heterodyne_inst
	   (.clk		(clk_125	), 
		.reset_b	(dsp_pll_locked	), 
		.het_1030_i	(het_1030_i	),
		.het_1030_q	(het_1030_q	),
		.het_1090_i	(het_1090_i	),
		.het_1090_q	(het_1090_q	)
		);
	
	
////////////// TX ////////////////////////////////////////////////////
	wire signed [19:0] sig_gen_i;
	wire signed [19:0] sig_gen_q;
	gen_signal gen_signal_inst
	   (.clk	(clk_125), 
		.reset_b(dsp_pll_locked), 
		.sig_i	(sig_gen_i),
		.sig_q  (sig_gen_q)
		);
	

		
	wire signed [19:0] sig_out_i;
	wire signed [19:0] sig_out_q;
	dpd #(.DELAY(507)) dpd_inst(
		.clk		(clk_125),
		.reset_b	(dsp_pll_locked),
		.dpd_adapt	(adapt_out	),
		.sig_in_i	(sig_gen_i), 
		.sig_in_q	(sig_gen_q),
		.sig_pa_i   (sig_pa_out_i),
		.sig_pa_q   (sig_pa_out_q),
		.sig_out_i	(sig_out_i),
		.sig_out_q  (sig_out_q)
	);		
	
    wire signed [15:0] s_i;
    wire signed [15:0] s_q;		
	compl_mult #(.W(16)) compl_mult_inst0  ( 
		.reset_b(dsp_pll_locked), 
		.clk	(clk_125), 
		.a		({sig_out_i[19:4], sig_out_q[19:4]}), 
		.b		({het_1090_i,het_1090_q}), 
		.o		({s_i, s_q}) );		
		
    wire signed [15:0] s_i_gain;
    wire signed [15:0] s_q_gain;		
	compl_mult #(.W(16)) compl_mult_inst5  ( 
		.reset_b(dsp_pll_locked), 
		.clk	(clk_125), 
		.a		({16'd20480, 16'd0}), 
		.b		({s_i, s_q}), 
		.o		({s_i_gain, s_q_gain}) );			
		
    assign tx_data_0_i = {s_i_gain[14:0], 1'b0};
	assign tx_data_0_q = {s_q_gain[14:0], 1'b0};
	assign tx_data_1_i = {s_i_gain[14:0], 1'b0};
	assign tx_data_1_q = {s_q_gain[14:0], 1'b0};
	assign tx_data_2_i = {s_i_gain[14:0], 1'b0};
	assign tx_data_2_q = {s_q_gain[14:0], 1'b0};
	assign tx_data_3_i = {s_i_gain[14:0], 1'b0};
	assign tx_data_3_q = {s_q_gain[14:0], 1'b0};	
////////////////////////////////////////////////////////////////////////	
	
	
	
////////////////////// RX //////////////////////////////////////////////	
    /////////////// GAIN ///////////////////////////////
    wire signed [15:0] gain_orx_i = 16'd27000;
    wire signed [15:0] gain_orx_q = 16'd0;		
    wire signed [15:0] sig_gain_i_0;
    wire signed [15:0] sig_gain_q_0;
	compl_mult #(.W(16)) compl_mult_inst3  ( 
		.reset_b(dsp_pll_locked), 
		.clk	(clk_125), 
		.a		({orx_data_0_i, orx_data_0_q}), 
		.b		({gain_orx_i, gain_orx_q}), 
		.o		({sig_gain_i_0, sig_gain_q_0}) );	

    reg signed [15:0] sig_gain_i;
    reg signed [15:0] sig_gain_q;
	always @(posedge clk_125, negedge dsp_pll_locked)
        if (!dsp_pll_locked) begin
			sig_gain_i <= 16'd0;
			sig_gain_q <= 16'd0;
        end else begin	
			sig_gain_i <= sig_gain_i_0[15:0];   //{sig_gain_i_0[13:0], 2'd0};
			sig_gain_q <= sig_gain_q_0[15:0];   //{sig_gain_q_0[13:0], 2'd0};
        end	
	////////////////////////////////////////////////////

	
    wire signed [15:0] sig_pa_out_16_i;
    wire signed [15:0] sig_pa_out_16_q;		
	compl_mult #(.W(16)) compl_mult_inst4  ( 
		.reset_b(dsp_pll_locked), 
		.clk	(clk_125), 
		.a		({sig_gain_i, sig_gain_q}), 
		.b		({het_1090_q,het_1090_i}), 
		.o		({sig_pa_out_16_i, sig_pa_out_16_q}) );
		
	reg signed [19:0] sig_pa_out_i;
	reg signed [19:0] sig_pa_out_q;
	reg signed [19:0] sig_pa_out_i_reg3;
	reg signed [19:0] sig_pa_out_q_reg3;
	always @(posedge clk_125, negedge dsp_pll_locked)
        if (!dsp_pll_locked) begin
			sig_pa_out_i <= 20'd0;
			sig_pa_out_q <= 20'd0;
			sig_pa_out_i_reg3 <= 20'd0;
			sig_pa_out_q_reg3 <= 20'd0;
        end else begin	
			sig_pa_out_i <= {sig_pa_out_16_i, 4'd0};
			sig_pa_out_q <= {sig_pa_out_16_q, 4'd0};
			sig_pa_out_i_reg3 <= sig_pa_out_i;
			sig_pa_out_q_reg3 <= sig_pa_out_q;		
        end	
///////////////////////////////////////////////////////////////////////////////////////






	wire [19:0] mag_sig_gen;
	mag_complex mag_complex_inst(
	    .clk	  (clk_125),
		.reset_b  (dsp_pll_locked),
		.sig_in_i (sig_gen_i),    
		.sig_in_q (sig_gen_q),
		.magn     (mag_sig_gen)  		
	);
	
	wire [19:0] mag_sig_out;
	mag_complex mag_complex_inst1(
	    .clk	  (clk_125),
		.reset_b  (dsp_pll_locked),
		.sig_in_i (sig_out_i),    
		.sig_in_q (sig_out_q),
		.magn     (mag_sig_out)  		
	);
	
	wire [19:0] mag_sig_pa_out;
	mag_complex mag_complex_inst2(
	    .clk	  (clk_125),
		.reset_b  (dsp_pll_locked),
		.sig_in_i (sig_pa_out_i_reg3),    
		.sig_in_q (sig_pa_out_q_reg3),
		.magn     (mag_sig_pa_out)  		
	);
	
	wire [19:0] mag_dpd_la0;
	mag_complex mag_complex_inst3(
	    .clk	  (clk_125),
		.reset_b  (dsp_pll_locked),
		.sig_in_i ({sig_dpd_la_i, 4'd0}),    
		.sig_in_q ({sig_dpd_la_q, 4'd0}),
		.magn     (mag_dpd_la0)  		
	);
	
	wire [19:0] mag_del_la0;
	mag_complex mag_complex_inst4(
	    .clk	  (clk_125),
		.reset_b  (dsp_pll_locked),
		.sig_in_i ({sig_del_la_i, 4'd0}),    
		.sig_in_q ({sig_del_la_q, 4'd0}),
		.magn     (mag_del_la0)  		
	);




///////////////////// LA ////////////////////////////////////////////////////////////////									
	reg [15:0] mag_sig_gen_reg;
	reg [15:0] mag_sig_out_reg;
	reg [15:0] mag_sig_pa_out_reg;
	reg [15:0] mag_dpd_la_reg;
	reg [15:0] mag_del_la_reg;
	reg signed [15:0] sig_gen_reg_i;
	reg signed [15:0] sig_gen_reg_q;
	always @(posedge clk_125, negedge dsp_pll_locked)
        if (!dsp_pll_locked) begin
			mag_sig_gen_reg    <= 16'd0;
			mag_sig_out_reg    <= 16'd0;
			mag_sig_pa_out_reg <= 16'd0;
			mag_dpd_la_reg <= 16'd0;
			mag_del_la_reg <= 16'd0;
			sig_gen_reg_i <= 16'd0;
			sig_gen_reg_q <= 16'd0;
        end else begin	
			mag_sig_gen_reg    <= mag_sig_gen   [19:4];
			mag_sig_out_reg    <= mag_sig_out   [19:4];
			mag_sig_pa_out_reg <= mag_sig_pa_out[19:4];
			mag_dpd_la_reg <= mag_dpd_la0[19:4];
			mag_del_la_reg <= mag_del_la0[19:4];	
			sig_gen_reg_i <= sig_gen_i[19:4];
			sig_gen_reg_q <= sig_gen_q[19:4];
        end	 
	
	
	reg [15:0] sig_gain_i_reg0;
	reg [15:0] sig_gain_q_reg0;
	reg [15:0] orx_data_0_i_reg;
	reg [15:0] orx_data_1_i_reg;
	reg [15:0] orx_data_0_q_reg;
	reg [15:0] orx_data_1_q_reg;
	reg [15:0] rx_data_0_i_reg;
	reg [15:0] rx_data_0_q_reg;
	reg [15:0] rx_data_1_i_reg;
	reg [15:0] rx_data_1_q_reg;
	reg [15:0] rx_data_2_i_reg;
	reg [15:0] rx_data_2_q_reg;
	reg [15:0] rx_data_3_i_reg;
	reg [15:0] rx_data_3_q_reg;
    always @(posedge clk_125, negedge reset_b)
        if (!reset_b) begin
			orx_data_0_i_reg <= 16'd0;
			orx_data_1_i_reg <= 16'd0;
			orx_data_0_q_reg <= 16'd0;
			orx_data_1_q_reg <= 16'd0;
			rx_data_0_i_reg <= 16'd0;
			rx_data_0_q_reg <= 16'd0;
			rx_data_1_i_reg <= 16'd0;
			rx_data_1_q_reg <= 16'd0;
			rx_data_2_i_reg <= 16'd0;
			rx_data_2_q_reg <= 16'd0;
			rx_data_3_i_reg <= 16'd0;
			rx_data_3_q_reg <= 16'd0;	
			sig_gain_i_reg0 <= 16'd0;
			sig_gain_q_reg0 <= 16'd0;		
        end else begin
			orx_data_0_i_reg <= orx_data_0_i;
			orx_data_1_i_reg <= orx_data_1_i;
			orx_data_0_q_reg <= orx_data_0_q;
			orx_data_1_q_reg <= orx_data_1_q;
			rx_data_0_i_reg  <= rx_data_0_i; 
			rx_data_0_q_reg  <= rx_data_0_q; 
			rx_data_1_i_reg  <= rx_data_1_i; 
			rx_data_1_q_reg  <= rx_data_1_q; 
			rx_data_2_i_reg  <= rx_data_2_i; 
			rx_data_2_q_reg  <= rx_data_2_q; 
			rx_data_3_i_reg  <= rx_data_3_i; 
			rx_data_3_q_reg  <= rx_data_3_q; 
			sig_gain_i_reg0  <= sig_gain_i;
			sig_gain_q_reg0  <= sig_gain_q;		
        end
		


	
	
/* 	ila_0 ila_0_inst(
		.clk		(clk_125), 
		.trig_in	(trig_in),
		.probe0		(mag_sig_gen_reg1   ),
		.probe1		(mag_sig_out_reg1   ),
		.probe2		(mag_sig_pa_out_reg1),
		.probe3		(dpd_adapt_reg1     ),
		.probe4		(mag_dpd_la_reg1    ),
		.probe5		(mag_del_la_reg1    ),
		.probe6		(sig_dpd_la_i_reg1  ),
		.probe7     (sig_dpd_la_q_reg1  ),
		.probe8		(sig_del_la_i_reg1  ),
		.probe9		(sig_del_la_q_reg1  ),
		.probe10	(sig_gain_i_reg1 	),
		.probe11    (sig_gain_q_reg1 	)
	); */

		

		
		
		
		
endmodule
