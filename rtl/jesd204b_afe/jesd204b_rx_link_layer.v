// Copyright (c) 2019, Dmitry Shubin

module jesd204b_rx_link_layer
(
    input         reset_b,
    input         clk,

    // параллельные данные до упорядочивания
    input  [31:0] rx_parallel_data,
    input   [3:0] rx_datak,
    input         sysref,
    output        sync_b,
    output        pattern_align_en,

    output [15:0] adc_data0,
    output [15:0] adc_data1,
    output        data_ready,

    input         scrambler_is_on,
    output [31:0] err_link_rx,
    // отладочный вектор на логический анализатор
    output [67:0] tst_fsm0,
    output [67:0] tst_fsm1,
    output [67:0] tst_fsm2,
    output [67:0] tst_fsm3,
    output [67:0] tst
);

wire [31:0] rx_dat = rx_parallel_data;


localparam K_PARAM = 8'd16;
localparam K_PARAM_M1 = 8'd15;


localparam CGS_WORD = 32'hbcbcbcbc;

localparam K_WORD = 8'hbc; // K28.5 group synchronization
localparam A_WORD = 8'h7c; // K28.3 lane alignment
localparam R_WORD = 8'h1c; // K28.0 begin of multiframe
localparam F_WORD = 8'hfc; // K28.7 frame alignment
localparam Q_WORD = 8'h9c; // K28.4 start of link configuration


// состояния FSM для link layer
// IDLE         - состояние ожидания сигнала от софта
// WAIT_SYSREF  - ожидание фронта сигнала SYSREF
// CGS          - Code Group Synchronization
// WAIT_ALIGN   - ожидание символа /R/ для выравнивания
// ALIGN        - выравнивание потока данных
// ILAS         - Initial Lane Alignment Sequence - последовательность фреймов для выравнивания
//              и проверки мультифреймов
// USER_DATA    - получение фрэймов с АЦП

reg [7:0] state, next_state;
localparam IDLE = 0;
localparam CGS = 1;
localparam WAIT_ALIGN = 2;
localparam ALIGN = 3;
localparam ILAS = 4;
localparam USER_DATA = 5;



reg sync_b_reg;

reg [7:0] cnt_lmfc;
reg       cnt_lmfc_en;
reg       cnt_lmfc_rst;

reg [7:0] cnt_fc;
reg       cnt_fc_en;
reg       cnt_fc_rst;

reg [1:0] align_mux;

reg [31:0] rx_dat_opt;
reg [31:0] rx_dat_opt_ff0;
reg [31:0] rx_dat_ff0;

reg [3:0] rx_datak_opt;
reg [3:0] rx_datak_ff0;

reg pattern_align_en_reg;

reg [15:0] adc_data0_reg;
reg [15:0] adc_data1_reg;

reg data_ready_reg;


wire [15:0] descrambled_adc0;
wire [15:0] descrambled_adc1;


assign data_ready = data_ready_reg;

assign sync_b = sync_b_reg;

assign pattern_align_en = pattern_align_en_reg;



reg [15:0] adc_data0_rg;
reg [15:0] adc_data1_rg;
always @(posedge clk, negedge reset_b)
    if(!reset_b) begin
        adc_data0_rg <= 16'd0;
        adc_data1_rg <= 16'd0;
    end else begin
        if (data_ready_reg) begin
            adc_data0_rg <= (scrambler_is_on) ? descrambled_adc0 : adc_data0_reg; // rx_dat_opt[31:16]; // 
            adc_data1_rg <= (scrambler_is_on) ? descrambled_adc1 : adc_data1_reg; // rx_dat_opt[15:0];  // 
        end else begin
            adc_data0_rg <= 16'd0;
            adc_data1_rg <= 16'd0;    
        end
    end

