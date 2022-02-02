// Copyright (c) 2019, Dmitry Shubin

module jesd204b_tx_link_layer
(
    input         reset_b,
    input         clk,
    input         sysref,
    input         sync_b,
    input  [15:0] tx_data_i,
    input  [15:0] tx_data_q,
    input         scrambler_is_on,
    output [31:0] tx_par_data,
    output  [3:0] tx_datak,
    output    [7:0] state_out,
    output [67:0] tst
);


localparam CGS_WORD = 32'hbcbcbcbc;

localparam K_WORD = 8'hbc; // K28.5 group synchronization
localparam A_WORD = 8'h7c; // K28.3 lane alignment
localparam R_WORD = 8'h1c; // K28.0 begin of multiframe
localparam F_WORD = 8'hfc; // K28.7 frame alignment
localparam Q_WORD = 8'h9c; // K28.4 start of link configuration

// параметры протокола JESD204B для передачи в ILAS
localparam K_PARAM = 8'd16;
localparam K_PARAM_M1 = 8'd15;
localparam F_PARAM = 8'd32;
localparam M_PARAM = 8'd4;


// состояния FSM для link layer
// IDLE         - состояние ожидания
// CGS          - Code Group Synchronization
// ILAS         - Initial Lane Alignment Sequence - последовательность фреймов для выравнивания
//              и проверки мультифреймов
// USER_DATA    - получение фрэймов с АЦП

reg [7:0] state, next_state;
localparam IDLE = 0;
localparam WAIT_SYNC_B = 1;
localparam CGS0 = 2;
localparam CGS1 = 3;
localparam ILAS1 = 4;
localparam ILAS2 = 5;
localparam ILAS3 = 6;
localparam ILAS4 = 7;
localparam TAIL1 = 8;
localparam TAIL2 = 9;
localparam USER_DATA = 10;

reg sysref_ff0;

reg [7:0] cnt_lmfc;
reg       cnt_lmfc_en;
reg       cnt_lmfc_rst;
reg [7:0] cnt_fc;
reg       cnt_fc_rst;


reg [15:0] dac_data3_ff0;    
always @(posedge clk, negedge reset_b)
    if (!reset_b) begin
        sysref_ff0 <= 1'b0;
        dac_data3_ff0 <= 16'h0;
    end else begin
        sysref_ff0 <= sysref;
        dac_data3_ff0 <= tx_data_q;
    end
