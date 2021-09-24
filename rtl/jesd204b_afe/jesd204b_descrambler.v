/*
    Название проекта    : 
    Название файла      : jesd204b_descrambler.v
    Назначение          : Дескремблер пользовательских данных.
    Автор               : Александрович Ф.А.
    Дата создания       : 2018.04.26
    Синтаксис           : IEEE 1364-2001 (Verilog HDL 2001)
    Комментарии         : Использован полином x15 ^ x14 + 1 для 32 разрядных данных. 
---------------------------------------------------------------------------------------------------------------------
    Состояние модуля    : [ ] проведена проверка синтаксиса (modelsim)
                          [ ] синтезируется без серьезных предупреждений
                          [ ] проведена функциональная проверка (функциональное моделирование) (modelsim)
                          [ ] проведена проверка в целевом проекте
---------------------------------------------------------------------------------------------------------------------
    Ревизия             : 1.0 - 2018.04.26
*/


`timescale 1ns / 1ns


module jesd204b_descrambler
(
    input         reset_b,
    input         clk,

    input  [31:0] s_d_in,

    output [31:0] d_out
);


reg [31:0] d_out_reg;

reg [14:0] scrambler15;


assign d_out = d_out_reg;


always @(posedge clk, negedge reset_b)
	if(~reset_b)
        scrambler15 <= 15'h7f80;
    else
        scrambler15 <= s_d_in[14:0];

always @(posedge clk, negedge reset_b)
	if(~reset_b)
        d_out_reg <= 32'h0;
    else begin
        d_out_reg[31] <= s_d_in[31] ^ scrambler15[14] ^ scrambler15[13];
        d_out_reg[30] <= s_d_in[30] ^ scrambler15[13] ^ scrambler15[12];
        d_out_reg[29] <= s_d_in[29] ^ scrambler15[12] ^ scrambler15[11];
        d_out_reg[28] <= s_d_in[28] ^ scrambler15[11] ^ scrambler15[10];
        d_out_reg[27] <= s_d_in[27] ^ scrambler15[10] ^ scrambler15[9];
        d_out_reg[26] <= s_d_in[26] ^ scrambler15[9] ^ scrambler15[8];
        d_out_reg[25] <= s_d_in[25] ^ scrambler15[8] ^ scrambler15[7];
        d_out_reg[24] <= s_d_in[24] ^ scrambler15[7] ^ scrambler15[6];
        d_out_reg[23] <= s_d_in[23] ^ scrambler15[6] ^ scrambler15[5];
        d_out_reg[22] <= s_d_in[22] ^ scrambler15[5] ^ scrambler15[4];
        d_out_reg[21] <= s_d_in[21] ^ scrambler15[4] ^ scrambler15[3];
        d_out_reg[20] <= s_d_in[20] ^ scrambler15[3] ^ scrambler15[2];
        d_out_reg[19] <= s_d_in[19] ^ scrambler15[2] ^ scrambler15[1];
        d_out_reg[18] <= s_d_in[18] ^ scrambler15[1] ^ scrambler15[0];
        d_out_reg[17] <= s_d_in[17] ^ scrambler15[0] ^ s_d_in[31];
        d_out_reg[16] <= s_d_in[16] ^ s_d_in[31] ^ s_d_in[30];
        d_out_reg[15] <= s_d_in[15] ^ s_d_in[30] ^ s_d_in[29];
        d_out_reg[14] <= s_d_in[14] ^ s_d_in[29] ^ s_d_in[28];
        d_out_reg[13] <= s_d_in[13] ^ s_d_in[28] ^ s_d_in[27];
        d_out_reg[12] <= s_d_in[12] ^ s_d_in[27] ^ s_d_in[26];
        d_out_reg[11] <= s_d_in[11] ^ s_d_in[26] ^ s_d_in[25];
        d_out_reg[10] <= s_d_in[10] ^ s_d_in[25] ^ s_d_in[24];
        d_out_reg[9]  <= s_d_in[9] ^ s_d_in[24] ^ s_d_in[23];
        d_out_reg[8]  <= s_d_in[8] ^ s_d_in[23] ^ s_d_in[22];
        d_out_reg[7]  <= s_d_in[7] ^ s_d_in[22] ^ s_d_in[21];
        d_out_reg[6]  <= s_d_in[6] ^ s_d_in[21] ^ s_d_in[20];
        d_out_reg[5]  <= s_d_in[5] ^ s_d_in[20] ^ s_d_in[19];
        d_out_reg[4]  <= s_d_in[4] ^ s_d_in[19] ^ s_d_in[18];
        d_out_reg[3]  <= s_d_in[3] ^ s_d_in[18] ^ s_d_in[17];
        d_out_reg[2]  <= s_d_in[2] ^ s_d_in[17] ^ s_d_in[16];
        d_out_reg[1]  <= s_d_in[1] ^ s_d_in[16] ^ s_d_in[15];
        d_out_reg[0]  <= s_d_in[0] ^ s_d_in[15] ^ s_d_in[14];
    end


endmodule


