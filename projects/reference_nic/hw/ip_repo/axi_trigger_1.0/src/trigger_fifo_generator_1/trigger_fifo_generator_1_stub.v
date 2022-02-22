// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
// Date        : Wed Oct 20 16:14:34 2021
// Host        : mengyue-Ubuntu running 64-bit Ubuntu 20.04.3 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/mengyue/NetFPGA-SUME-live_v2/projects/reference_nic/hw/ip_repo/axi_trigger_1.0/src/trigger_fifo_generator_1/trigger_fifo_generator_1_stub.v
// Design      : trigger_fifo_generator_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1761-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_5,Vivado 2020.2" *)
module trigger_fifo_generator_1(clk, srst, din, wr_en, rd_en, dout, full, empty, 
  data_count)
/* synthesis syn_black_box black_box_pad_pin="clk,srst,din[416:0],wr_en,rd_en,dout[416:0],full,empty,data_count[10:0]" */;
  input clk;
  input srst;
  input [416:0]din;
  input wr_en;
  input rd_en;
  output [416:0]dout;
  output full;
  output empty;
  output [10:0]data_count;
endmodule
