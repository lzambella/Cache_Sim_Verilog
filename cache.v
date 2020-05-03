`timescale 1ns/1ps

/*
    2048 Byte cache
    16 lines per set
    16 sets

    The cache module should contain 16 different cache sets
    The index of the reference determines which set to pull from

    the offset determines which buddy to bring into the line but this is not as important as this deals with the data itself and not whether the data is in there or not
    The general idea is that if the tag for a given index matches; then there is a hit

    A decoder is used for the index, this determines which cache set to check
    
*/
module cache(
    input clk,
    input [31:0] addr_in,   // Memory reference input
    input state,
    output wire hit          // output one if any set returns a hit
);
    // Hit outputs from each cache set
    // 16 bit bus
    wire [15:0] hit_lines;
    wire [15:0] enable_lines;
    

    // Get components from input address
    wire [24:0] tag;    // 27-bits
    wire [3:0] index;   // 4-bits
    wire offset;        // 1 bit

    assign offset = addr_in[2:0];
    assign index = addr_in[6:3];
    assign tag = addr_in[31:7];

    assign hit = (hit_lines > 0) ? 1 : 0;   // Workaround to check if there were any hits in any of our sets

    // Takes 4 bit index and outputs enable for cache sets
    // This 'selects' the cache for read/writing
    decoder enable_decode(.in(index),
                          .out(enable_lines));

    // Generate 16 unique cache sets easily
    genvar i;
    generate
        for (i = 0; i <= 15; i = i + 1) begin
            cache_set set(.clk(clk),
                          .tag(tag),                    // tag input
                          .enable(enable_lines[i]),     // enabler for each set
                          .state(state),                // current state of the FSM
                          .hit_out(hit_lines[i]));          // output hit
        end
    endgenerate
endmodule