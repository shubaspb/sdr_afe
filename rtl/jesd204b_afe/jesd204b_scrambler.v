
module jesd204b_scrambler
(
    input         reset_b,
    input         clk,
    input  [31:0] d_in,
    output [31:0] s_d_out
);

reg [31:0] d_out_reg;
reg [14:0] scrambler15;
reg [16:0] scrambler15_msb;

assign s_d_out[31] = scrambler15_msb[16];
assign s_d_out[30] = scrambler15_msb[15];
assign s_d_out[29] = scrambler15_msb[14];
assign s_d_out[28] = scrambler15_msb[13];
assign s_d_out[27] = scrambler15_msb[12];
assign s_d_out[26] = scrambler15_msb[11];
assign s_d_out[25] = scrambler15_msb[10];
assign s_d_out[24] = scrambler15_msb[9];
assign s_d_out[23] = scrambler15_msb[8];
assign s_d_out[22] = scrambler15_msb[7];
assign s_d_out[21] = scrambler15_msb[6];
assign s_d_out[20] = scrambler15_msb[5];
assign s_d_out[19] = scrambler15_msb[4];
assign s_d_out[18] = scrambler15_msb[3];
assign s_d_out[17] = scrambler15_msb[2];
assign s_d_out[16] = scrambler15_msb[1];
assign s_d_out[15] = scrambler15_msb[0];
assign s_d_out[14] = scrambler15[14];
assign s_d_out[13] = scrambler15[13];
assign s_d_out[12] = scrambler15[12];
assign s_d_out[11] = scrambler15[11];
assign s_d_out[10] = scrambler15[10];
assign s_d_out[9]  = scrambler15[9];
assign s_d_out[8]  = scrambler15[8];
assign s_d_out[7]  = scrambler15[7];
assign s_d_out[6]  = scrambler15[6];
assign s_d_out[5]  = scrambler15[5];
assign s_d_out[4]  = scrambler15[4];
assign s_d_out[3]  = scrambler15[3];
assign s_d_out[2]  = scrambler15[2];
assign s_d_out[1]  = scrambler15[1];
assign s_d_out[0]  = scrambler15[0];

always @(posedge clk, negedge reset_b)
    if(~reset_b)
        scrambler15_msb <= 17'h0;
    else begin
        scrambler15_msb[16] <= scrambler15[14] ^ scrambler15[13] ^ d_in[31];
        scrambler15_msb[15] <= scrambler15[13] ^ scrambler15[12] ^ d_in[30];
        scrambler15_msb[14] <= scrambler15[12] ^ scrambler15[11] ^ d_in[29];
        scrambler15_msb[13] <= scrambler15[11] ^ scrambler15[10] ^ d_in[28];
        scrambler15_msb[12] <= scrambler15[10] ^ scrambler15[9] ^ d_in[27];
        scrambler15_msb[11] <= scrambler15[9] ^ scrambler15[8] ^ d_in[26];
        scrambler15_msb[10] <= scrambler15[8] ^ scrambler15[7] ^ d_in[25];
        scrambler15_msb[9]  <= scrambler15[7] ^ scrambler15[6] ^ d_in[24];
        scrambler15_msb[8]  <= scrambler15[6] ^ scrambler15[5] ^ d_in[23];
        scrambler15_msb[7]  <= scrambler15[5] ^ scrambler15[4] ^ d_in[22];
        scrambler15_msb[6]  <= scrambler15[4] ^ scrambler15[3] ^ d_in[21];
        scrambler15_msb[5]  <= scrambler15[3] ^ scrambler15[2] ^ d_in[20];
        scrambler15_msb[4]  <= scrambler15[2] ^ scrambler15[1] ^ d_in[19];
        scrambler15_msb[3]  <= scrambler15[1] ^ scrambler15[0] ^ d_in[18];
        scrambler15_msb[2]  <= scrambler15[0] ^ scrambler15[14] ^ scrambler15[13] ^ d_in[31] ^ d_in[17];
        scrambler15_msb[1]  <= scrambler15[14] ^ scrambler15[12] ^ d_in[31] ^ d_in[30] ^ d_in[16];
        scrambler15_msb[0]  <= scrambler15[13] ^ scrambler15[11] ^ d_in[30] ^ d_in[29] ^ d_in[15];
    end

always @(posedge clk, negedge reset_b)
    if(~reset_b)
        scrambler15 <= 15'h7f80;
    else begin
        scrambler15[14] <= scrambler15[12] ^ scrambler15[10] ^ d_in[29] ^ d_in[28] ^ d_in[14];
        scrambler15[13] <= scrambler15[11] ^ scrambler15[9] ^ d_in[28] ^ d_in[27] ^ d_in[13];
        scrambler15[12] <= scrambler15[10] ^ scrambler15[8] ^ d_in[27] ^ d_in[26] ^ d_in[12];
        scrambler15[11] <= scrambler15[9] ^ scrambler15[7] ^ d_in[26] ^ d_in[25] ^ d_in[11];
        scrambler15[10] <= scrambler15[8] ^ scrambler15[6] ^ d_in[25] ^ d_in[24] ^ d_in[10];
        scrambler15[9]  <= scrambler15[7] ^ scrambler15[5] ^ d_in[24] ^ d_in[23] ^ d_in[9];
        scrambler15[8]  <= scrambler15[6] ^ scrambler15[4] ^ d_in[23] ^ d_in[22] ^ d_in[8];
        scrambler15[7]  <= scrambler15[5] ^ scrambler15[3] ^ d_in[22] ^ d_in[21] ^ d_in[7];
        scrambler15[6]  <= scrambler15[4] ^ scrambler15[2] ^ d_in[21] ^ d_in[20] ^ d_in[6];
        scrambler15[5]  <= scrambler15[3] ^ scrambler15[1] ^ d_in[20] ^ d_in[19] ^ d_in[5];
        scrambler15[4]  <= scrambler15[2] ^ scrambler15[0] ^ d_in[19] ^ d_in[18] ^ d_in[4];
        scrambler15[3]  <= scrambler15[1] ^ scrambler15[14] ^ scrambler15[13] ^ d_in[31] ^ d_in[18] ^ d_in[17] ^ d_in[3];
        scrambler15[2]  <= scrambler15[0] ^ scrambler15[13] ^ scrambler15[12] ^ d_in[30] ^ d_in[17] ^ d_in[16] ^ d_in[2];
        scrambler15[1]  <= scrambler15[14] ^ scrambler15[13] ^ scrambler15[12] ^ scrambler15[11] ^ d_in[31] ^ d_in[29] ^ d_in[16] ^ d_in[15] ^ d_in[1];
        scrambler15[0]  <= scrambler15[13] ^ scrambler15[12] ^ scrambler15[11] ^ scrambler15[10] ^ d_in[30] ^ d_in[28] ^ d_in[15] ^ d_in[14] ^ d_in[0];
    end


endmodule