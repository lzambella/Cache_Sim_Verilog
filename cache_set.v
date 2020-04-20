`timescale 1ns/1ps

/*
    Cache FIFO implementation in verilog
    Gives synchronous FIFO write async read functionality.
    hold 16 lines of 4-byte references

    The queue holds 16 lines of 2 words each totalling 32 words
    Each word is 4 bytes long
    Each time a reference is added, we want to bring in its local 'buddy'

    The queue takes a memory write flag to determine whether data should be pushed
    This is clocked sychronously 
    A pointer is used to mark the address of the oldest data
    When the queue is not full, we can simply push data to the end, but when it is full, start removing references from the beginning (check if all valid bits are set to 1?)
    The pointer should start at the beginning of the 'array' of all the data and get updated as new stuff is added
    The old data is simply replaced with the new data at that address
    When the pointer reaches the max limit, just reset it back to zero and restart the cycle.

    The input should only be the tag; the unique identifier for a piece of data in any particular set

    A queue module is essentially one of many sets in the cache, each containing 16 ways for data to be stored

    We need to have two states: one for searching and one for updating
    The search state only searches through the queue to determine whether the reference requested is actually in the cache. This outputs whether there is a hit or miss
    The update state handles adding and removing new and old data.
*/

module cache_set(
    input clk,                      // System clock
    input [63:0] write_data,        // data to PUSH
    input [26:0] tag,               // tag to pull data from
    input mem_write,                // push write_data flag
    input state,                    // state input for FSM
    output reg [63:0] read_data,    // popped data
    output reg hit                  // 1 if the data already exists
    );

    `define STATE_SEARCH = 'b0;
    `define STATE_UPDATE = 'b1;
    /*
    * Write and read pointers are used to simulate FIFO functionality
    * When an item is pushed, increment the write pointer
    * When an item is popped, increment the read pointer'
    * Uses a circular buffer technique and the values should always wrap around when overflowed
    * The FIFO is empty when the write pointer equals the read pointer
    */
    reg [3:0] write_ptr;    // Pointer to address to write data to
    reg [3:0] read_ptr;     // Pointer to address to read data at
    reg [4:0] cache_size;
    // Current size of the cache
    integer i;

    // Set up the tag storage for each way
    // the tag for a 4 byte reference (32 bits) is exactly 27 bits
    // Want to be able to store at most 16 of these tags
    reg [26:0] tags [15:0];
    // Set up the same for the valid bits as well (1 bit each)
    reg valid_bits [15:0];
    // Do the same for the actual contents of memory
    reg [61:0] data_memory [15:0];

    /**
    * Asyncronous reading of cache data
    * Should only be done for testing purposes
    * The syncronous write handles everything (IE return a hit when trying to add a reference that is already stored)
    */
    always @ (*) begin
        // Use a for loop to short hand conditionals
        // This should work because the tags should all be unique
        for (i = 0; i < 15; i++) begin
            // Check if the tag is in there and that it is valid
            if (tags[i] == tag && valid_bits[i] == 1) begin
                read_data <= data_memory[i];
                //$display("Cache hit! input: %h index of tag: %d", tag, i);
            end
        end


    end

    /**
    * Syncronous FIFO operation for pushing and removing old data
    * Outputs a hit if the data already exists
    */
    always @ (posedge clk) begin
        case (state)
            // Search the cache
            'b0: begin
                for (i = 0; i < 15; i++) begin
                    // First check if tag exists and is valid
                    if (tags[i] == tag && valid_bits[i] == 1) begin
                        // Get the data referenced by the memory
                        read_data <= data_memory[i];
                        hit <= 1;
                        $display("Cache hit! input: %h index of tag: %d", tag, i);
                    end
                end
            end
            // Update the cache if there was no hit
            'b1: begin
                // Only update the cache if there was no hit
                if (hit == 0) begin
                    // Check if the cache is full first
                    if (cache_size == 16) begin
                        // replace the reference at the READ POINTER with the new reference
                        // then increment both the read pointer and write pointer
                        tags[read_ptr] <= tag;
                        $display("Replacing data at location %d with tag: %d", read_ptr, tag);
                        read_ptr <= read_ptr + 1;
                        write_ptr <= write_ptr + 1;
                    // Otherwise we can just add a new reference
                    end else begin 
                        // add the reference to the location referred to by the write pointer
                        // Then increment the write pointer and the total size
                        tags[write_ptr] <= tag;
                        valid_bits[write_ptr] <= 1;
                        $display("Adding reference to location %d", write_ptr);
                        write_ptr <= write_ptr + 1;
                        cache_size <= cache_size + 1;
                    end
                end else begin
                    hit <= 0;
                    $display("Data hit");
                end
            end

        endcase
    end
    // Testbench code
    initial begin
        cache_size = 0;     // Initialize size
        read_ptr = 0;
        write_ptr = 0;
    end
endmodule