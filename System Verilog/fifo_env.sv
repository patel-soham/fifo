// Environment conatians agent and scoreboard 
class fifo_env;

// scoreboard and agent 
fifo_scb scb;
fifo_agent agent;

virtual fifo_intf vif;

// 2 different mailboxes for read and write transactions
mailbox mon2scb_wr, mon2scb_rd;

// recieving virtual interface from test
function new(virtual fifo_intf vif);
		this.vif = vif;
		mon2scb_wr = new();
		mon2scb_rd = new();

		scb = new(mon2scb_wr, mon2scb_rd);
		agent = new(vif, mon2scb_wr, mon2scb_rd);
endfunction

// run environment
task run();
	fork
		scb.run();
		agent.run();
	join
endtask

endclass
