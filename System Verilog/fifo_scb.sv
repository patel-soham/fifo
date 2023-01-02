class fifo_scb;

fifo_tx wr_tx, rd_tx;

// 2 different mailboxes for read and write transactions
mailbox mon2scb_wr, mon2scb_rd;

// fifo checker
int fifo [$:`DEPTH]; // fixed size queue of depth size
bit wr_err, rd_err, read_check; 

//semaphore to control working on same fifo queue
semaphore key; 

//getting mailboxes from environment
function new(mailbox mon2scb_wr, mailbox mon2scb_rd);
	this.mon2scb_wr = mon2scb_wr;
	this.mon2scb_rd = mon2scb_rd;
	key = new(1);
endfunction

task run();
	fork
		read();
		write();
	join
endtask

task write();
	forever begin
		mon2scb_wr.get(wr_tx);
		key.get(1);

		if(wr_err==1) begin
			if(wr_tx.wr_error_o==1)
				$display("Write error check pass");
			else
				$display("!!!!Write error check fail!!!!");
			wr_err = 0;
		end
		if(fifo.size() == `DEPTH)begin
			if(wr_tx.full_o==1 || read_check==1)
				$display("Full signal check pass");
			else
				$display("!!!!Full signal check fail!!!!");
		end

		if(wr_tx.wr_en_i==1 && wr_tx.full_o==0)
			fifo.push_back(wr_tx.wdata_i);

		// logic to test write error signal
		if(wr_tx.wr_en_i==1 && wr_tx.full_o==1)
			wr_err = 1;
		
		key.put(1);
	end
endtask

task read();
	forever begin
		mon2scb_rd.get(rd_tx);
		key.get(1);

		if(rd_err==1) begin
			if(rd_tx.rd_error_o==1)
				$display("Read error check pass");
			else
				$display("!!!!Read error check fail!!!!");
			rd_err = 0;
		end
		if(fifo.size()==0) begin 
			if(rd_tx.empty_o==1)
				$display("Empty signal check pass");
			else
				$display("!!!!Empty signal check fail!!!!");
		end
		if(read_check==1) begin
			if(rd_tx.rdata_o == fifo.pop_front())
				$display("Data buffer check pass");
			else
				$display("!!!!Data buffer check fail!!!!");
			read_check=0;
		end

		if(rd_tx.rd_en_i==1 && rd_tx.empty_o==0) 
			read_check=1;

		// logic to test read error signal
		if(rd_tx.rd_en_i==1 && rd_tx.empty_o==1)
			rd_err=1;
		
		key.put(1);
	end
endtask

endclass
