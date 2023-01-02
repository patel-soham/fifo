// driver collects tx packets from generator 
// drives signal to dut
class fifo_drv;

fifo_tx wr_tx, rd_tx;

virtual fifo_intf vif;

// 2 different mailboxes for read and write transactions
mailbox gen2drv_wr, gen2drv_rd;

//event 
event wr_done, rd_done;

//getting mailboxes from agent
function new(virtual fifo_intf vif, mailbox gen2drv_wr, mailbox gen2drv_rd);
	this.vif = vif;
	this.gen2drv_rd = gen2drv_rd;
	this.gen2drv_wr = gen2drv_wr;
endfunction

task run();
	fork
		wr_op();
		rd_op();
	join
endtask

task wr_op();
	forever begin
		gen2drv_wr.get(wr_tx);
		drive_wr(wr_tx);
		->wr_done; //handshaking with generator
	end
endtask

task rd_op();
	forever begin
		gen2drv_rd.get(rd_tx);
		drive_rd(rd_tx);
		->rd_done; //handshaking with generator
	end
endtask

task drive_wr(fifo_tx tx);
	@(vif.drv_wr_mb.drv_wr_cb);
	vif.drv_wr_mb.drv_wr_cb.wr_en_i <= tx.wr_en_i;
	vif.drv_wr_mb.drv_wr_cb.wdata_i <= tx.wdata_i;
	@(vif.drv_wr_mb.drv_wr_cb);
	vif.drv_wr_mb.drv_wr_cb.wr_en_i <= 0;
	vif.drv_wr_mb.drv_wr_cb.wdata_i <= 0;
endtask

task drive_rd(fifo_tx tx);
	@(vif.drv_rd_mb.drv_rd_cb);
	vif.drv_rd_mb.drv_rd_cb.rd_en_i <= tx.rd_en_i;
	@(vif.drv_rd_mb.drv_rd_cb);
	vif.drv_rd_mb.drv_rd_cb.rd_en_i <= 0;
endtask

endclass
