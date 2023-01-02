// generator gives packets to driver 
class fifo_gen;

// config bit to run write & read concurrent or not
bit concurrent;
// counter for write and read transactions
int wr_count, rd_count;
int wr, rd;

// transaction handle 
// tx handle points to modified class from test program
fifo_tx tx, wr_tx, rd_tx;

// 2 mailboxes for read and write transactions
mailbox gen2drv_wr, gen2drv_rd;

//event 
event wr_done, rd_done;

function new(mailbox gen2drv_wr, gen2drv_rd);
	this.gen2drv_rd = gen2drv_rd;
	this.gen2drv_wr = gen2drv_wr;
endfunction

task run();
	if(wr_count==0 && rd_count==0)
		$display("*****NO PACKETS SENT FROM GENERATOR********");
	if (concurrent) begin // based on concurrent bit, perform wr,rd
		fork
			run_wr();
			run_rd();
		join
	end
	else begin
		run_wr();
		run_rd();
	end
endtask

task run_wr();
	repeat(wr_count) begin
		assert(tx.randomize() with {wr_en_i==1; rd_en_i==0;});
		wr_tx = tx.copy();
		gen2drv_wr.put(wr_tx);
		@(wr_done);
	end
endtask
task run_rd();
	repeat(rd_count) begin
		assert(tx.randomize() with {wr_en_i==0; rd_en_i==1;});
		rd_tx = tx.copy();
		gen2drv_rd.put(rd_tx);
		@(rd_done);
	end
endtask

endclass
