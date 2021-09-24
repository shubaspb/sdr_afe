

module ddc_dmsp_125
(
    input         link_clk,
    input         clk_125,    // clock
	input         clk_25,     // 
	input         clk_100,    // 
	input         clk_20,     // 
    input         reset_b,    // reset
    input  [15:0] get_i,      // heterodyne signal, real part
    input  [15:0] get_q,      // heterodyne signal, imag part
    input  [15:0] sig_in_i,   // input signal, real part
    input  [15:0] sig_in_q,   // input signal, imag part
    output [19:0] sig_out_i,  // output signal, real part
    output [19:0] sig_out_q   // output signal, imag part
);


	reg [15:0] get_i_0, get_i_1, get_i_2, get_i_3;  
	reg [15:0] get_q_0, get_q_1, get_q_2, get_q_3; 
	reg [15:0] sig_in_i_0, sig_in_i_1, sig_in_i_2, sig_in_i_3;
	reg [15:0] sig_in_q_0, sig_in_q_1, sig_in_q_2, sig_in_q_3;

	always @ (posedge link_clk, negedge reset_b)
		if (!reset_b) begin
		    {get_i_1, get_i_0} <= 32'd0;
			{get_q_1, get_q_0} <= 32'd0;
		    {sig_in_i_1, sig_in_i_0} <= 32'd0;
			{sig_in_q_1, sig_in_q_0} <= 32'd0;
		end else begin
		    {get_i_1, get_i_0} <= {get_i_0, get_i};
			{get_q_1, get_q_0} <= {get_q_0, get_q};
		    {sig_in_i_1, sig_in_i_0} <= {sig_in_i_0, sig_in_i};
			{sig_in_q_1, sig_in_q_0} <= {sig_in_q_0, sig_in_q};
		end
		   
	always @ (posedge clk_125, negedge reset_b)
		if (!reset_b) begin
		    {get_i_3, get_i_2} <= 32'd0;
			{get_q_3, get_q_2} <= 32'd0;
		    {sig_in_i_3, sig_in_i_2} <= 32'd0;
			{sig_in_q_3, sig_in_q_2} <= 32'd0;
		end else begin
		    {get_i_3, get_i_2} <= {get_i_2, get_i_1};
			{get_q_3, get_q_2} <= {get_q_2, get_q_1};
		    {sig_in_i_3, sig_in_i_2} <= {sig_in_i_2, sig_in_i_1};
			{sig_in_q_3, sig_in_q_2} <= {sig_in_q_2, sig_in_q_1};
		end



