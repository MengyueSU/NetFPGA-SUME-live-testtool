-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
-- Date        : Wed Oct 20 16:14:34 2021
-- Host        : mengyue-Ubuntu running 64-bit Ubuntu 20.04.3 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/mengyue/NetFPGA-SUME-live_v2/projects/reference_nic/hw/ip_repo/axi_trigger_1.0/src/trigger_fifo_generator_1/trigger_fifo_generator_1_stub.vhdl
-- Design      : trigger_fifo_generator_1
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7vx690tffg1761-3
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity trigger_fifo_generator_1 is
  Port ( 
    clk : in STD_LOGIC;
    srst : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 416 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 416 downto 0 );
    full : out STD_LOGIC;
    empty : out STD_LOGIC;
    data_count : out STD_LOGIC_VECTOR ( 10 downto 0 )
  );

end trigger_fifo_generator_1;

architecture stub of trigger_fifo_generator_1 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,srst,din[416:0],wr_en,rd_en,dout[416:0],full,empty,data_count[10:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "fifo_generator_v13_2_5,Vivado 2020.2";
begin
end;
