vlib work
vlog tb_fifo_sync.v
vsim tb +testname=test_concurrent_wr_rd
add wave sim:/tb/u0/*
run -all
