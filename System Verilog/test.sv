// test program to test fifo
program test(fifo_intf pif);

class tx extends fifo_tx;
	// extra constraints if required for this test
endclass

fifo_env env;
tx tx_modified;

initial begin
	env=new(pif);
	tx_modified = new(); 	

	// Change frequency of read and write clock cycles from headers file
	// Change fifo depth or data width from headers file
	// USE ANY ONE OF CASE TO TEST FIFO, COMMENT REST

	// 1. test case for writing till fifo is full to get full output
	env.agent.gen.wr_count = `DEPTH;
	env.agent.gen.rd_count = 0;
	env.agent.gen.concurrent = 0;

	// 2. test case for writing and then reading till fifo is empty to get empty output
	env.agent.gen.wr_count = `DEPTH;
	env.agent.gen.rd_count = `DEPTH;
	env.agent.gen.concurrent = 0;

	// 3. test case for writing more than capacity of fifo to get write error output
	env.agent.gen.wr_count = `DEPTH+1;
	env.agent.gen.rd_count = 0;
	env.agent.gen.concurrent = 0;
	
	// 4. test case for writing and then reading more than capacity of fifo
	// to get read error output
	env.agent.gen.wr_count = `DEPTH;
	env.agent.gen.rd_count = `DEPTH+1;
	env.agent.gen.concurrent = 0;

	// 5. test case for random read write operations concurrently on fifo
	env.agent.gen.wr_count = 50;
	env.agent.gen.rd_count = 50;
	env.agent.gen.concurrent = 1; //run first write then read 
	

	env.agent.gen.tx = tx_modified;

	repeat(3) @ (posedge pif.wr_clk_i); // wait for reset to finish
	env.run();
end

endprogram
