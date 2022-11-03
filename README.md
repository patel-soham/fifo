# FIFO using verilog
A project to implement synchronous FIFO and asynchronous FIFO using verilog.
- Developed various test cases to verify empty, full, read error, write error and concurrent reads & writes through testbench.
- Implemented gray counter instead of regular counter for read and write pointers in Asynchronous FIFO to avoid glitch conditions.

---
**Files**
1. Asynchronous FIFO [design](fifo_async/fifo_async.v), [testbench](fifo_async/tb_fifo_async.v) and [run.do](fifo_async/run.do)
2. Synchronous FIFO [design](fifo_sync/fifo_sync.v), [testbench](fifo_sync/tb_fifo_sync.v) and [run.do](fifo_sync/run.do)
