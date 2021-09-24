/*
    Название проекта    : tcas_bsps
    Название файла      : jesd204b_rst_ctl.v
    Назначение          : Контроллер сброса link layer jesd204b.
    Автор               : Александрович Ф.А.
    Дата создания       : 2018.10.23
    Синтаксис           : IEEE 1364-2001 (Verilog HDL 2001)
    Комментарии         :
*/



`timescale 1ns / 1ns


module jesd204b_rst_ctl
(
    input  link_clk,
    input  tx_en0,
    input  tx_en1,
    input  rx_en0,
    input  rx_en1,
    output reset_b
);


	wire rst_en = rx_en0 & rx_en1 & tx_en0 & tx_en1;

	reg rst_en_ff0;
	reg rst_en_ff1;
	always @(posedge link_clk, negedge rst_en)
		if (!rst_en)
			{rst_en_ff1, rst_en_ff0} <= 2'h0;
		else
			{rst_en_ff1, rst_en_ff0} <= {rst_en_ff0, rst_en};
			
	reg [15:0] rst_cnt;
	always @(posedge link_clk, negedge rst_en_ff1)
		if (!rst_en_ff1)
			rst_cnt <= 16'h0;
		else
			rst_cnt <= rst_cnt + ~&rst_cnt;

	assign reset_b = &rst_cnt;




endmodule





