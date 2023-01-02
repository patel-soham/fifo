`timescale 1ns/1ps

`define FREQ_RD_CLK 6 //frequency of read clock in MHz
`define FREQ_WR_CLK 15 //frequency of write clock in MHz

`define DEPTH 4 // fifo depth
`define PTR_WIDTH $clog2(`DEPTH) // fifo pointer width
`define WIDTH 16  // fifo word/data size

`include "fifo_tx.sv"
`include "fifo_async.v"
`include "fifo_intf.sv"
`include "fifo_gen.sv"
`include "fifo_drv.sv"
`include "fifo_mon.sv"
`include "fifo_agent.sv"
`include "fifo_scb.sv"
`include "fifo_env.sv"
`include "test.sv"
`include "top.sv"
