// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Tue Apr 27 14:07:52 2021
// Host        : yayushin-pc running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub D:/WORK/afe7700_xilinx/rtl/ila_0/ila_0_stub.v
// Design      : ila_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2019.1" *)
module ila_0(clk, trig_in, trig_in_ack, probe0, probe1, probe2, 
  probe3, probe4, probe5, probe6, probe7, probe8, probe9, probe10, probe11)
/* synthesis syn_black_box black_box_pad_pin="clk,trig_in,trig_in_ack,probe0[19:0],probe1[19:0],probe2[19:0],probe3[19:0],probe4[19:0],probe5[19:0],probe6[19:0],probe7[19:0],probe8[19:0],probe9[19:0],probe10[19:0],probe11[19:0]" */;
  input clk;
  input trig_in;
  output trig_in_ack;
  input [19:0]probe0;
  input [19:0]probe1;
  input [19:0]probe2;
  input [19:0]probe3;
  input [19:0]probe4;
  input [19:0]probe5;
  input [19:0]probe6;
  input [19:0]probe7;
  input [19:0]probe8;
  input [19:0]probe9;
  input [19:0]probe10;
  input [19:0]probe11;
endmodule