//////////////////// 125 ///////////////////////////////////////
	wire [19:0] get_i_3_wire 	= {get_i_3, 4'd0}; 
	wire [19:0] get_q_3_wire 	= {get_q_3, 4'd0}; 
	wire [19:0] sig_in_i_3_wire = {sig_in_i_3, 4'd0};
	wire [19:0] sig_in_q_3_wire = {sig_in_q_3, 4'd0};

    wire [19:0] demod_i;
    wire [19:0] demod_q;
    complex_mult #(.W(20)) complex_mult_rxst1(
        .reset_b (reset_b        ),
        .clk     (clk_125        ),
        .a_in_i  (get_i_3_wire   ),
        .a_in_q  (get_q_3_wire   ),
        .b_in_i  (sig_in_i_3_wire),
        .b_in_q  (sig_in_q_3_wire),
        .out_i   (demod_i        ),
        .out_q   (demod_q        ));



    wire [23:0] cic_125_i; 
    cic_filter_5st
       #(.W_IN          (20),
         .W_GAIN        (14),
         .W_GAIN_STAGE  (3),
         .W_OUT         (24),
         .ORDER         (5))
    cic_filter_inst_1
       (.clk         (clk_125), 
        .reset_b     (reset_b),  
        .data_input  (demod_i),
        .data_output (cic_125_i));

    wire [23:0] cic_125_q; 
    cic_filter_5st
       #(.W_IN          (20),
         .W_GAIN        (14),
         .W_GAIN_STAGE  (3),
         .W_OUT         (24),
         .ORDER         (5))
    cic_filter_inst_2
       (.clk         (clk_125), 
        .reset_b     (reset_b),  
        .data_input  (demod_q),
        .data_output (cic_125_q));


	

/////////////// 25 //////////////////////////////////////////////	
	reg [19:0] dec_25_i;
	reg [19:0] dec_25_q;
	reg [19:0] dec_25_i_0;
	reg [19:0] dec_25_q_0;
	always @ (posedge clk_25, negedge reset_b)
		if(!reset_b) begin
		    dec_25_i_0 <= 20'd0;
			dec_25_q_0 <= 20'd0;
		    dec_25_i <= 20'd0;
			dec_25_q <= 20'd0;
		end else begin
		    dec_25_i_0 <= cic_125_i[21:2];
			dec_25_q_0 <= cic_125_q[21:2];
		    dec_25_i <= dec_25_i_0;
			dec_25_q <= dec_25_q_0;
		end
		   
		   
	//  wire [19:0] fir_25_i;	   
	//  fir_filter_23 fir_filter_23_inst0
	//     (.clk		(clk_25), 
	//  	.reset_b	(reset_b), 
	//  	.data_input	(dec_25_i),
	//  	.data_output(fir_25_i));
    //  
	//  wire [19:0] fir_25_q;	   
	//  fir_filter_23 fir_filter_23_inst2
	//     (.clk		(clk_25), 
	//  	.reset_b	(reset_b), 
	//  	.data_input	(dec_25_q),
	//  	.data_output(fir_25_q));		
	
	
	
/////////////// 100 //////////////////////////////////////////////	
	reg [19:0] fir_100_i;
	reg [19:0] fir_100_q;
	reg [19:0] fir_100_i_0;
	reg [19:0] fir_100_q_0;
	always @ (posedge clk_100, negedge reset_b)
		if(!reset_b) begin
		    fir_100_i_0 <= 20'd0;
			fir_100_q_0 <= 20'd0;
		    fir_100_i <= 20'd0;
			fir_100_q <= 20'd0;
		end else begin
		    fir_100_i_0 <= dec_25_i;  // fir_25_i; //
			fir_100_q_0 <= dec_25_q;  // fir_25_q; //
		    fir_100_i <= fir_100_i_0;
			fir_100_q <= fir_100_q_0;
		end
	

    wire [23:0] cic_100_i; 
    cic_filter_5st
       #(.W_IN          (20),
         .W_GAIN        (14),
         .W_GAIN_STAGE  (3),
         .W_OUT         (24),
         .ORDER         (5))
    cic_filter_inst_3
       (.clk         (clk_100), 
        .reset_b     (reset_b),  
        .data_input  (fir_100_i),
        .data_output (cic_100_i));

    wire [23:0] cic_100_q; 
    cic_filter_5st
       #(.W_IN          (20),
         .W_GAIN        (14),
         .W_GAIN_STAGE  (3),
         .W_OUT         (24),
         .ORDER         (5))
    cic_filter_inst_4
       (.clk         (clk_100), 
        .reset_b     (reset_b),  
        .data_input  (fir_100_q),
        .data_output (cic_100_q));
		
		
		
		
/////////////// 20 //////////////////////////////////////////////	
	reg [19:0] dec_20_i;
	reg [19:0] dec_20_q;
	reg [19:0] dec_20_i_0;
	reg [19:0] dec_20_q_0;
	always @ (posedge clk_20, negedge reset_b)
		if(!reset_b) begin
		    dec_20_i_0 <= 20'd0;
			dec_20_q_0 <= 20'd0;
		    dec_20_i <= 20'd0;
			dec_20_q <= 20'd0;
		end else begin
		    dec_20_i_0 <= cic_100_i[21:2];
			dec_20_q_0 <= cic_100_q[21:2];
		    dec_20_i <= dec_20_i_0;
			dec_20_q <= dec_20_q_0;
		end
		   
		   
	wire [19:0] fir_20_i;	   
	fir_filter_23 fir_filter_23_inst3
	   (.clk		(clk_20), 
		.reset_b	(reset_b), 
		.data_input	(dec_20_i),
		.data_output(fir_20_i));

	wire [19:0] fir_20_q;	   
	fir_filter_23 fir_filter_23_inst4
	   (.clk		(clk_20), 
		.reset_b	(reset_b), 
		.data_input	(dec_20_q),
		.data_output(fir_20_q));		
	
		
		
		
		
	
    assign sig_out_i = fir_20_i;
    assign sig_out_q = fir_20_q;
	
	
	
	

endmodule




