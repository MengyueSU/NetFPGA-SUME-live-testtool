// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
// Date        : Thu Dec  9 18:11:06 2021
// Host        : mengyue-Ubuntu running 64-bit Ubuntu 20.04.3 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/mengyue/NetFPGA-SUME-live-all/projects/reference_nic/hw/ip_repo/axi_counter_1.0/src/counter_fifo_generator/counter_fifo_generator_stub.v
// Design      : counter_fifo_generator
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1761-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_5,Vivado 2020.2" *)
module counter_fifo_generator(wr_clk, wr_rst, rd_clk, rd_rst, din, wr_en, rd_en, 
  dout, full, empty, wr_data_count)
/* synthesis syn_black_box black_box_pad_pin="wr_clk,wr_rst,rd_clk,rd_rst,din[63:0],wr_en,rd_en,dout[63:0],full,empty,wr_data_count[8:0]" */;
  input wr_clk;
  input wr_rst;
  input rd_clk;
  input rd_rst;
  input [63:0]din;
  input wr_en;
  input rd_en;
  output [63:0]dout;
  output full;
  output empty;
  output [8:0]wr_data_count;
endmodule
