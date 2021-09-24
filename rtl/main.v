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
	input 			if_sel
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
/////////////////////////////////////////////////////////////////////
	
	

	

	
	
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
	wire link_clk;	
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
		
		
		









    wire  [3:0] gt4_rxdisperr = tst1[27:24];
	wire  [3:0] gt4_rxnotintable = tst1[23:20]; 
	//wire  [3:0] adc_sync_b_rx = tst1[15:12];
    //wire [15:0] rx_errors = {tst1[23:16], gt0_rxdisperr[3:0], gt0_rxnotintable[3:0]};	
    //wire [1:0] align_mux = tst2[45:44];  
    //wire [3:0] rx_datak = tst2[43:40]; 
	//wire [31:0] rxd0	= tst2[39:8];
	//wire [31:0] rx_data	= {rx_data_0_i,rx_data_0_q};
	//wire [7:0] rx_state = tst2[7:0];
	


		
	wire [15:0] het_1030_i;
	wire [15:0] het_1030_q;
	wire [15:0] het_1090_i;
	wire [15:0] het_1090_q;
    gen_heterodyne gen_heterodyne_inst
	   (.clk		(link_clk	), 
		.reset_b	(reset_b	), 
		.het_1030_i	(het_1030_i	),
		.het_1030_q	(het_1030_q	),
		.het_1090_i	(het_1090_i	),
		.het_1090_q	(het_1090_q	)
		);
	
	
		
	reg if_sel_reg0;
	reg if_sel_reg1;
    reg if_sel_posedge;	
	always @(posedge link_clk, negedge reset_b)
        if (!reset_b) begin
			if_sel_reg0 <= 1'd0;
			if_sel_reg1 <= 1'd0;
			if_sel_posedge <= 1'd0;
        end else begin	
			if_sel_reg0 <= if_sel;
			if_sel_reg1 <= if_sel_reg0;
			if_sel_posedge <= (~if_sel_reg0) & if_sel;
        end	
	
	reg [1:0] if_sel_fsm;	
	always @(posedge link_clk, negedge reset_b)
        if (!reset_b) begin
			if_sel_fsm <= 2'd0;
        end else begin	
			if (if_sel_posedge)
				if_sel_fsm <= if_sel_fsm + 2'd1;
			else
				if_sel_fsm <= if_sel_fsm;		
        end	
	
    reg signed [15:0] s_i;
    reg signed [15:0] s_q;	
	always @(posedge link_clk, negedge reset_b)
        if (!reset_b) begin
			s_i <= 16'd0;
	        s_q <= 16'd0;
        end else begin	
			//s_i <= het_1090_i + het_1030_i;
	        //s_q <= het_1090_q + het_1030_q;
		    if (if_sel_fsm==2'd0)
		        {s_i, s_q} <= {het_1030_i, het_1030_q}; 
			else if (if_sel_fsm==2'd1)
		        {s_i, s_q} <= {het_1090_i, het_1090_q}; 
			else if (if_sel_fsm==2'd2)
		        {s_i, s_q} <= {het_1090_i, het_1090_q}; 		
			else
		        {s_i, s_q} <= {het_1030_i, het_1030_q};
        end	 
		
		
		

	
////////////////// DDC ///////////////////////////////////////////////////////////////////////
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

///////////////////  RX 1030 ////////////////////////////////
	wire [19:0] demod_1030_i;
    wire [19:0] demod_1030_q;   
    ddc_dmsp_125 ddc_dmsp_125_inst1(
	    .link_clk  (link_clk    ),
        .clk_125   (clk_125  	),  
		.clk_25    (clk_25  	),
		.clk_100   (clk_100 	),
		.clk_20    (clk_20  	),
        .reset_b   (dsp_pll_locked),       
        .get_i     (het_1030_q  ),
        .get_q     (het_1030_i  ),
        .sig_in_i  (rx_data_0_i	),
        .sig_in_q  (rx_data_0_q	),
        .sig_out_i (demod_1030_i),
        .sig_out_q (demod_1030_q)
        );
		
    wire [23:0] sig_i_1030 = {demod_1030_i, 4'd0};
    wire [23:0] sig_q_1030 = {demod_1030_q, 4'd0};
    wire [23:0] mag_1030;
	mag_complex mag_complex_inst1(
		.reset_b	(reset_b	),
		.clk		(clk_20		),
		.sig_i		(sig_i_1030 ),
		.sig_q		(sig_q_1030 ),
		.magnitude  (mag_1030   )	
    );   	
////////////////////////////////////////////////////////////////
	
	

///////////////////  RX 1090 ////////////////////////////////
	wire [19:0] demod_1090_i;
    wire [19:0] demod_1090_q;   
    ddc_dmsp_125 ddc_dmsp_125_inst2(
	    .link_clk  (link_clk    ),
        .clk_125   (clk_125  	),  
		.clk_25    (clk_25  	),
		.clk_100   (clk_100 	),
		.clk_20    (clk_20  	),
        .reset_b   (dsp_pll_locked),       
        .get_i     (het_1090_q  ),
        .get_q     (het_1090_i  ),
        .sig_in_i  (rx_data_0_i	),
        .sig_in_q  (rx_data_0_q	),
        .sig_out_i (demod_1090_i),
        .sig_out_q (demod_1090_q)
        );
		
    wire [23:0] sig_i_1090 = {demod_1090_i, 4'd0};
    wire [23:0] sig_q_1090 = {demod_1090_q, 4'd0};
    wire [23:0] mag_1090;
	mag_complex mag_complex_inst2(
		.reset_b	(reset_b	),
		.clk		(clk_20		),
		.sig_i		(sig_i_1090 ),
		.sig_q		(sig_q_1090 ),
		.magnitude  (mag_1090   )	
    );   	
////////////////////////////////////////////////////////////////
		
	
		
		


///////////////////// LA ////////////////////////////////////////////////////////////////									
    assign tx_data_0_i = s_i;
	assign tx_data_0_q = s_q;
	assign tx_data_1_i = s_i;
	assign tx_data_1_q = s_q;
	assign tx_data_2_i = s_i;
	assign tx_data_2_q = s_q;
	assign tx_data_3_i = s_i;
	assign tx_data_3_q = s_q;
		

	
	reg [31:0] rx_data; 
	reg [7:0] cnt_fc;
	reg [31:0] tx_data_tst;
	reg [3:0] tx_datak;
	reg [3:0] rx_datak;
	reg [3:0] tx_state;
	reg sysref_edge;
	reg [15:0] tst_state;
	reg [3:0] rx_state;
	reg [2:0] mux_sel;
	reg [1:0] align_mux; 
	always @(posedge link_clk, negedge reset_b)
        if (!reset_b) begin
			cnt_fc	<= 8'd0;
			tx_data_tst	<= 32'd0;
			tx_datak    <= 4'd0;
			rx_datak    <= 4'd0;
			tx_state    <= 4'd0;
			sysref_edge <= 1'd0;
            rx_state    <= 4'd0;
			rx_data <= 32'd0;
			mux_sel <= 3'd0;
			align_mux <= 2'd0;
        end else begin	
			cnt_fc	<= tst[55:48];
			tx_data_tst	<= tst[47:16];
			tx_datak    <= tst[15:12];
			rx_datak = tst2[43:40]; 
			tx_state    <= tst[7:4];
			sysref_edge <= tst[3];	
			mux_sel <= tst[2:0];
            rx_state <= tst2[3:0];   
			rx_data <= tst2[39:8];
			align_mux <= tst2[45:44]; 
        end	 

	
	reg sysref_reg;
	reg rx_sync_reg0; 
	reg rx_sync_reg; 
	reg tx_sync_reg;
	always @(posedge clk_100, negedge pll_locked)
        if (!pll_locked) begin
	        sysref_reg  <= 1'b0;
	        rx_sync_reg0 <= 1'b0;
			rx_sync_reg <= 1'b0;
	        tx_sync_reg <= 1'b0;
        end else begin	
			sysref_reg  <= sysref; 
			rx_sync_reg0 <= rx_sync;
            rx_sync_reg <= rx_sync_reg0;			
			tx_sync_reg <= tx_sync; 
        end	 	
	
	
	reg signed [15:0] orx_data_0_i_reg;
	reg signed [15:0] orx_data_0_q_reg;
	reg signed [15:0] orx_data_1_i_reg;
	reg signed [15:0] orx_data_1_q_reg;
	reg signed [15:0] rx_data_0_i_reg;
	reg signed [15:0] rx_data_0_q_reg;
	reg signed [15:0] rx_data_1_i_reg;
	reg signed [15:0] rx_data_1_q_reg;
	reg signed [15:0] rx_data_2_i_reg;
	reg signed [15:0] rx_data_2_q_reg;
	reg signed [15:0] rx_data_3_i_reg;
	reg signed [15:0] rx_data_3_q_reg;
	
	reg signed [15:0] orx_data_0_i_reg0;
	reg signed [15:0] orx_data_0_q_reg0;
	reg signed [15:0] orx_data_1_i_reg0;
	reg signed [15:0] orx_data_1_q_reg0;
	reg signed [15:0] rx_data_0_i_reg0;
	reg signed [15:0] rx_data_0_q_reg0;
	reg signed [15:0] rx_data_1_i_reg0;
	reg signed [15:0] rx_data_1_q_reg0;
	reg signed [15:0] rx_data_2_i_reg0;
	reg signed [15:0] rx_data_2_q_reg0;
	reg signed [15:0] rx_data_3_i_reg0;
	reg signed [15:0] rx_data_3_q_reg0;
	
    always @(posedge link_clk, negedge reset_b)
        if (!reset_b) begin
			orx_data_0_i_reg0 <= 16'd0;
			orx_data_1_i_reg0 <= 16'd0;
			orx_data_0_q_reg0 <= 16'd0;
			orx_data_1_q_reg0 <= 16'd0;
			rx_data_0_i_reg0 <= 16'd0;
			rx_data_0_q_reg0 <= 16'd0;
			rx_data_1_i_reg0 <= 16'd0;
			rx_data_1_q_reg0 <= 16'd0;
			rx_data_2_i_reg0 <= 16'd0;
			rx_data_2_q_reg0 <= 16'd0;
			rx_data_3_i_reg0 <= 16'd0;
			rx_data_3_q_reg0 <= 16'd0;	
        end else begin
			orx_data_0_i_reg0 <= orx_data_0_i;
			orx_data_1_i_reg0 <= orx_data_1_i;
			orx_data_0_q_reg0 <= orx_data_0_q;
			orx_data_1_q_reg0 <= orx_data_1_q;
			rx_data_0_i_reg0 <= rx_data_0_i;
			rx_data_0_q_reg0 <= rx_data_0_q;
			rx_data_1_i_reg0 <= rx_data_1_i;
			rx_data_1_q_reg0 <= rx_data_1_q;
			rx_data_2_i_reg0 <= rx_data_2_i;
			rx_data_2_q_reg0 <= rx_data_2_q;
			rx_data_3_i_reg0 <= rx_data_3_i;
			rx_data_3_q_reg0 <= rx_data_3_q;	
        end

    always @(posedge link_clk, negedge reset_b)
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
        end else begin
			orx_data_0_i_reg <= orx_data_0_i_reg0;
			orx_data_1_i_reg <= orx_data_1_i_reg0;
			orx_data_0_q_reg <= orx_data_0_q_reg0;
			orx_data_1_q_reg <= orx_data_1_q_reg0;
			rx_data_0_i_reg  <= rx_data_0_i_reg0; 
			rx_data_0_q_reg  <= rx_data_0_q_reg0; 
			rx_data_1_i_reg  <= rx_data_1_i_reg0; 
			rx_data_1_q_reg  <= rx_data_1_q_reg0; 
			rx_data_2_i_reg  <= rx_data_2_i_reg0; 
			rx_data_2_q_reg  <= rx_data_2_q_reg0; 
			rx_data_3_i_reg  <= rx_data_3_i_reg0; 
			rx_data_3_q_reg  <= rx_data_3_q_reg0; 
        end
		
	reg [15:0] mag_1090_reg;    
	reg [15:0] demod_1090_i_reg;
	reg [15:0] demod_1090_q_reg;
	reg [15:0] demod_1030_i_reg;
	reg [15:0] demod_1030_q_reg;
	reg [15:0] mag_1030_reg;  
    reg [15:0] mag_1090_reg; 	
	reg [15:0] demod_1090_i_reg_0;
	reg [15:0] demod_1090_q_reg_0;
	always @(posedge clk_20, negedge reset_b)
        if (!reset_b) begin
			mag_1030_reg     <= 16'd0;
			mag_1090_reg     <= 16'd0;		
			demod_1090_i_reg <= 16'd0; 
			demod_1090_q_reg <= 16'd0; 
			demod_1030_i_reg <= 16'd0; 
			demod_1030_q_reg <= 16'd0; 
			demod_1090_i_reg_0 <= 16'd0; 
			demod_1090_q_reg_0 <= 16'd0; 
        end else begin	
			mag_1030_reg <= mag_1030[19:4] + mag_1030[3];
			mag_1090_reg <= mag_1090[19:4] + mag_1090[3];  
			demod_1090_i_reg_0 <= demod_1090_i[15:0]; 
			demod_1090_q_reg_0 <= demod_1090_q[15:0];   
			demod_1090_i_reg <= demod_1090_i[19:4] + demod_1090_i[3]; 
			demod_1090_q_reg <= demod_1090_q[19:4] + demod_1090_q[3]; 	
			demod_1030_i_reg <= demod_1030_i[15:0]; 
			demod_1030_q_reg <= demod_1030_q[15:0];   
        end	 
	
	
	
	
	wire [15:0] reset_tst = tst1[15:0];	
	wire [5:0] adc_sync_b_rx = tst1[15:10]; 
	wire trig_in = rst_ctl_clk;  
	wire trig_in_ack;
	wire [15:0] probe0  = {rx_datak[3:0], rx_state[3:0], align_mux[1:0], 2'd0, rx_sync_reg, tx_sync_reg, sysref_reg, rst_ctl_clk};  // rx_data_0_q_reg;    
	wire [15:0] probe1  = demod_1090_i_reg; 
	wire [15:0] probe2  = demod_1090_i_reg_0;       
	wire [15:0] probe3  = demod_1090_q_reg_0;  
	wire [15:0] probe4  = rx_data_0_i_reg;  // mag_1030_reg;  	
	wire [15:0] probe5  = rx_data_0_q_reg;  // mag_1090_reg;   	
	wire [15:0] probe6  = rx_data_1_i_reg;  // rx_data_0_i_reg;     
	wire [15:0] probe7  = rx_data_1_q_reg;  // rx_data_0_q_reg;     
	wire [15:0] probe8  = rx_data_2_i_reg;  // orx_data_0_i_reg; 
	wire [15:0] probe9  = rx_data_2_q_reg;  // orx_data_0_q_reg;  
	wire [15:0] probe10 = demod_1030_i_reg;  //  rx_data_3_i_reg;  // 
	wire [15:0] probe11 = demod_1030_q_reg;  //  rx_data_3_q_reg;  // 

	
	
	ila_0 ila_0_inst(
		.clk		(clk_20), 
		.trig_in	(trig_in),
		.probe0		(probe0	),
		.probe1		(probe1	),
		.probe2		(probe2	),
		.probe3		(probe3	),
		.probe4		(probe4	),
		.probe5		(probe5	),
		.probe6		(probe6	),
		.probe7     (probe7 ),
		.probe8		(probe8	),
		.probe9		(probe9	),
		.probe10	(probe10),
		.probe11    (probe11)
	);

		

		
		
		
		
endmodule
