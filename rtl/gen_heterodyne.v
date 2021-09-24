
`timescale 1ns / 10ps

module gen_heterodyne
   (input clk, 
    input reset_b, 
	output reg [15:0] het_1030_i,
	output reg [15:0] het_1030_q,
	output reg [15:0] het_1090_i,
	output reg [15:0] het_1090_q
	);



////////////////////// 40 / 20 ///////////////////////////////////////
	wire signed [19:0] arr_20_i [0:49];
	wire signed [19:0] arr_20_q [0:49];

	assign arr_20_i[0 ] =  20'sd471850;
	assign arr_20_i[1 ] =  20'sd252830;
	assign arr_20_i[2 ] = -20'sd200904;
	assign arr_20_i[3 ] = -20'sd468130;
	assign arr_20_i[4 ] = -20'sd300768;
	assign arr_20_i[5 ] =  20'sd145810;
	assign arr_20_i[6 ] =  20'sd457026;
	assign arr_20_i[7 ] =  20'sd343964;
	assign arr_20_i[8 ] = -20'sd88416;
	assign arr_20_i[9 ] = -20'sd438715;
	assign arr_20_i[10] = -20'sd381735;
	assign arr_20_i[11] =  20'sd29628;
	assign arr_20_i[12] =  20'sd413485;
	assign arr_20_i[13] =  20'sd413485;
	assign arr_20_i[14] =  20'sd29628;
	assign arr_20_i[15] = -20'sd381735;
	assign arr_20_i[16] = -20'sd438715;
	assign arr_20_i[17] = -20'sd88416;
	assign arr_20_i[18] =  20'sd343964;
	assign arr_20_i[19] =  20'sd457026;
	assign arr_20_i[20] =  20'sd145810;
	assign arr_20_i[21] = -20'sd300768;
	assign arr_20_i[22] = -20'sd468130;
	assign arr_20_i[23] = -20'sd200904;
	assign arr_20_i[24] =  20'sd252830;
	assign arr_20_i[25] =  20'sd471850;
	assign arr_20_i[26] =  20'sd252830;
	assign arr_20_i[27] = -20'sd200904;
	assign arr_20_i[28] = -20'sd468130;
	assign arr_20_i[29] = -20'sd300768;
	assign arr_20_i[30] =  20'sd145810;
	assign arr_20_i[31] =  20'sd457026;
	assign arr_20_i[32] =  20'sd343964;
	assign arr_20_i[33] = -20'sd88416;
	assign arr_20_i[34] = -20'sd438715;
	assign arr_20_i[35] = -20'sd381735;
	assign arr_20_i[36] =  20'sd29628;
	assign arr_20_i[37] =  20'sd413485;
	assign arr_20_i[38] =  20'sd413485;
	assign arr_20_i[39] =  20'sd29628;
	assign arr_20_i[40] = -20'sd381735;
	assign arr_20_i[41] = -20'sd438715;
	assign arr_20_i[42] = -20'sd88416;
	assign arr_20_i[43] =  20'sd343964;
	assign arr_20_i[44] =  20'sd457026;
	assign arr_20_i[45] =  20'sd145810;
	assign arr_20_i[46] = -20'sd300768;
	assign arr_20_i[47] = -20'sd468130;
	assign arr_20_i[48] = -20'sd200904;
	assign arr_20_i[49] =  20'sd252830;	

	assign arr_20_q[0 ] =  20'sd0;
	assign arr_20_q[1 ] =  20'sd398397;
	assign arr_20_q[2 ] =  20'sd426943;
	assign arr_20_q[3 ] =  20'sd59138;
	assign arr_20_q[4 ] = -20'sd363567;
	assign arr_20_q[5 ] = -20'sd448756;
	assign arr_20_q[6 ] = -20'sd117345;
	assign arr_20_q[7 ] =  20'sd323004;
	assign arr_20_q[8 ] =  20'sd463493;
	assign arr_20_q[9 ] =  20'sd173700;
	assign arr_20_q[10] = -20'sd277347;
	assign arr_20_q[11] = -20'sd470919;
	assign arr_20_q[12] = -20'sd227316;
	assign arr_20_q[13] =  20'sd227316;
	assign arr_20_q[14] =  20'sd470919;
	assign arr_20_q[15] =  20'sd277347;
	assign arr_20_q[16] = -20'sd173700;
	assign arr_20_q[17] = -20'sd463493;
	assign arr_20_q[18] = -20'sd323004;
	assign arr_20_q[19] =  20'sd117345;
	assign arr_20_q[20] =  20'sd448756;
	assign arr_20_q[21] =  20'sd363567;
	assign arr_20_q[22] = -20'sd59138;
	assign arr_20_q[23] = -20'sd426943;
	assign arr_20_q[24] = -20'sd398397;
	assign arr_20_q[25] =  20'sd0;
	assign arr_20_q[26] =  20'sd398397;
	assign arr_20_q[27] =  20'sd426943;
	assign arr_20_q[28] =  20'sd59138;
	assign arr_20_q[29] = -20'sd363567;
	assign arr_20_q[30] = -20'sd448756;
	assign arr_20_q[31] = -20'sd117345;
	assign arr_20_q[32] =  20'sd323004;
	assign arr_20_q[33] =  20'sd463493;
	assign arr_20_q[34] =  20'sd173700;
	assign arr_20_q[35] = -20'sd277347;
	assign arr_20_q[36] = -20'sd470919;
	assign arr_20_q[37] = -20'sd227316;
	assign arr_20_q[38] =  20'sd227316;
	assign arr_20_q[39] =  20'sd470919;
	assign arr_20_q[40] =  20'sd277347;
	assign arr_20_q[41] = -20'sd173700;
	assign arr_20_q[42] = -20'sd463493;
	assign arr_20_q[43] = -20'sd323004;
	assign arr_20_q[44] =  20'sd117345;
	assign arr_20_q[45] =  20'sd448756;
	assign arr_20_q[46] =  20'sd363567;
	assign arr_20_q[47] = -20'sd59138;
	assign arr_20_q[48] = -20'sd426943;
	assign arr_20_q[49] = -20'sd398397;


	reg [5:0] cnt20;
	always @ (posedge clk, negedge reset_b)
		if(!reset_b) begin
		    cnt20 <= 6'd0;
		end else begin
		    if (cnt20==6'd49)
				cnt20 <= 6'd0;	    
			else 
				cnt20 <= cnt20 + 6'd1;
		end

	reg [5:0] cnt40;
	always @ (posedge clk, negedge reset_b)
		if(!reset_b) begin
		    cnt40 <= 6'd0;
		end else begin
		    if (cnt40==6'd48)
				cnt40 <= 6'd0;	    
			else 
				cnt40 <= cnt40 + 6'd2;
		end

	
    reg [19:0] het_20_i;
	reg [19:0] het_20_q;
	reg [19:0] het_40_i;
	reg [19:0] het_40_q;
	always @ (posedge clk, negedge reset_b)
		if(!reset_b) begin
			het_20_i <= 20'd0;
			het_20_q <= 20'd0;
			het_40_i <= 20'd0;
			het_40_q <= 20'd0;
		end else begin
			het_20_i <= arr_20_i[cnt20];
			het_20_q <= arr_20_q[cnt20];
			het_40_i <= arr_20_i[cnt40];
			het_40_q <= arr_20_q[cnt40];
		end
	
	reg [15:0] het_1030_i_0;
	reg [15:0] het_1030_q_0;
	reg [15:0] het_1090_i_0;
	reg [15:0] het_1090_q_0;
	always @ (posedge clk, negedge reset_b)
		if(!reset_b) begin
			het_1030_i_0 <= 16'd0;
			het_1030_q_0 <= 16'd0;
			het_1090_i_0 <= 16'd0;
			het_1090_q_0 <= 16'd0;
		end else begin
			het_1030_i_0 <= het_20_q[19:4] + het_20_q[3];
			het_1030_q_0 <= het_20_i[19:4] + het_20_i[3];
			het_1090_i_0 <= het_40_i[19:4] + het_40_i[3];
			het_1090_q_0 <= het_40_q[19:4] + het_40_q[3];
		end	
		
		
		
		
/////////////////////////// various /////////////////////////////////////////////////////////////		
    wire signed [15:0] s_i_0;
    wire signed [15:0] s_q_0;
    dds_signal_generator#(
        .WIDTH_NCO      (16),
        .WIDTH_PHASE    (32),
        .WIDHT_ADDR_ROM (14),
        .INIT_ROM_FILE  ("sin_nco_14_16.mem")) 
    dds_signal_generator_inst1(
        .clk            (clk), 
        .reset_b        (reset_b), 
        .start          (1'b1), 
        .frequency      (32'd3285649981), // +95.6250
        .phase          (32'd0), 
        .amplitude      (16'h7000), 
        .real_sig       (s_i_0[15:0]),
        .imag_sig       (s_q_0[15:0])
        );  
		
		
    wire signed [15:0] s_i_1;
    wire signed [15:0] s_q_1;
    dds_signal_generator#(
        .WIDTH_NCO      (16),
        .WIDTH_PHASE    (32),
        .WIDHT_ADDR_ROM (14),
        .INIT_ROM_FILE  ("sin_nco_14_16.mem")) 
    dds_signal_generator_inst2(
        .clk            (clk), 
        .reset_b        (reset_b), 
        .start          (1'b1), 
        .frequency      (32'd1052266988), // +30.6250
        .phase          (32'd0), 
        .amplitude      (16'h7000), 
        .real_sig       (s_i_1[15:0]),
        .imag_sig       (s_q_1[15:0])
        );   	
			
		
		
		
		
		
	always @ (posedge clk, negedge reset_b)
		if(!reset_b) begin
			het_1030_i <= 16'd0;
			het_1030_q <= 16'd0;
			het_1090_i <= 16'd0;
			het_1090_q <= 16'd0;
		end else begin
			het_1030_i <= s_i_0;  //   het_1030_i_0;   // 
			het_1030_q <= s_q_0;  //   het_1030_q_0;   // 
			het_1090_i <= s_i_1;  //   het_1090_i_0;   // 
			het_1090_q <= s_q_1;  //   het_1090_q_0;   // 
		end		
		
		

		
		
		


		
endmodule





















