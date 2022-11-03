`include "fifo_async.v"
`timescale 1ns/1ps
// Already passing SEED through run.do
//`define SEED 2345
// seed for generating random delay

module tb;

parameter DEPTH=16, // Depth if FIFO
		  WIDTH=8, // Data width on each location
		  PTR_WIDTH=4, // Pointer width to address all locations (depth)
     	  	  RD_CLK_TP=14, // Time period of read interface clock
		  WR_CLK_TP=10, // Time period of write interfsce clock
		  MAX_RD_DELAY=10, // Maximum delay between 2 read cycles  
		  MAX_WR_DELAY=14, // Maximum delay between 2 write cycles  
		  NUM_TXS=100; // Number of read and write transactions
// Based on values of TP and MAX DELAY of both interfaces the write and read errors frequency will vary

reg rd_clk_i, wr_clk_i, rst_i, wr_en_i, rd_en_i;
reg [WIDTH-1 : 0] wdata_i;
wire full_o, empty_o, wr_error_o, rd_error_o;
wire [WIDTH-1 : 0] rdata_o;

integer i, j, k, l, wr_delay, rd_delay;
reg [30*8 : 1] testname;

fifo_async #(.DEPTH(DEPTH), .WIDTH(WIDTH), .PTR_WIDTH(PTR_WIDTH)) u0 (.rd_clk_i(rd_clk_i), .wr_clk_i(wr_clk_i), .rst_i(rst_i), .wr_en_i(wr_en_i), .wdata_i(wdata_i), .full_o(full_o), .wr_error_o(wr_error_o), .rd_en_i(rd_en_i), .rdata_o(rdata_o), .empty_o(empty_o), .rd_error_o(rd_error_o));

//Clock generation 
initial begin
	rd_clk_i = 0;
	forever #(RD_CLK_TP/2.0) rd_clk_i = ~rd_clk_i;
end

initial begin
	wr_clk_i = 0;
	forever #(WR_CLK_TP/2.0) wr_clk_i = ~wr_clk_i;
end

initial begin
	$value$plusargs("testname=%s",testname);
	i = 0;
	j = 0;
	k = 0;
	l = 0;
	wr_delay = 0;
	rd_delay = 0;
	wr_en_i = 0;
	rd_en_i = 0;
	wdata_i = 0;

	rst_i = 1;
	@ (posedge wr_clk_i);
	rst_i = 0;
	
	case(testname)
		// test case for writing till fifo is full to get full output
		"test_full": begin
			write_fifo(DEPTH);
		end
		// test case for writing and then reading till fifo is empty to get empty output 
		"test_empty": begin
			write_fifo(DEPTH);
			read_fifo(DEPTH);
		end
		// test case for writing more than capacity of fifo to get write error output
		"test_full_error": begin
			write_fifo(DEPTH+1);
		end
		// test case for writing and then reading more than capacity of fifo
		// to get read error output
		"test_empty_error": begin
			write_fifo(DEPTH);
			read_fifo(DEPTH+1);
		end
		// test case for random read write operations concurrently on fifo
		"test_concurrent_wr_rd": begin
		`ifdef SEED
			$display("Seed passed through command.");
		`else
			$display("Seed not passed.");
		`endif
			fork
				begin
					// Performing 100 write operations with random delay between each
					for (k=0; k<NUM_TXS; k=k+1) begin
						write_fifo(1);
						`ifdef SEED
							wr_delay = ($urandom(`SEED+k)%MAX_WR_DELAY) + 1;
						`else
							// OR without seed
							wr_delay = $urandom_range(1, MAX_WR_DELAY);
						`endif
						repeat (wr_delay) @(posedge wr_clk_i);
					end
				end
				begin
					// Performing 100 read operations with random delay between each
					for (l=0; l<NUM_TXS; l=l+1) begin
						read_fifo(1);
						`ifdef SEED
							rd_delay = ($urandom(`SEED+l)%MAX_RD_DELAY) + 1;
						`else
							// OR without seed
							rd_delay = $urandom_range(1, MAX_RD_DELAY);
						`endif
						repeat (rd_delay) @(posedge rd_clk_i);
					end
				end
			join
		end

		default: begin
			$display("*********Error in test case type!**************");
		end
	endcase
	#10 $finish;
end

// Task to perform desired number of write operations on fifo 
task write_fifo(input integer num_wr);
begin
	wr_en_i = 1;
	for(i=0; i<num_wr; i=i+1) begin
		wdata_i = $random;
		@(posedge wr_clk_i);
	end
	wr_en_i = 0;
	wdata_i = 0;
	@(posedge wr_clk_i);
end
endtask

// Task to perform desired number of read operations on fifo 
task read_fifo(input integer num_wr);
begin
	for(j=0; j<num_wr; j=j+1) begin
		rd_en_i = 1;
		@(posedge rd_clk_i);
	end
	rd_en_i = 0;
	@(posedge rd_clk_i);
end
endtask

endmodule
