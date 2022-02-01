/*
    Название проекта    : eva_adrv9371
    Название файла      : jesd204b_prbs_verifier.sv
    Назначение          : модуль проверки псевдослучайной последовательности PRBS7.
    Автор               : Александрович Ф.А.
    Дата создания       : 2018.02.27
    Синтаксис           : IEEE 1800-2012 (Verilog HDL 2001)
    Комментарии         :
---------------------------------------------------------------------------------------------------------------------
    Состояние модуля    : [ ] проведена проверка синтаксиса (modelsim)
                          [ ] синтезируется без серьезных предупреждений
                          [ ] проведена функциональная проверка (функциональное моделирование) (modelsim)
                          [ ] проведена проверка в целевом проекте
---------------------------------------------------------------------------------------------------------------------
    Ревизия             : 1.0 - 2018.02.27
*/


`timescale 1ns / 1ns


module jesd204b_prbs_verifier
(
    input         link_reset_b,
    input         link_clk,

    input         debug_reset_b,
    input         debug_clk,

    // параллельные данные до упорядочивания
    output [31:0] tx_parallel_data,
    input  [31:0] rx_parallel_data,
    input   [3:0] pattern_detect,

    output        sync,
    output        err,

    output        pattern_align_en,

    // отладочный вектор на логический анализатор
    output [67:0] tst_prbs0,
    output [67:0] tst_prbs1
);


localparam SYNC_DATA_WORD = 32'h4f143040;

localparam SYNC_PATTERN_DETECT = 4'h2;


reg err_reg;

reg pattern_align_en_reg;

reg [6:0] prbs7_reg;

reg [31:0] prbs7_checker;

reg [31:0] rx_parallel_data_ff0;

reg [15:0] cnt_err;

reg [3:0] cnt_sync;

reg wrreq;
reg wr_en;

reg rdreq;
reg rd_en;

reg data_ready_reg;


wire [10:0] wrusedw;
wire wrfull;
wire wrempty;

wire rdfull;
wire rdempty;

wire [24:0] prbs7_comb;

wire [3:0] debug_pattern_detect;
wire [31:0] debug_rx_parallel_data_ff0;
wire [27:0] debug_prbs7_checker;


reg [7:0] state, next_state;
localparam WAIT_SYNC = 0;
localparam CNT_INC = 1;
localparam NOP = 2;
localparam VERIFY = 3;

assign tx_parallel_data = prbs7_checker;

assign sync = ~pattern_align_en_reg;

assign err = err_reg;

assign pattern_align_en = pattern_align_en_reg;

assign prbs7_comb[24] = prbs7_reg[3] ^ prbs7_reg[5] ^ prbs7_reg[6];
assign prbs7_comb[23] = prbs7_reg[0] ^ prbs7_reg[4];
assign prbs7_comb[22] = prbs7_reg[1] ^ prbs7_reg[5];
assign prbs7_comb[21] = prbs7_reg[2] ^ prbs7_reg[6];
assign prbs7_comb[20] = prbs7_reg[0] ^ prbs7_reg[3] ^ prbs7_reg[6];
assign prbs7_comb[19] = prbs7_reg[0] ^ prbs7_reg[1] ^ prbs7_reg[4] ^ prbs7_reg[6];
assign prbs7_comb[18] = prbs7_reg[0] ^ prbs7_reg[1] ^ prbs7_reg[2] ^ prbs7_reg[5] ^ prbs7_reg[6];
assign prbs7_comb[17] = prbs7_reg[0] ^ prbs7_reg[1] ^ prbs7_reg[2] ^ prbs7_reg[3];
assign prbs7_comb[16] = prbs7_reg[1] ^ prbs7_reg[2] ^ prbs7_reg[3] ^ prbs7_reg[4];
assign prbs7_comb[15] = prbs7_reg[2] ^ prbs7_reg[3] ^ prbs7_reg[4] ^ prbs7_reg[5];
assign prbs7_comb[14] = prbs7_reg[3] ^ prbs7_reg[4] ^ prbs7_reg[5] ^ prbs7_reg[6];
assign prbs7_comb[13] = prbs7_reg[0] ^ prbs7_reg[4] ^ prbs7_reg[5];
assign prbs7_comb[12] = prbs7_reg[1] ^ prbs7_reg[5] ^ prbs7_reg[6];
assign prbs7_comb[11] = prbs7_reg[2] ^ prbs7_reg[0];
assign prbs7_comb[10] = prbs7_reg[3] ^ prbs7_reg[1];
assign prbs7_comb[9] = prbs7_reg[4] ^ prbs7_reg[2];
assign prbs7_comb[8] = prbs7_reg[5] ^ prbs7_reg[3];
assign prbs7_comb[7] = prbs7_reg[6] ^ prbs7_reg[4];
assign prbs7_comb[6] = prbs7_reg[0] ^ prbs7_reg[6] ^ prbs7_reg[5];
assign prbs7_comb[5] = prbs7_reg[1] ^ prbs7_reg[0];
assign prbs7_comb[4] = prbs7_reg[2] ^ prbs7_reg[1];
assign prbs7_comb[3] = prbs7_reg[3] ^ prbs7_reg[2];
assign prbs7_comb[2] = prbs7_reg[4] ^ prbs7_reg[3];
assign prbs7_comb[1] = prbs7_reg[5] ^ prbs7_reg[4];
assign prbs7_comb[0] = prbs7_reg[6] ^ prbs7_reg[5];

assign tst_prbs0 =
{
    link_clk,
    8'h0,
    cnt_err[15:0],
    rx_parallel_data_ff0[31:24],
    1'b0, // не рабочий бит
    rx_parallel_data_ff0[23:0],
    pattern_detect[3:0],
    2'h0,
    err_reg,
    pattern_align_en_reg,
    link_clk,
    link_reset_b
};

assign tst_prbs1 =
{
    debug_clk,
    debug_pattern_detect[3:0],
    debug_rx_parallel_data_ff0[31:4],
    1'b0, // не рабочий бит
    debug_rx_parallel_data_ff0[3:0],
    debug_prbs7_checker[27:0],
    debug_clk,
    rd_en
};


// последовательная часть FSM
always @(posedge link_clk, negedge link_reset_b)
    if (!link_reset_b)
        state <= WAIT_SYNC;
    else
        state <= next_state;

// комбинационная часть FSM
always @(*) begin
    next_state = WAIT_SYNC;
    case (state)

        WAIT_SYNC :
            if ((rx_parallel_data == SYNC_DATA_WORD) && (pattern_detect == SYNC_PATTERN_DETECT))
                if (cnt_sync == 4'd3)
                    next_state = NOP;
                else
                    next_state = CNT_INC;
            else
                next_state = WAIT_SYNC;

        CNT_INC : next_state = WAIT_SYNC;

        NOP : next_state = VERIFY;

        VERIFY : next_state = VERIFY;

    endcase
end

// комбинационные выходны FSM
always @(posedge link_clk, negedge link_reset_b)
    if (!link_reset_b) begin
        cnt_err <= 16'h0;
        prbs7_reg <= 7'h01;
        pattern_align_en_reg <= 1'b1;
        err_reg <= 1'b0;
        data_ready_reg <= 1'b0;
        cnt_sync <= 4'h0;
    end else
        case (next_state)

            WAIT_SYNC : begin
                cnt_err <= 16'h0;
                prbs7_reg <= 7'h01;
                pattern_align_en_reg <= 1'b1;
                err_reg <= 1'b0;
                data_ready_reg <= 1'b0;
            end

            CNT_INC : cnt_sync <= cnt_sync + 4'd1;

            NOP : begin
                data_ready_reg <= 1'b1;
                pattern_align_en_reg <= 1'b0;

                prbs7_reg[6] <= prbs7_reg[4] ^ prbs7_reg[2] ^ prbs7_reg[5];
                prbs7_reg[5] <= prbs7_reg[3] ^ prbs7_reg[1] ^ prbs7_reg[4];
                prbs7_reg[4] <= prbs7_reg[2] ^ prbs7_reg[0] ^ prbs7_reg[3];
                prbs7_reg[3] <= prbs7_reg[1] ^ prbs7_reg[6] ^ prbs7_reg[5] ^ prbs7_reg[2];
                prbs7_reg[2] <= prbs7_reg[0] ^ prbs7_reg[5] ^ prbs7_reg[4] ^ prbs7_reg[1];
                prbs7_reg[1] <= prbs7_reg[6] ^ prbs7_reg[5] ^ prbs7_reg[4] ^ prbs7_reg[3] ^ prbs7_reg[0];
                prbs7_reg[0] <= prbs7_reg[6] ^ prbs7_reg[4] ^ prbs7_reg[3] ^ prbs7_reg[2];
            end

            VERIFY : begin
                prbs7_reg[6] <= prbs7_reg[4] ^ prbs7_reg[2] ^ prbs7_reg[5];
                prbs7_reg[5] <= prbs7_reg[3] ^ prbs7_reg[1] ^ prbs7_reg[4];
                prbs7_reg[4] <= prbs7_reg[2] ^ prbs7_reg[0] ^ prbs7_reg[3];
                prbs7_reg[3] <= prbs7_reg[1] ^ prbs7_reg[6] ^ prbs7_reg[5] ^ prbs7_reg[2];
                prbs7_reg[2] <= prbs7_reg[0] ^ prbs7_reg[5] ^ prbs7_reg[4] ^ prbs7_reg[1];
                prbs7_reg[1] <= prbs7_reg[6] ^ prbs7_reg[5] ^ prbs7_reg[4] ^ prbs7_reg[3] ^ prbs7_reg[0];
                prbs7_reg[0] <= prbs7_reg[6] ^ prbs7_reg[4] ^ prbs7_reg[3] ^ prbs7_reg[2];

                err_reg <= (prbs7_checker != rx_parallel_data_ff0) ? 1'b1 : 1'b0;

                if (prbs7_checker != rx_parallel_data_ff0)
                    cnt_err = cnt_err + ~&cnt_err;
            end

        endcase

always @(posedge link_clk, negedge link_reset_b)
    if(!link_reset_b)
        prbs7_checker <= 32'h0;
    else begin
        prbs7_checker[0] <= prbs7_reg[6];
        prbs7_checker[1] <= prbs7_reg[5];
        prbs7_checker[2] <= prbs7_reg[4];
        prbs7_checker[3] <= prbs7_reg[3];
        prbs7_checker[4] <= prbs7_reg[2];
        prbs7_checker[5] <= prbs7_reg[1];
        prbs7_checker[6] <= prbs7_reg[0];
        prbs7_checker[7] <= prbs7_comb[0];
        prbs7_checker[8] <= prbs7_comb[1];
        prbs7_checker[9] <= prbs7_comb[2];
        prbs7_checker[10] <= prbs7_comb[3];
        prbs7_checker[11] <= prbs7_comb[4];
        prbs7_checker[12] <= prbs7_comb[5];
        prbs7_checker[13] <= prbs7_comb[6];
        prbs7_checker[14] <= prbs7_comb[7];
        prbs7_checker[15] <= prbs7_comb[8];
        prbs7_checker[16] <= prbs7_comb[9];
        prbs7_checker[17] <= prbs7_comb[10];
        prbs7_checker[18] <= prbs7_comb[11];
        prbs7_checker[19] <= prbs7_comb[12];
        prbs7_checker[20] <= prbs7_comb[13];
        prbs7_checker[21] <= prbs7_comb[14];
        prbs7_checker[22] <= prbs7_comb[15];
        prbs7_checker[23] <= prbs7_comb[16];
        prbs7_checker[24] <= prbs7_comb[17];
        prbs7_checker[25] <= prbs7_comb[18];
        prbs7_checker[26] <= prbs7_comb[19];
        prbs7_checker[27] <= prbs7_comb[20];
        prbs7_checker[28] <= prbs7_comb[21];
        prbs7_checker[29] <= prbs7_comb[22];
        prbs7_checker[30] <= prbs7_comb[23];
        prbs7_checker[31] <= prbs7_comb[24];
    end

always @(posedge link_clk, negedge link_reset_b)
    if(!link_reset_b)
        rx_parallel_data_ff0 <= 32'h0;
    else
        rx_parallel_data_ff0 <= rx_parallel_data;

always @(posedge link_clk, negedge link_reset_b)
    if (!link_reset_b)
        wr_en <= 1'b0;
    else
        if (wrfull)
            wr_en <= 1'b0;
        else if ((wrempty) && (data_ready_reg))
            wr_en <= 1'b1;

always @(posedge link_clk, negedge link_reset_b)
    if (!link_reset_b)
        wrreq <= 1'b0;
    else
        if (wrfull)
            wrreq <= 1'b0;
        else if (wr_en)
            wrreq <= 1'b1;

always @(posedge debug_clk, negedge debug_reset_b)
    if (!debug_reset_b)
        rd_en <= 1'b0;
    else
        if (rdempty)
            rd_en <= 1'b0;
        else if (rdfull)
            rd_en <= 1'b1;

always @(posedge debug_clk, negedge debug_reset_b)
    if (!debug_reset_b)
        rdreq <= 1'b0;
    else
        if (rdempty)
            rdreq <= 1'b0;
        else if (rdfull)
            rdreq <= 1'b1;


jesd204b_prbs_debug_fifo jesd204b_prbs_debug_fifo_inst0
(
    .aclr       (~link_reset_b),

    .wrclk      (link_clk),
    .wrusedw    (wrusedw),
    .wrfull     (wrfull),
    .wrempty    (wrempty),
    .wrreq      (wrreq),
    .data       ({pattern_detect, rx_parallel_data_ff0, prbs7_checker[27:0]}),

    .rdclk      (debug_clk),
    .rdusedw    (),
    .rdfull     (rdfull),
    .rdempty    (rdempty),
    .rdreq      (rdreq),
    .q          ({debug_pattern_detect, debug_rx_parallel_data_ff0, debug_prbs7_checker})
);


endmodule


