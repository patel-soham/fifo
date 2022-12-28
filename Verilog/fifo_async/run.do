vlib work
vlog tb_fifo_async.v +define+SEED=2345   
vsim tb +testname=test_concurrent_wr_rd
add wave sim:/tb/u0/*
run -all