assign adc_data0 = adc_data0_rg;
assign adc_data1 = adc_data1_rg;



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
            next_state = CGS;

        CGS :
            if ((rx_dat == CGS_WORD) && (rx_datak == 4'hf))
                next_state = WAIT_ALIGN;
            else
                next_state = CGS;

        WAIT_ALIGN :
            if (((rx_dat[31:24] == R_WORD) && (rx_datak[3] == 1'b1))
            || ((rx_dat[23:16] == R_WORD)  && (rx_datak[2] == 1'b1))
            || ((rx_dat[15:8] == R_WORD) && (rx_datak[1] == 1'b1))
            || ((rx_dat[7:0] == R_WORD) && (rx_datak[0] == 1'b1)))
                next_state = ALIGN;
            else
                next_state = WAIT_ALIGN;

        ALIGN : next_state = ILAS;

        ILAS :
            if ((cnt_fc == K_PARAM) && (cnt_lmfc == 8'd4))
                next_state = USER_DATA;
            else
                next_state = ILAS;

        USER_DATA : next_state = USER_DATA;

    endcase
end
    

// последовательные выходны FSM
always @(posedge clk, negedge reset_b)
    if(!reset_b) begin
        adc_data0_reg <= 16'h0;
        adc_data1_reg <= 16'h0;
        data_ready_reg <= 1'b0;
    end else
        case (next_state)
            IDLE : begin
                adc_data0_reg <= 16'h0;
                adc_data1_reg <= 16'h0;
                data_ready_reg <= 1'b0;
            end
            USER_DATA : begin
                data_ready_reg <= 1'b1;
                adc_data0_reg <= rx_dat_opt[31:16];
                if (!scrambler_is_on)
                    if (((rx_dat_opt[7:0] == A_WORD) || (rx_dat_opt[7:0] == F_WORD))
                    && (rx_datak_opt[0] == 1'b1))
                        adc_data1_reg <= {rx_dat_opt[15:8], rx_dat_opt_ff0[7:0]};
                    else
                        adc_data1_reg <= rx_dat_opt[15:0];
                else if (rx_datak_opt[0] == 1'b1) begin
                    if (rx_dat_opt[7:0] == A_WORD)
                        adc_data1_reg <= {rx_dat_opt[15:8], A_WORD};
                    else if (rx_dat_opt[7:0] == F_WORD)
                        adc_data1_reg <= {rx_dat_opt[15:8], F_WORD};
                end else
                        adc_data1_reg <= rx_dat_opt[15:0];
            end

        endcase

// последовательные выходны FSM
always @(posedge clk, negedge reset_b)
    if(!reset_b) begin
        pattern_align_en_reg <= 1'b1;
        cnt_fc_en <= 1'b0;
        cnt_fc_rst <= 1'b1;
        cnt_lmfc_en <= 1'b0;
        cnt_lmfc_rst <= 1'b1;
    end else
        case (next_state)
            IDLE : begin
                pattern_align_en_reg <= 1'b1;
                cnt_fc_en <= 1'b0;
                cnt_fc_rst <= 1'b1;
                cnt_lmfc_en <= 1'b0;
                cnt_lmfc_rst <= 1'b1;
            end
            ALIGN : begin
                pattern_align_en_reg <= 1'b0;
                cnt_fc_en <= 1'b1;
                cnt_fc_rst <= 1'b0;
                cnt_lmfc_en <= 1'b0;
                cnt_lmfc_rst <= 1'b0;
            end
            ILAS :
                if (cnt_fc == K_PARAM_M1) begin
                    cnt_fc_rst <= 1'b1;
                    cnt_lmfc_en <= 1'b1;
                end else begin
                    cnt_fc_rst <= 1'b0;
                    cnt_lmfc_en <= 1'b0;
                end
            USER_DATA : begin
                if (cnt_fc == K_PARAM_M1) begin
                    cnt_fc_rst <= 1'b1;
                    cnt_lmfc_en <= 1'b1;
                end else begin
                    cnt_fc_rst <= 1'b0;
                    cnt_lmfc_en <= 1'b0;
                end
            end

        endcase


// последовательные выходны FSM
always @(posedge clk, negedge reset_b)
    if(!reset_b) begin
        sync_b_reg <= 1'b1;
    end else
        case (next_state)
            IDLE         : sync_b_reg <= 1'b1;
            CGS         : sync_b_reg <= 1'b0;
            WAIT_ALIGN     : sync_b_reg <= 1'b1;
        endcase    

        
// последовательные выходны FSM
always @(posedge clk, negedge reset_b)
    if(!reset_b) begin
        align_mux <= 2'h0;
    end else
        case (next_state)
            IDLE : align_mux <= 2'h0;
            ALIGN : begin
                if (rx_dat[31:24] == R_WORD)
                    align_mux <= 2'h0;
                else if (rx_dat[23:16] == R_WORD)
                    align_mux <= 2'h1;
                else if (rx_dat[15:8] == R_WORD)
                    align_mux <= 2'h2;
                else if (rx_dat[7:0] == R_WORD)
                    align_mux <= 2'h3;
                else
                    align_mux <= 2'h0;                
            end
        endcase     
        

    always @(*)
        case (align_mux)
            2'h0     : rx_dat_opt = {rx_dat_ff0[31:24], rx_dat[7:0],        rx_dat[15:8],       rx_dat[23:16]       };
            2'h1     : rx_dat_opt = {rx_dat_ff0[23:16], rx_dat_ff0[31:24],  rx_dat[7:0],        rx_dat[15:8]        };
            2'h2     : rx_dat_opt = {rx_dat_ff0[15:8],  rx_dat_ff0[23:16],  rx_dat_ff0[31:24],  rx_dat[7:0]         };
            3'h3     : rx_dat_opt = {rx_dat_ff0[7:0],   rx_dat_ff0[15:8],   rx_dat_ff0[23:16],  rx_dat_ff0[31:24]   };
            default : rx_dat_opt = 32'd0;
        endcase
        
    always @(*)
        case (align_mux)
            2'h0     : rx_datak_opt = {rx_datak_ff0[3], rx_datak[0],     rx_datak[1],       rx_datak[2]    };
            2'h1     : rx_datak_opt = {rx_datak_ff0[2], rx_datak_ff0[3], rx_datak[0],       rx_datak[1]    };
            2'h2     : rx_datak_opt = {rx_datak_ff0[1], rx_datak_ff0[2], rx_datak_ff0[3],   rx_datak[0]    };
            3'h3     : rx_datak_opt = {rx_datak_ff0[0], rx_datak_ff0[1], rx_datak_ff0[2],   rx_datak_ff0[3]};
            default : rx_datak_opt = 4'd0;
        endcase    

    
always @(posedge clk, negedge reset_b)
if (!reset_b) begin
    rx_dat_ff0 <= 32'h0;
    rx_datak_ff0 <= 4'h0;
    rx_dat_opt_ff0 <= 32'h0;
end else begin
    rx_dat_ff0 <= rx_dat;
    rx_datak_ff0 <= rx_datak;
    rx_dat_opt_ff0 <= rx_dat_opt;
end

always @(posedge clk, negedge reset_b)
if (!reset_b)
    cnt_fc <= 8'h1;
else
    if (cnt_fc_rst)
        cnt_fc <= 8'h1;
    else if (cnt_fc_en)
        cnt_fc <= cnt_fc + 8'h1;

always @(posedge clk, negedge reset_b)
if (!reset_b)
    cnt_lmfc <= 8'h1;
else
    if (cnt_lmfc_rst)
        cnt_lmfc <= 8'h1;
    else if (cnt_lmfc_en)
        cnt_lmfc <= cnt_lmfc + 8'h1;

        
////////////////// check  replacement ////////////////////////////////////    
reg [31:0] errors_link;
wire flag_multi = (rx_dat_opt[7:0]==A_WORD) & rx_datak_opt[0];
always @(posedge clk, negedge reset_b)
    if(!reset_b) begin
        errors_link <= 32'd0;
    end else begin
        if (flag_multi) begin
            if (cnt_fc==K_PARAM)
                errors_link <= errors_link;    
            else
                errors_link <= errors_link + ~&errors_link;
        end else
            errors_link <= errors_link;        
    end
///////////////////////////////////////////////////////////////            


jesd204b_descrambler jesd204b_descrambler_inst0
(
    .reset_b    (reset_b),
    .clk        (clk),

    .s_d_in     ({adc_data0_reg, adc_data1_reg}),

    .d_out      ({descrambled_adc0, descrambled_adc1})
);


/////////////// jesd link control /////////////////////////////
reg [31:0] rx_parallel_data_reg;
always @(posedge clk, negedge reset_b)
    if (!reset_b) begin
        rx_parallel_data_reg <= 32'd0;
    end else begin
        rx_parallel_data_reg <= rx_parallel_data;
    end            
wire flag_dif = (rx_parallel_data_reg==rx_parallel_data);
    
reg [15:0] cnt_dif;
always @(posedge clk, negedge reset_b)
    if (!reset_b) begin
        cnt_dif <= 16'd0;
    end else begin
        if (flag_dif)
            cnt_dif <= cnt_dif + ~&cnt_dif;
        else if (cnt_fc_en)
            cnt_dif <= 16'd0;
    end
wire alarm_dif = &cnt_dif;
///////////////////////////////////////////////////////////////


assign err_link_rx = {errors_link[30:0], alarm_dif};


assign tst = {
    22'd0,
    align_mux[1:0],
    rx_datak[3:0],
    rx_parallel_data[31:0],
    3'd0,
    sync_b_reg,
    state[3:0]
    };

endmodule