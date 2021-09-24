
//*************************************************************************************
`timescale 1ns / 10ps


module tcas_dmsp_tb 
   #(parameter WIDTH_IN = 24,                // !!! WIDTH_OUT < WIDTH_IN + WIDTH_GAIN_STAGE*n_stages
               WIDTH_OUT = 24,		   
               LENGTH_IN = 10000,            // length input signal testbench
               LENGTH_OUT = 1900,             // length output signal testbench
               DELAY_module = 1,             // delay of module (must be bigger than real delay)
			   INPUT_FILE = "input_tb.dat",   // length signal in file must be equal LENGTH_IN
			   INPUT_FILE_I = "input_i_tb.dat",
			   INPUT_FILE_Q = "input_q_tb.dat",
			   OUTPUT_FILE_I = "output_i_tb.dat",
			   OUTPUT_FILE_Q = "output_q_tb.dat",
			   OUTPUT_FILE_MAG = "output_mag.dat")


   (output reg [WIDTH_OUT-1:0] sig_rom_out_1,
    output reg [WIDTH_OUT-1:0] sig_rom_out_2,
	output reg [WIDTH_OUT-1:0] sig_rom_out_3);


   

reg clk_125;
reg clk_25;
reg clk_100;
reg clk_20;
reg reset_b;
	
always
  #4 clk_125 = ~clk_125;
always
  #20 clk_25 = ~clk_25;
always
  #5 clk_100 = ~clk_100;
always
  #25 clk_20 = ~clk_20;
  
  
initial
begin
  clk_125 = 1;
  #1 clk_25 = 1;
  #1 clk_100 = 1;
  #1 clk_20 = 1;
  reset_b = 0;
  #20 reset_b = 1; 
end 



///////////////// Generate input signals ///////////////////////////////
reg [WIDTH_IN-1:0] rom_in_1 [0:LENGTH_IN-1]; 
reg [WIDTH_IN-1:0] rom_in_2 [0:LENGTH_IN-1]; 
initial begin 
$readmemb(INPUT_FILE_I, rom_in_1);  
$readmemb(INPUT_FILE_Q, rom_in_2);
end

reg [WIDTH_IN-1:0] input_signal_i; 
reg [WIDTH_IN-1:0] input_signal_q; 
reg [31:0] cnt_rom_in_1 = {(32){1'b0}};
always @(posedge clk_125) begin
   input_signal_i = rom_in_1[cnt_rom_in_1];
   input_signal_q = rom_in_2[cnt_rom_in_1];
   cnt_rom_in_1 = cnt_rom_in_1 + 1;
end
/////////////////////////////////////////////////////////////////////////





///////////////////////////////// Module //////////////////////////////////////////////////////
    wire signed [15:0] s_i_1;
    wire signed [15:0] s_q_1;
    dds_signal_generator#(
        .WIDTH_NCO      (16),
        .WIDTH_PHASE    (32),
        .WIDHT_ADDR_ROM (14),
        .INIT_ROM_FILE  ("sin_nco_14_16.mem")) 
    dds_signal_generator_inst2(
        .clk            (clk_125), 
        .reset_b        (reset_b), 
        .start          (1'b1), 
        .frequency      (32'd3607772529), // -20    (32'd240518167), //  7    (32'd687194767),   // 20     //
        .phase          (32'd0), 
        .amplitude      (16'h7000), 
        .real_sig       (s_i_1[15:0]),
        .imag_sig       (s_q_1[15:0])
        );  	

		
	wire [19:0] demod_1090_i;
    wire [19:0] demod_1090_q;   
    ddc_dmsp_125 ddc_dmsp_125_inst1(
	    .link_clk  (clk_125  	),
        .clk_125   (clk_125  	),  
		.clk_25    (clk_25  	),
		.clk_100   (clk_100 	),
		.clk_20    (clk_20  	),
        .reset_b   (reset_b   	),       
        .get_i     (s_i_1     	),
        .get_q     (s_q_1     	),
        .sig_in_i  (input_signal_i[23:8]	),
        .sig_in_q  (input_signal_q[23:8]	),
        .sig_out_i (demod_1090_i 	),
        .sig_out_q (demod_1090_q 	)
        );
		
    wire [23:0] sig_i = {demod_1090_i, 4'd0};
    wire [23:0] sig_q = {demod_1090_q, 4'd0};
    wire [23:0] magnitude;
	mag_complex mag_complex_inst(
		.reset_b	(reset_b	),
		.clk		(clk_20		),
		.sig_i		(sig_i		),
		.sig_q		(sig_q		),
		.magnitude  (magnitude  )	
    );  	
		
/////////////////////////////////////////////////////////////////////////////////////////////




// ========= Write output files ====================================================
// --------- counter for addr output roms --------------------------------------------
reg [31:0] ind;
reg [31:0] cnt_rom = {(32){1'b0}};

always @(posedge clk_20, negedge reset_b) begin : counter_out
   if (!reset_b) 
      begin
      cnt_rom <= {(32){1'b0}};
      ind <= {(32){1'b0}}; 
	  end
   else if (cnt_rom <= DELAY_module)
      begin
      cnt_rom <= cnt_rom + 1;
      ind <= {(32){1'b0}}; 
	  end
   else
      begin
      cnt_rom <= cnt_rom + 1;	   
      ind <= cnt_rom-DELAY_module;
	  end
end
	
// ----------- Write output rom for sinus ------------------------------------------
reg [WIDTH_OUT-1:0] rom_0 [0:LENGTH_OUT-1];
	
always @(posedge clk_20, negedge reset_b) begin : ROM_sin_write
   rom_0[ind] = {demod_1090_i, 4'd0}; 
   sig_rom_out_1 <= rom_0[ind];
   if (ind==LENGTH_OUT-1)
      $writememh(OUTPUT_FILE_I, rom_0, 0, LENGTH_OUT-1); 
end

// ----------- Write output rom for cosinus ------------------------------------------
reg [WIDTH_OUT-1:0] rom_1 [0:LENGTH_OUT-1];
	
always @(posedge clk_20, negedge reset_b) begin : ROM_cos_write
   rom_1[ind] = {demod_1090_q, 4'd0}; 
   sig_rom_out_2 <= rom_1[ind];
   if (ind==LENGTH_OUT-1)
      $writememh(OUTPUT_FILE_Q, rom_1, 0, LENGTH_OUT-1); 
end

// ----------- (magnitude ------------------------------------------
reg [WIDTH_OUT-1:0] rom_2 [0:LENGTH_OUT-1];
	
always @(posedge clk_20, negedge reset_b) begin : ROM_magnitude
   rom_2[ind] = magnitude; 
   sig_rom_out_3 <= rom_2[ind];
   if (ind==LENGTH_OUT-1)
      $writememh(OUTPUT_FILE_MAG, rom_2, 0, LENGTH_OUT-1); 
end


endmodule
