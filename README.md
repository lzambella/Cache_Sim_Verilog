# Verilog cache implementation

The easiest way to run is to type `iverilog *.v` and then `vvp a.out` in the same directory as the V files.

Icarus verilog or equivalent is needed. To run with vivado, drop all the verilog files into a new project. The trace files either need to be placed in the same directory as the verilog files or somewhere else.

Currently, the testbench uses any of the three trace text files to only measure the miss rate. To change between them, modify the test bench to point towards these finales in the initialize block. The trace size at the top of the file have to be changed accordingly as well.

This cache system uses 16 sets each containing 16 lines. The replacement policy is FIFO.

## Features

* Proper tag/index/offset splitting
* Set searching and LIFO replacement
* Keeps track of hit and miss counts.

## To do

* Implement actual data storing and retrieval
* Optimize FSM/make it work in one cycle
* Integrate with the LEGv8 ARM CPU