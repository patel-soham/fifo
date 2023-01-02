// Write interface for Asynchronous FIFO
interface fifo_intf(input bit wr_clk_i, rst_i, rd_clk_i);

logic [`WIDTH-1 : 0] wdata_i; 
logic wr_en_i, full_o, wr_error_o;

logic [`WIDTH-1 : 0] rdata_o; 
logic rd_en_i, empty_o, rd_error_o;

// Write clocking block and modport for driver and monitor
clocking drv_wr_cb @ (posedge wr_clk_i);
	default input #1 output #1;
	input full_o, wr_error_o;
	output wr_en_i;
	output wdata_i;
endclocking

clocking mon_wr_cb @ (posedge wr_clk_i);
	default input #1 output #1;
	input full_o, wr_error_o, wr_en_i, wdata_i;
endclocking

modport drv_wr_mb (clocking drv_wr_cb);
modport mon_wr_mb (clocking mon_wr_cb);

// Read clocking block and modport for driver and monitor
clocking drv_rd_cb @ (posedge rd_clk_i);
	default input #1 output #1;
	input empty_o, rd_error_o, rdata_o;
	output rd_en_i;
endclocking

clocking mon_rd_cb @ (posedge rd_clk_i);
	default input #1 output #1;
	input empty_o, rd_error_o, rdata_o, rd_en_i;
endclocking

modport drv_rd_mb (clocking drv_rd_cb);
modport mon_rd_mb (clocking mon_rd_cb);

endinterface
