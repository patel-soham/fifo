// Asynchronous FIFO design 
module fifo_async (
// Write interface
wr_clk_i, rst_i, wr_en_i, wdata_i, full_o, wr_error_o, 
// Read interface
rd_clk_i, rd_en_i, rdata_o, empty_o, rd_error_o);

parameter DEPTH=16, // Depth if FIFO
		  WIDTH=8, // Data width on each location
		  PTR_WIDTH=4; // Pointer width to address all locations (depth)

input rd_clk_i, wr_clk_i, rst_i, wr_en_i, rd_en_i;
input [WIDTH-1 : 0] wdata_i;
output reg full_o, empty_o, wr_error_o, rd_error_o;
output reg [WIDTH-1 : 0] rdata_o;

reg wr_toggle_f, rd_toggle_f, wr_toggle_f_rd_clk, rd_toggle_f_wr_clk;
reg [PTR_WIDTH-1 : 0] wr_ptr, rd_ptr, wr_ptr_rd_clk, rd_ptr_wr_clk, wr_ptr_gray, rd_ptr_gray;
reg [WIDTH-1 : 0] mem [DEPTH-1 : 0];
integer i;

// 2 processes : read and write both happens on different  
// clock so they both have to be coded in 2 different always block

// Write interface
always @ (posedge wr_clk_i) begin
	if (rst_i == 1) begin
		i = 0;
		full_o = 0;
		empty_o = 1;
		wr_error_o = 0;
		rd_error_o = 0;
		rdata_o = 0;
		wr_toggle_f = 0;
		rd_toggle_f = 0;
		wr_toggle_f_rd_clk = 0;
		rd_toggle_f_wr_clk = 0;
		wr_ptr = 0;
		rd_ptr = 0;
		wr_ptr_gray = 0;
		rd_ptr_gray = 0;
		wr_ptr_rd_clk = 0;
		rd_ptr_wr_clk = 0;
		for (i = 0; i < DEPTH; i=i+1) mem[i] = 0;
	end
	else begin
		wr_error_o = 0;
		if (wr_en_i == 1) begin
			if (full_o == 1) wr_error_o = 1; // trying to write when fifo is full
			else begin
				mem[wr_ptr] = wdata_i;
				if (wr_ptr == DEPTH-1) wr_toggle_f = ~wr_toggle_f;
				wr_ptr = wr_ptr + 1;
				// gray code conversion before synchronizing to avoid glitch conditions
				wr_ptr_gray = bin2gray(wr_ptr);
			end
		end
	end
end

// Read interface
always @ (posedge rd_clk_i) begin
	if (rst_i != 1) begin
		rd_error_o = 0;
		if (rd_en_i == 1) begin
			if (empty_o == 1) rd_error_o = 1; // trying to read when fifo is empty
			else begin
				rdata_o = mem[rd_ptr];
				if (rd_ptr == DEPTH-1) rd_toggle_f = ~rd_toggle_f;
				rd_ptr = rd_ptr + 1;
				// gray code conversion before synchronizing to avoid glitch conditions
				rd_ptr_gray = bin2gray(rd_ptr); 
			end
		end
	end
end

// Logic for full and empty generation
// can be sequential or combinational
always @ (*) begin
	empty_o = 0;
	full_o = 0;
	// All conditions here are synchronized for write clk because full signal
	// is connected to write interface
	if (wr_ptr_gray == rd_ptr_wr_clk) begin
		if (wr_toggle_f != rd_toggle_f_wr_clk) full_o = 1;
	end
	// All conditions here are synchronized for read clk because empty signal
	// is connected to read interface
	if (wr_ptr_rd_clk == rd_ptr_gray) begin
		if (wr_toggle_f_rd_clk == rd_toggle_f) empty_o = 1;
	end
end

// Here ptr controls toogle flag, then they control empty and full conditions
// which are not syncronized for both interface with different clocks. So 
// we use synchronizers to prevent metastabiltiy condition. To avoid changing
// either flags during restricted time in either of the clocks. (setup / hold)

always @ (posedge wr_clk_i) begin
	rd_ptr_wr_clk <= rd_ptr_gray;
	rd_toggle_f_wr_clk <= rd_toggle_f;
end

always @ (posedge rd_clk_i) begin
	wr_ptr_rd_clk <= wr_ptr_gray;
	wr_toggle_f_rd_clk <= wr_toggle_f;
end

function reg [PTR_WIDTH-1 : 0] bin2gray (input reg [PTR_WIDTH-1 : 0] bin);
	begin
		bin2gray = { bin[PTR_WIDTH-1], bin[PTR_WIDTH-1:1] ^ bin[PTR_WIDTH-2:0]  };
	end
endfunction

endmodule