wire sysref_edge = ({sysref, sysref_ff0} == 2'h2);


// последовательная часть FSM
always @(posedge clk, negedge reset_b)
    if (!reset_b)
        state <= IDLE;
    else
        state <= next_state;

// комбинационная часть FSM
always @(*) begin
    next_state = IDLE;
    case (state)
        IDLE :
            if (sysref_edge)
                next_state = WAIT_SYNC_B;
        WAIT_SYNC_B :
            if (sync_b == 1'b0)
                next_state = CGS0;
            else
                next_state = WAIT_SYNC_B;
        CGS0 :
            if (sync_b == 1'b1)
                next_state = CGS1;
            else
                next_state = CGS0;
        CGS1 :
            if (cnt_fc == K_PARAM)
                next_state = ILAS1;
            else
                next_state = CGS1;
        ILAS1 :
            if (cnt_fc == K_PARAM)
                next_state = ILAS2;
            else
                next_state = ILAS1;
        ILAS2 :
            if (cnt_fc == K_PARAM)
                next_state = ILAS3;
            else
                next_state = ILAS2;
        ILAS3 :
            if (cnt_fc == K_PARAM)
                next_state = ILAS4;
            else
                next_state = ILAS3;
        ILAS4 :
            if (cnt_fc == K_PARAM)
                next_state = TAIL1;
            else
                next_state = ILAS4;
        TAIL1 : next_state = TAIL2;
        TAIL2 : next_state = USER_DATA;
        USER_DATA :
            if (sync_b == 1'b0)
                next_state = CGS0;
            else
                next_state = USER_DATA;
    endcase
end

assign state_out=state;


// скремблер
wire [31:0] data_no_scr = {tx_data_i[15:0], tx_data_q[15:0]};
wire [31:0] data_scr0;
jesd204b_scrambler jesd204b_scrambler_inst1
(
    .reset_b    (reset_b),
    .clk        (clk),
    .d_in       (data_no_scr),
    .s_d_out    (data_scr0)
);

reg [31:0] data_scr;
always @(posedge clk, negedge reset_b)
    if (!reset_b) begin
        data_scr <= 32'h0;
    end else begin
        if (scrambler_is_on)
            data_scr <= data_scr0;
        else
            data_scr <= data_no_scr;
    end


// character replacement
reg [7:0] data_scr_reg;
always @(posedge clk, negedge reset_b)
    if (!reset_b) begin
        data_scr_reg <= 8'h0;
    end else begin
        data_scr_reg <= data_scr[7:0];
    end
wire flag_f_word = (data_scr[7:0]==8'hFC);
wire flag_a_word = (data_scr[7:0]==8'h7C);
wire flag_replace = (data_scr[7:0] == data_scr_reg[7:0]);

// последовательные выходны FSM
reg [31:0] tx_data;
reg [3:0] tx_ak;
always @(posedge clk, negedge reset_b)
    if(!reset_b) begin
        {tx_data, tx_ak} <= {R_WORD, R_WORD, R_WORD, R_WORD, 4'hf};
    end else begin
        case (next_state)
            IDLE            :   {tx_data, tx_ak} <= {R_WORD, R_WORD, R_WORD, R_WORD, 4'hf};
            WAIT_SYNC_B     :   {tx_data, tx_ak} <= {R_WORD, R_WORD, R_WORD, R_WORD, 4'hf};
            CGS0            :   {tx_data, tx_ak} <= {K_WORD, K_WORD, K_WORD, K_WORD, 4'hf};
            CGS1            :   {tx_data, tx_ak} <= {K_WORD, K_WORD, K_WORD, K_WORD, 4'hf};
            ILAS1           :
                case (cnt_fc)
                    8'd16   : {tx_data, tx_ak} <= {32'h1c010203, 4'b1000};
                    8'd1    : {tx_data, tx_ak} <= {32'h04050607, 4'b0000};
                    8'd2    : {tx_data, tx_ak} <= {32'h08090a0b, 4'b0000};
                    8'd3    : {tx_data, tx_ak} <= {32'h0c0d0e0f, 4'b0000};
                    8'd4    : {tx_data, tx_ak} <= {32'h10111213, 4'b0000};
                    8'd5    : {tx_data, tx_ak} <= {32'h14151617, 4'b0000};
                    8'd6    : {tx_data, tx_ak} <= {32'h18191a1b, 4'b0000};
                    8'd7    : {tx_data, tx_ak} <= {32'h1c1d1e1f, 4'b0000};
                    8'd8    : {tx_data, tx_ak} <= {32'h20212223, 4'b0000};
                    8'd9    : {tx_data, tx_ak} <= {32'h24252627, 4'b0000};
                    8'd10   : {tx_data, tx_ak} <= {32'h28292a2b, 4'b0000};
                    8'd11   : {tx_data, tx_ak} <= {32'h2c2d2e2f, 4'b0000};
                    8'd12   : {tx_data, tx_ak} <= {32'h30313233, 4'b0000};
                    8'd13   : {tx_data, tx_ak} <= {32'h34353637, 4'b0000};
                    8'd14   : {tx_data, tx_ak} <= {32'h38393a3b, 4'b0000};
                    8'd15   : {tx_data, tx_ak} <= {32'h3c3d3e7c, 4'b0001};
                    default : {tx_data, tx_ak} <= {32'h0, 4'h0};
                endcase
            ILAS2 :
                case (cnt_fc)
                    8'd16   : {tx_data, tx_ak} <= {32'h1c9c0000, 4'b1100};
                    8'd1    : {tx_data, tx_ak} <= {32'h0007011f, 4'b0000};
                    8'd2    : {tx_data, tx_ak} <= {32'h00002020, 4'b0000};
                    8'd3    : {tx_data, tx_ak} <= {32'h00000029, 4'b0000};
                    8'd4    : {tx_data, tx_ak} <= {32'h50515253, 4'b0000};
                    8'd5    : {tx_data, tx_ak} <= {32'h54555657, 4'b0000};
                    8'd6    : {tx_data, tx_ak} <= {32'h58595a5b, 4'b0000};
                    8'd7    : {tx_data, tx_ak} <= {32'h5c5d5e5f, 4'b0000};
                    8'd8    : {tx_data, tx_ak} <= {32'h60616263, 4'b0000};
                    8'd9    : {tx_data, tx_ak} <= {32'h64656667, 4'b0000};
                    8'd10   : {tx_data, tx_ak} <= {32'h68696a6b, 4'b0000};
                    8'd11   : {tx_data, tx_ak} <= {32'h6c6d6e6f, 4'b0000};
                    8'd12   : {tx_data, tx_ak} <= {32'h70717273, 4'b0000};
                    8'd13   : {tx_data, tx_ak} <= {32'h74757677, 4'b0000};
                    8'd14   : {tx_data, tx_ak} <= {32'h78797a7b, 4'b0000};
                    8'd15   : {tx_data, tx_ak} <= {32'h7c7d7e7c, 4'b0001};
                    default : {tx_data, tx_ak} <= {32'h0, 4'h0};
                endcase
            ILAS3 :
                case (cnt_fc)
                    8'd16   : {tx_data, tx_ak} <= {32'h1c818283, 4'b1000};
                    8'd1    : {tx_data, tx_ak} <= {32'h84858687, 4'b0000};
                    8'd2    : {tx_data, tx_ak} <= {32'h88898a8b, 4'b0000};
                    8'd3    : {tx_data, tx_ak} <= {32'h8c8d8e8f, 4'b0000};
                    8'd4    : {tx_data, tx_ak} <= {32'h90919293, 4'b0000};
                    8'd5    : {tx_data, tx_ak} <= {32'h94959697, 4'b0000};
                    8'd6    : {tx_data, tx_ak} <= {32'h98999a9b, 4'b0000};
                    8'd7    : {tx_data, tx_ak} <= {32'h9c9d9e9f, 4'b0000};
                    8'd8    : {tx_data, tx_ak} <= {32'ha0a1a2a3, 4'b0000};
                    8'd9    : {tx_data, tx_ak} <= {32'ha4a5a6a7, 4'b0000};
                    8'd10   : {tx_data, tx_ak} <= {32'ha8a9aaab, 4'b0000};
                    8'd11   : {tx_data, tx_ak} <= {32'hacadaeaf, 4'b0000};
                    8'd12   : {tx_data, tx_ak} <= {32'hb0b1b2b3, 4'b0000};
                    8'd13   : {tx_data, tx_ak} <= {32'hb4b5b6b7, 4'b0000};
                    8'd14   : {tx_data, tx_ak} <= {32'hb8b9babb, 4'b0000};
                    8'd15   : {tx_data, tx_ak} <= {32'hbcbdbe7c, 4'b0001};
                    default : {tx_data, tx_ak} <= {32'h0, 4'h0};
                endcase
            ILAS4 :
                case (cnt_fc)
                    8'd16   : {tx_data, tx_ak} <= {32'h1cc1c2c3, 4'b1000};
                    8'd1    : {tx_data, tx_ak} <= {32'hc4c5c6c7, 4'b0000};
                    8'd2    : {tx_data, tx_ak} <= {32'hc8c9cacb, 4'b0000};
                    8'd3    : {tx_data, tx_ak} <= {32'hcccdcecf, 4'b0000};
                    8'd4    : {tx_data, tx_ak} <= {32'hd0d1d2d3, 4'b0000};
                    8'd5    : {tx_data, tx_ak} <= {32'hd4d5d6d7, 4'b0000};
                    8'd6    : {tx_data, tx_ak} <= {32'hd8d9dadb, 4'b0000};
                    8'd7    : {tx_data, tx_ak} <= {32'hdcdddedf, 4'b0000};
                    8'd8    : {tx_data, tx_ak} <= {32'he0e1e2e3, 4'b0000};
                    8'd9    : {tx_data, tx_ak} <= {32'he4e5e6e7, 4'b0000};
                    8'd10   : {tx_data, tx_ak} <= {32'he8e9eaeb, 4'b0000};
                    8'd11   : {tx_data, tx_ak} <= {32'hecedeeef, 4'b0000};
                    8'd12   : {tx_data, tx_ak} <= {32'hf0f1f2f3, 4'b0000};
                    8'd13   : {tx_data, tx_ak} <= {32'hf4f5f6f7, 4'b0000};
                    8'd14   : {tx_data, tx_ak} <= {32'hf8f9fafb, 4'b0000};
                    8'd15   : {tx_data, tx_ak} <= {32'hfcfdfe7c, 4'b0001};
                    default : {tx_data, tx_ak} <= {32'h0, 4'h0};
                endcase
            TAIL1           : {tx_data, tx_ak} <= {32'h000000fc, 4'b0001};
            TAIL2           : {tx_data, tx_ak} <= {32'h000000fc, 4'b0001};
            USER_DATA : 
                case (cnt_fc)
                    K_PARAM_M1 : begin  if      (flag_replace)   {tx_data, tx_ak} <= {data_scr[31:8], A_WORD, 4'h1};
                                        else if (flag_a_word)    {tx_data, tx_ak} <= {data_scr[31:8], A_WORD, 4'h1};
                                        else                     {tx_data, tx_ak} <= {data_scr[31:0], 4'h0}; end
                    default :    begin  if      (flag_replace)   {tx_data, tx_ak} <= {data_scr[31:8], F_WORD, 4'h1};
                                        else if (flag_f_word)    {tx_data, tx_ak} <= {data_scr[31:8], F_WORD, 4'h1};
                                        else                     {tx_data, tx_ak} <= {data_scr[31:0], 4'h0}; end
                endcase

        endcase
    end


// последовательные выходны FSM
// always @(posedge clk, negedge reset_b)
    // if(!reset_b) begin
        // {cnt_lmfc_en, cnt_fc_rst} <= {1'b0, 1'b1};
    // end else
        // case (next_state)
            // IDLE         :  {cnt_lmfc_en, cnt_fc_rst} <= {1'b0, sysref_edge};
            // WAIT_SYNC_B :  {cnt_lmfc_en, cnt_fc_rst} <= {1'b0, sysref_edge}; 
            // CGS0         :  {cnt_lmfc_en, cnt_fc_rst} <= {cnt_lmfc_en, sysref_edge};
            // CGS1         :  {cnt_lmfc_en, cnt_fc_rst} <= (cnt_fc==K_PARAM_M1) ? {1'b1, 1'b1} : {1'b0, 1'b0}; 
            // ILAS1         :  {cnt_lmfc_en, cnt_fc_rst} <= (cnt_fc==K_PARAM_M1) ? {1'b1, 1'b1} : {1'b0, 1'b0};
            // ILAS2         :  {cnt_lmfc_en, cnt_fc_rst} <= (cnt_fc==K_PARAM_M1) ? {1'b1, 1'b1} : {1'b0, 1'b0};
            // ILAS3         :  {cnt_lmfc_en, cnt_fc_rst} <= (cnt_fc==K_PARAM_M1) ? {1'b1, 1'b1} : {1'b0, 1'b0};
            // ILAS4         :  {cnt_lmfc_en, cnt_fc_rst} <= (cnt_fc==K_PARAM_M1) ? {1'b1, 1'b1} : {1'b0, 1'b0};
            // USER_DATA     :  {cnt_lmfc_en, cnt_fc_rst} <= (cnt_fc==K_PARAM_M1) ? {1'b1, 1'b1} : {1'b0, 1'b0}; 
        // endcase

always @(posedge clk, negedge reset_b)
    if (!reset_b)
        cnt_fc <= 8'h1;
    else
        if (sysref_edge)
            cnt_fc <= 8'h1;
        else begin 
            if (cnt_fc==K_PARAM)
                cnt_fc <= 8'h1;
            else
                cnt_fc <= cnt_fc + 8'h1;
        end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////



assign tx_par_data = {tx_data[7:0], tx_data[15:8], tx_data[23:16], tx_data[31:24]};
assign tx_datak    = {tx_ak[0], tx_ak[1], tx_ak[2], tx_ak[3]};     
    
reg [31:0] tx_par_data_tst;     
reg [3:0] tx_datak_tst;     
always @(posedge clk, negedge reset_b)
    if(!reset_b) begin
        tx_par_data_tst <= 32'd0;     
        tx_datak_tst <= 4'd0; 
    end else begin    
        tx_par_data_tst <= {tx_data[7:0], tx_data[15:8], tx_data[23:16], tx_data[31:24]};
        tx_datak_tst    <= {tx_ak[0], tx_ak[1], tx_ak[2], tx_ak[3]};     
    end
    
    
assign tst = {
clk,
reset_b,
sysref,
sync_b,
8'd0,
cnt_fc[7:0],
tx_par_data_tst[31:0],
tx_datak_tst[3:0],
state[7:0],
sysref_edge,
3'd0
};

endmodule