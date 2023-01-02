vlib work
vlog headers.svh +define+TEST_EMPTY_ERR   
vsim -novopt top -l logfile.log
add wave sim:/top/pif/*
run -all
