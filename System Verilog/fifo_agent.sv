// write agent class contains driver, generator and monitor
// acting as component that writes in fifo
class fifo_agent;

virtual fifo_intf vif;

fifo_gen gen;
fifo_drv drv;
fifo_mon mon;

// 2 different mailboxes for read and write transactions
mailbox gen2drv_wr, gen2drv_rd, mon2scb_wr, mon2scb_rd;

//event 
event wr_done, rd_done;

//getting mailboxes from environment
function new(virtual fifo_intf vif, mailbox mon2scb_wr, mailbox mon2scb_rd);
	this.vif = vif;
	this.mon2scb_wr = mon2scb_wr;
	this.mon2scb_rd = mon2scb_rd;
	gen2drv_wr = new();
	gen2drv_rd = new();
	drv = new(vif, gen2drv_wr, gen2drv_rd);
	mon = new(vif, mon2scb_wr, mon2scb_rd);
	gen = new(gen2drv_wr, gen2drv_rd);

	gen.wr_done = this.wr_done;
	drv.wr_done = this.wr_done;
	gen.rd_done = this.rd_done;
	drv.rd_done = this.rd_done;

endfunction

task run();
	fork
		gen.run();
		drv.run();
		mon.run();
	join
endtask

endclass
