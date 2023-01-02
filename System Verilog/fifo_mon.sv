// monitor collects signals from interface and 
// sends packets to scoreboard
class fifo_mon;

fifo_tx wr_tx, rd_tx;

virtual fifo_intf vif;

// 2 different mailboxes for read and write transactions
mailbox mon2scb_wr, mon2scb_rd;

//getting mailboxes from agent (from environment)
function new(virtual fifo_intf vif, mailbox mon2scb_wr, mailbox mon2scb_rd);
	this.vif = vif;
	this.mon2scb_wr = mon2scb_wr;
	this.mon2scb_rd = mon2scb_rd;
endfunction

task run();
	fork
		wr_pack();
		rd_pack();
	join
endtask

task wr_pack();
	forever begin
		@(vif.mon_wr_mb.mon_wr_cb);	
		wr_tx = new();
		wr_tx.wr_en_i = vif.mon_wr_mb.mon_wr_cb.wr_en_i;
		wr_tx.wdata_i = vif.mon_wr_mb.mon_wr_cb.wdata_i;	
		wr_tx.full_o = vif.mon_wr_mb.mon_wr_cb.full_o;
		wr_tx.wr_error_o = vif.mon_wr_mb.mon_wr_cb.wr_error_o;
		mon2scb_wr.put(wr_tx);
	end
endtask

task rd_pack();
	forever begin
		@(vif.mon_rd_mb.mon_rd_cb);	
		rd_tx = new();
		rd_tx.rd_en_i = vif.mon_rd_mb.mon_rd_cb.rd_en_i;
		rd_tx.rdata_o = vif.mon_rd_mb.mon_rd_cb.rdata_o;
		rd_tx.empty_o = vif.mon_rd_mb.mon_rd_cb.empty_o;
		rd_tx.rd_error_o = vif.mon_rd_mb.mon_rd_cb.rd_error_o;
		mon2scb_rd.put(rd_tx);
	end
endtask

endclass
