// Synchronous FIFO design 
module fifo_sync (
// Common 
clk_i,
// Write interface
rst_i, wr_en_i, wdata_i, full_o, wr_error_o, 
// Read interface
rd_en_i, rdata_o, empty_o, rd_error_o);

parameter DEPTH=16, // Depth if FIFO
		  WIDTH=8, // Data width on each location
		  PTR_WIDTH=4; // Pointer width to address all locations (depth)

input clk_i, rst_i, wr_en_i, rd_en_i;
input [WIDTH-1 : 0] wdata_i;
output reg full_o, empty_o, wr_error_o, rd_error_o;
output reg [WIDTH-1 : 0] rdata_o;

reg wr_toggle_f, rd_toggle_f;
reg [PTR_WIDTH-1 : 0] wr_ptr, rd_ptr;
reg [WIDTH-1 : 0] mem [DEPTH-1 : 0];
integer i;

// 2 processes : read and write both happens on the same 
// clock so they both can be coded in same always block
always @ (posedge clk_i) begin
	if (rst_i == 1) begin
		i = 0;
		full_o = 0;
		empty_o = 1;
		wr_error_o = 0;
		rd_error_o = 0;
		rdata_o = 0;
		wr_toggle_f = 0;
		rd_toggle_f = 0;
		wr_ptr = 0;
		rd_ptr = 0;
		for (i = 0; i < DEPTH; i=i+1) mem[i] = 0;
	end
	else begin
		rd_error_o = 0;
		wr_error_o = 0;
		// Write process
		if (wr_en_i == 1) begin
			if (full_o == 1) wr_error_o = 1; // trying to write when fifo is full
			else begin
				mem[wr_ptr] = wdata_i;
				if (wr_ptr == DEPTH-1) wr_toggle_f = ~wr_toggle_f;
				wr_ptr = wr_ptr + 1;
			end
		end
		// Read process
		if (rd_en_i == 1) begin
			if (empty_o == 1) rd_error_o = 1; // trying to read when fifo is empty
			else begin
				rdata_o = mem[rd_ptr];
				if (rd_ptr == DEPTH-1) rd_toggle_f = ~rd_toggle_f;
				rd_ptr = rd_ptr + 1;
			end
		end
	end
end

// Logic for full and empty generation
// can be sequential or combinational
always @ (*) begin
	empty_o = 0;
	full_o = 0;
	if (wr_ptr == rd_ptr) begin
		if (wr_toggle_f == rd_toggle_f) empty_o = 1;
		if (wr_toggle_f != rd_toggle_f) full_o = 1;
	end
end

endmodule
