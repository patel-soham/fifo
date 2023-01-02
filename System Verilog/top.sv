// top most module in testbench
module top;

// clocks and reset signal instantiation
bit wr_clk_i, rd_clk_i, rst_i;
real tp_wr_clk, tp_rd_clk;

always #(tp_wr_clk/2.0)wr_clk_i = ~wr_clk_i;
always #(tp_rd_clk/2.0)rd_clk_i = ~rd_clk_i;

// interface of asynchronous fifo
fifo_intf pif (wr_clk_i, rst_i, rd_clk_i);

// instantiate dut
fifo_async #(.DEPTH(`DEPTH), .WIDTH(`WIDTH), .PTR_WIDTH(`PTR_WIDTH)) u0 (
	.rd_clk_i(pif.rd_clk_i), 
	.wr_clk_i(pif.wr_clk_i), 
	.rst_i(pif.rst_i), 
	.wr_en_i(pif.wr_en_i), 
	.wdata_i(pif.wdata_i), 
	.full_o(pif.full_o), 
	.wr_error_o(pif.wr_error_o), 
	.rd_en_i(pif.rd_en_i), 
	.rdata_o(pif.rdata_o), 
	.empty_o(pif.empty_o), 
	.rd_error_o(pif.rd_error_o));

// reset hold and release
initial begin
	tp_wr_clk = (1000/`FREQ_WR_CLK); // MHz to ns time period 
	tp_rd_clk = (1000/`FREQ_RD_CLK); // MHz to ns time period 
	pif.wr_en_i = 0;
	pif.rd_en_i = 0;
	pif.wdata_i = 0;
	rst_i = 1;
	repeat (3) @ (posedge wr_clk_i);
	rst_i = 0;
	
end

// Instantiate program 
test t0(pif);

initial begin
	#10000 $finish;
end

endmodule
