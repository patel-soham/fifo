// FIFO Transaction class
class fifo_tx;
// No reset or clocks here
rand bit wr_en_i, rd_en_i;
rand bit [`WIDTH-1 : 0] wdata_i;
	 bit full_o, empty_o, wr_error_o, rd_error_o;
	 bit [`WIDTH-1 : 0] rdata_o;

// print method
function void print();
	$display("*********PACKET INFO***********");
	$display("\t wr_en_i : %h", wr_en_i);
	$display("\t rd_en_i : %h", rd_en_i);
	$display("\t wdata_i : %h", wdata_i);
	$display("\t rdata_o : %h", rdata_o);
	$display("\t full_o : %h", full_o);
	$display("\t empty_o : %h", empty_o);
	$display("\t wr_error_o : %h", wr_error_o);
	$display("\t rd_error_o : %h", rd_error_o);
endfunction

//copy method
function fifo_tx copy();
	fifo_tx tx;
	tx=new();
	tx.wr_en_i = this.wr_en_i;
	tx.rd_en_i = this.rd_en_i;
	tx.wdata_i = this.wdata_i;
	tx.rdata_o = this.rdata_o;
	tx.full_o = this.full_o;
	tx.empty_o = this.empty_o;
	tx.wr_error_o = this.wr_error_o;
	tx.rd_error_o = this.rd_error_o;
	return tx;
endfunction
endclass
