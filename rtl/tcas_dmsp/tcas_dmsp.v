

module tcas_dmsp
    (
    // iH.x.b
    input         reset_b,         // asyncronous reset
    input         clk_100,         // clock 100 MHz
    input         clk_20,          // clock 20 MHz
    // iS-H.Tx                         
    input         ant_top_bot,     // sel antenna - top/bottom
    input  [2:0]  dir_intrg,       // request direction
    // iH.i                            
    input  [15:0] sig_rx_1_i,      // input channel 1, real part
    input  [15:0] sig_rx_1_q,      // input channel 1, imag part
    input  [15:0] sig_rx_2_i,      // input channel 2, real part
    input  [15:0] sig_rx_2_q,      // input channel 2, imag part
    input  [15:0] sig_rx_3_i,      // input channel 3, real part
    input  [15:0] sig_rx_3_q,      // input channel 3, imag part
    input  [15:0] sig_rx_4_i,      // input channel 4, real part
    input  [15:0] sig_rx_4_q,      // input channel 4, imag part
    // iH.f                            
    input  [15:0] cor_rx_1_i,      // correction coefficients channel 1, real part
    input  [15:0] cor_rx_1_q,      // correction coefficients channel 1, imag part
    input  [15:0] cor_rx_2_i,      // correction coefficients channel 2, real part
    input  [15:0] cor_rx_2_q,      // correction coefficients channel 2, imag part
    input  [15:0] cor_rx_3_i,      // correction coefficients channel 3, real part
    input  [15:0] cor_rx_3_q,      // correction coefficients channel 3, imag part
    input  [15:0] cor_rx_4_i,      // correction coefficients channel 4, real part
    input  [15:0] cor_rx_4_q,      // correction coefficients channel 4, imag part
    // iH.k                            
    input  [15:0] get_i,        // Heterodyne, real part
    input  [15:0] get_q,        // Heterodyne, imag part
    // iH-S.Rx.Sync.up
    output reg [15:0] ampl_main,   // diagram MAIN
    output reg [15:0] ampl_omega,  // diagram OMEGA
    output     [8:0]  bearing,     // bearing (peleng), [degrees]
    // iH-S.Rx.Omni.up 
    output reg [15:0] ampl_omni,   // diagram OMNI
    output     [67:0] tst1,
    output     [67:0] tst2
    );  
    
    ///////////////// DDC //////////////////////////////////////////////////
    wire [15:0] demod_1_i;
    wire [15:0] demod_1_q;   
    ddc_dmsp ddc_dmsp_inst1(
        .clk       (clk_100   ),  
        .reset_b   (reset_b   ),       
        .get_i     (get_i     ),
        .get_q     (get_q     ),
        .sig_in_i  (sig_rx_1_i),
        .sig_in_q  (sig_rx_1_q),
        .sig_out_i (demod_1_i ),
        .sig_out_q (demod_1_q )
        );
    
    wire [15:0] demod_2_i;
    wire [15:0] demod_2_q;   
    ddc_dmsp ddc_dmsp_inst2(
        .clk       (clk_100   ),  
        .reset_b   (reset_b   ),       
        .get_i     (get_i     ),
        .get_q     (get_q     ),
        .sig_in_i  (sig_rx_2_i),
        .sig_in_q  (sig_rx_2_q),
        .sig_out_i (demod_2_i ),
        .sig_out_q (demod_2_q )
        );
    
    wire [15:0] demod_3_i;
    wire [15:0] demod_3_q;   
    ddc_dmsp ddc_dmsp_inst3(
        .clk       (clk_100   ),  
        .reset_b   (reset_b   ),       
        .get_i     (get_i     ),
        .get_q     (get_q     ),
        .sig_in_i  (sig_rx_3_i),
        .sig_in_q  (sig_rx_3_q),
        .sig_out_i (demod_3_i ),
        .sig_out_q (demod_3_q )
        );
    
    wire [15:0] demod_4_i;
    wire [15:0] demod_4_q;   
    ddc_dmsp ddc_dmsp_inst4(
        .clk       (clk_100   ),  
        .reset_b   (reset_b   ),       
        .get_i     (get_i     ),
        .get_q     (get_q     ),
        .sig_in_i  (sig_rx_4_i),
        .sig_in_q  (sig_rx_4_q),
        .sig_out_i (demod_4_i ),
        .sig_out_q (demod_4_q )
        );
    ////////////////////////////////////////////////////////////////////////
    
    
    ///////////////// AM-PH correction /////////////////////////////////////
    wire [15:0] corr_1_i;
    wire [15:0] corr_1_q;
    complex_mult #(.W(16)) complex_mult_rxst11(
        .reset_b (reset_b    ),
        .clk     (clk_20     ),
        .a_in_i  (demod_1_i  ),
        .a_in_q  (demod_1_q  ),
        .b_in_i  (cor_rx_1_i ),
        .b_in_q  (cor_rx_1_q ),
        .out_i   (corr_1_i   ),
        .out_q   (corr_1_q   ));
    
    wire [15:0] corr_2_i;
    wire [15:0] corr_2_q;
    complex_mult #(.W(16)) complex_mult_rxst12(
        .reset_b (reset_b    ),
        .clk     (clk_20     ),
        .a_in_i  (demod_2_i  ),
        .a_in_q  (demod_2_q  ),
        .b_in_i  (cor_rx_2_i ),
        .b_in_q  (cor_rx_2_q ),
        .out_i   (corr_2_i   ),
        .out_q   (corr_2_q   ));
    
    wire [15:0] corr_3_i;
    wire [15:0] corr_3_q;
    complex_mult #(.W(16)) complex_mult_rxst13(
        .reset_b (reset_b    ),
        .clk     (clk_20     ),
        .a_in_i  (demod_3_i  ),
        .a_in_q  (demod_3_q  ),
        .b_in_i  (cor_rx_3_i ),
        .b_in_q  (cor_rx_3_q ),
        .out_i   (corr_3_i   ),
        .out_q   (corr_3_q   ));
    
    wire [15:0] corr_4_i;
    wire [15:0] corr_4_q;
    complex_mult #(.W(16)) complex_mult_rxst14(
        .reset_b (reset_b    ),
        .clk     (clk_20     ),
        .a_in_i  (demod_4_i  ),
        .a_in_q  (demod_4_q  ),
        .b_in_i  (cor_rx_4_i ),
        .b_in_q  (cor_rx_4_q ),
        .out_i   (corr_4_i   ),
        .out_q   (corr_4_q   ));
    //////////////////////////////////////////////////////////////////////////
    
    
    /////////////////// beamform rx //////////////////////////////////////////
    wire [23:0] main_i_24; 
    wire [23:0] main_q_24;
    wire [23:0] omega_i_24;
    wire [23:0] omega_q_24;
    wire [23:0] omni_i_24; 
    wire [23:0] omni_q_24;
    beamform_rx beamform_rx_inst(
        .clk        (clk_20      ),  
        .reset_b    (reset_b     ),       
        .ant_top_bot(ant_top_bot ),
        .dir_intrg  (dir_intrg   ),
        .ch_1_i     (corr_1_i    ),
        .ch_1_q     (corr_1_q    ),
        .ch_2_i     (corr_2_i    ),
        .ch_2_q     (corr_2_q    ),
        .ch_3_i     (corr_3_i    ),
        .ch_3_q     (corr_3_q    ),
        .ch_4_i     (corr_4_i    ),
        .ch_4_q     (corr_4_q    ),
        .main_i     (main_i_24   ),
        .main_q     (main_q_24   ),
        .omega_i    (omega_i_24  ),
        .omega_q    (omega_q_24  ),
        .omni_i     (omni_i_24   ),
        .omni_q     (omni_q_24   )
        );
    
    wire [23:0] main_ampl_24;
    ampl_dmsp ampl_dmsp_inst1
        (.reset_b (reset_b      ),
        .clk     (clk_20       ),
        .sig_i   (main_i_24    ),
        .sig_q   (main_q_24    ),
        .ampl    (main_ampl_24 )); 
    
    wire [23:0] omega_ampl_24;
    ampl_dmsp ampl_dmsp_inst2
        (.reset_b (reset_b      ),
        .clk     (clk_20       ),
        .sig_i   (omega_i_24    ),
        .sig_q   (omega_q_24    ),
        .ampl    (omega_ampl_24 )); 
    
    wire [23:0] omni_ampl_24;
    ampl_dmsp ampl_dmsp_inst3
        (.reset_b (reset_b      ),
        .clk     (clk_20       ),
        .sig_i   (omni_i_24    ),
        .sig_q   (omni_q_24    ),
        .ampl    (omni_ampl_24 )); 
    
    
    always @ (posedge clk_20, negedge reset_b)
        if (~reset_b) begin
                ampl_main  <= 16'd0;
                ampl_omega <= 16'd0;
                ampl_omni  <= 16'd0;
        end else begin 
                ampl_main  <= main_ampl_24[23:8] + main_ampl_24[7];
                ampl_omega <= omega_ampl_24[23:8] + omega_ampl_24[7]; 
                ampl_omni  <= omni_ampl_24[23:8] + omni_ampl_24[7];  
            end
    ////////////////////////////////////////////////////////////////////////////
    
    
    ///////////////// peleng ///////////////////////////////////////////////////
    wire [23:0] corr_1_i_24 = {corr_1_i, 8'd0};
    wire [23:0] corr_1_q_24 = {corr_1_q, 8'd0};
    wire [23:0] corr_2_i_24 = {corr_2_i, 8'd0};
    wire [23:0] corr_2_q_24 = {corr_2_q, 8'd0};
    wire [23:0] corr_3_i_24 = {corr_3_i, 8'd0};
    wire [23:0] corr_3_q_24 = {corr_3_q, 8'd0};
    wire [23:0] corr_4_i_24 = {corr_4_i, 8'd0};
    wire [23:0] corr_4_q_24 = {corr_4_q, 8'd0};
    peleng peleng_inst(
        .reset_b(reset_b     ),
        .clk    (clk_20      ),
        .ant_top_bot (ant_top_bot),
        .sig1_i (corr_1_i_24 ),            
        .sig1_q (corr_1_q_24 ),              
        .sig2_i (corr_2_i_24 ),            
        .sig2_q (corr_2_q_24 ),    
        .sig3_i (corr_3_i_24 ),            
        .sig3_q (corr_3_q_24 ),        
        .sig4_i (corr_4_i_24 ),            
        .sig4_q (corr_4_q_24 ),        
        .angle  (bearing     ));
    ////////////////////////////////////////////////////////////////////////////  
    
    assign tst1[67:0] = {
        clk_100, 
        clk_20, 
        ampl_main[15:0],
        ampl_omega[15:0],
        tst_sig_rx_1_i[15:0],
        tst_sig_rx_1_q[15:0]
        };
    
    assign tst2[67:0] = {
        clk_100,
        clk_20,
        tst_sig_rx_2_i[15:0],
        tst_sig_rx_2_q[15:0],
        tst_sig_rx_3_i[15:0],
        tst_sig_rx_3_q[15:0]
        };
    
    reg  [15:0] tst_sig_rx_1_i;
    reg  [15:0] tst_sig_rx_1_q;
    reg  [15:0] tst_sig_rx_2_i;
    reg  [15:0] tst_sig_rx_2_q;
    reg  [15:0] tst_sig_rx_3_i;
    reg  [15:0] tst_sig_rx_3_q;
    
    always @(posedge clk_100)
        begin
            tst_sig_rx_1_i <= sig_rx_1_i[15:0];
            tst_sig_rx_1_q <= sig_rx_1_q[15:0];
            tst_sig_rx_2_i <= sig_rx_2_i[15:0];
            tst_sig_rx_2_q <= sig_rx_2_q[15:0];
            tst_sig_rx_3_i <= sig_rx_3_i[15:0];
            tst_sig_rx_3_q <= sig_rx_3_q[15:0];
        end
    
endmodule




