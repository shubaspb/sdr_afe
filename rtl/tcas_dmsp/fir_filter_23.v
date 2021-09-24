
`timescale 1ns / 10ps

module fir_filter_23
   (input clk, 
    input reset_b, 
    input [19:0] data_input,
	output reg [19:0] data_output);



	
	// ========= Initial file with coefficients filter ================
	wire signed [20:0] coeff [0:11];

    assign coeff [0 ] = 21'b000000010000010011010;       // 21'b000000001001110010101;
    assign coeff [1 ] = 21'b111111110010101010011;       // 21'b111111110111001000001;
    assign coeff [2 ] = 21'b111111100010010111101;       // 21'b111111101110101101000;
    assign coeff [3 ] = 21'b000000110100100001001;       // 21'b000000100010001110001;
    assign coeff [4 ] = 21'b000000111011000100010;       // 21'b000000100000010010010;
    assign coeff [5 ] = 21'b111101100001010110100;       // 21'b111110011001101000111;
    assign coeff [6 ] = 21'b111110110011100111110;       // 21'b111111011111000101000;
    assign coeff [7 ] = 21'b000101110011001101001;       // 21'b000011101111001011100;
    assign coeff [8 ] = 21'b000000101111001001100;       // 21'b111111101111101011100;
    assign coeff [9 ] = 21'b110011101100001110100;       // 21'b110111110110111011001;
    assign coeff [10] = 21'b111111110000001001011;       // 21'b000010011110011101110;
	assign coeff [11] = 21'b011110000011111010000;       // 21'b011001000011001010111;



/////////////// Line delay for input signal ///////////////////////////////////////////////////////
	reg signed [20:0] del [0:23];

	always @ (posedge clk, negedge reset_b)
	begin : line_delay
	integer i; 
		if(!reset_b) begin
		    for(i=0; i < 24; i=i+1) 
			    del[i] <= 21'd0;
		end else begin
		    del[0] <= { {data_input[19]} , {data_input} };
		    for(i=0; i < 23; i=i+1) 
			    del[i+1] <= del[i];
		end
	end


	reg signed [20:0] adds [0:11];
	always @ (posedge clk, negedge reset_b)
	begin : adders
	integer i; 
		if(!reset_b) begin
		    for(i=0; i < 12; i=i+1) 
			    adds[i] <= 21'd0;
		end else begin
		    adds[0 ] <= del[0 ] + del[23];
			adds[1 ] <= del[1 ] + del[22];
			adds[2 ] <= del[2 ] + del[21];
			adds[3 ] <= del[3 ] + del[20];
			adds[4 ] <= del[4 ] + del[19];
			adds[5 ] <= del[5 ] + del[18];
			adds[6 ] <= del[6 ] + del[17];
			adds[7 ] <= del[7 ] + del[16];
			adds[8 ] <= del[8 ] + del[15];
			adds[9 ] <= del[9 ] + del[14];
			adds[10] <= del[10] + del[13];
			adds[11] <= del[11] + del[12];
		end
	end


////////////////// Multiplied by coefficients /////////////////////////////////////////
    reg signed [40:0] m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11;
	always @ (posedge clk, negedge reset_b)
		if(!reset_b) begin
		    {m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11} <= {(12*41){1'b0}};
		end else begin
		    m0  <= adds[0 ] * coeff[0 ];
			m1  <= adds[1 ] * coeff[1 ];
			m2  <= adds[2 ] * coeff[2 ];
			m3  <= adds[3 ] * coeff[3 ];
			m4  <= adds[4 ] * coeff[4 ];
			m5  <= adds[5 ] * coeff[5 ];
			m6  <= adds[6 ] * coeff[6 ];
			m7  <= adds[7 ] * coeff[7 ];
			m8  <= adds[8 ] * coeff[8 ];
			m9  <= adds[9 ] * coeff[9 ];
			m10 <= adds[10] * coeff[10];
			m11 <= adds[11] * coeff[11];
		end
	
    reg signed [40:0] s0, s1, s2, s3;
	always @ (posedge clk, negedge reset_b)
		if(!reset_b) begin
		    {s0, s1, s2, s3} <= {41'd0, 41'd0, 41'd0, 41'd0};
			data_output <= 20'd0;
		end else begin
		    s0  <= m0[40:10] + m1[40:10] + m2[40:10] + m3[40:10];
			s1  <= m4[40:10] + m5[40:10] + m6[40:10] + m7[40:10];
			s2  <= m8[40:10] + m9[40:10] + m10[40:10] + m11[40:10];
			s3  <= s0 + s1 + s2;
			data_output <= s3[30:11]+s3[10];
		end


endmodule

