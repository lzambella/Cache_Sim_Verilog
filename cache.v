`timescale 1ns/1ps

/*
    2048 Byte cache
    16 lines per set
    16 sets

    The cache module should contain 16 different cache sets
    The index of the reference determines which set to pull from

    the offset determines which buddy to bring into the line but this is not as important
    The general idea is that if the tag for a given index matches; then there is a hit
*/
module Cache(
    input clk,              // Clock
    input [31:0] addr_in    // Memory reference input

);

endmodule