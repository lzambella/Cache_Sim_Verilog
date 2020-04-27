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
    input [31:0] addr_in,   // Memory reference input
    input state,
    output reg hit          // output one if any set returns a hit
);
    // Hit outputs from each cache set
    // 16 bit bus
    wire hit_lines [15:0];
    reg enable_lines [15:0];
    

    // Get components from input address
    wire [26:0] tag;
    wire [4:0] index;
    wire offset;

    assign offset = addr_in[0];
    assign index = addr_in[4:1];
    assign tag = addr_in[31:5];

    // Generate 16 unique cache sets easily
    genvar i;
    generate
        for (i = 0; i <= 15; i = i + 1) begin
            cache_set set(.tag(tag),                    // tag input
                          .enable(enable_lines[i]),     // enabler for each set
                          .state(state),                // current state of the FSM
                          .hit(hit_lines[i]));          // output hit
        end
    endgenerate


    always @ (state) begin
        /*
        What happens in the states is the inverse of what normally would happen because of propagation

        So in the read state, reset the hit if any and enable the set at the index for writing
        in the write state, check if there was a hit and increment the hit count

        The actual set modules themselves are synced correctly to their proper sets (read to read and write to write).
        */
        case (state)
            'b0: begin
                //enable the cache at the index for writing
                enable_lines[index] <= 1;
                hit <= 0;
            end
            // Check for hits during the write stage
            'b1: begin
                if (hit_lines[index] == 1) begin
                    //$display("Hit @ index %d : %d",index, hit_lines[index]);
                    hit <= 1;
                end
                enable_lines[index] <= 0;
            end
        endcase
    end
endmodule