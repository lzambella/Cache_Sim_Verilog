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
    input [24:0] tag,               // tag to pull data from
    input mem_write,                // push write_data flag
    input state,                    // state input for FSM
    input enable,                   // set enable line
    output reg [63:0] read_data,    // popped data
    output reg hit                  // 1 if the data already exists
    );

    `define STATE_SEARCH 0
    `define STATE_UPDATE 1
    /*
    * Write and read pointers are used to simulate FIFO functionality
    * When an item is pushed, increment the write pointer
    * When an item is popped, increment the read pointer'
    * Uses a circular buffer technique and the values should always wrap around when overflowed
    * The FIFO is empty when the write pointer equals the read pointer
    */
    reg unsigned [3:0] write_ptr;    // Pointer to address to write data to
    reg unsigned [3:0] read_ptr;     // Pointer to address to read data at
    reg unsigned [4:0] cache_size;
    // Current size of the cache
    integer i;

    // Set up the tag storage for each way
    // the tag for a 4 byte reference (32 bits) is exactly 27 bits
    // Want to be able to store at most 16 of these tags
    reg [24:0] tags [15:0];

    // Set up the same for the valid bits as well (1 bit each)
    reg valid_bits [15:0];

    // Do the same for the actual contents of memory
    reg [61:0] data_memory [15:0];


    /**
    * Syncronous FIFO operation for pushing and removing old data
    * Outputs a hit if the data already exists
    */
    always @ (posedge clk) begin
            case (state)
            // Search the cache
            0: begin
            /*
                for (i = 0; i < 16; i++) begin          // Check each cell in the tag queue for a hit
                    //$display("Content at location %h: %h",i, tags[i]);
                    // First check if tag exists and is valid
                    if (tags[i] == tag && valid_bits[i] == 1 && enable == 1) begin
                        // Get the data referenced by the memory
                        read_data <= data_memory[i];    // Output the data
                        hit <= 1;                       // Send a hit
                        $display("HIT tag %h found at index %d", tag, i);
                    end
                end
                */
                if (tags[0] == tag && valid_bits[0] == 1 && enable == 1) begin
                        read_data <= data_memory[0];    // Output the data
                        hit <= 1;                       // Send a hit
                end else if (tags[1] == tag && valid_bits[1] == 1 && enable == 1) begin
                        read_data <= data_memory[1];    // Output the data
                        hit <= 1;                       // Send a hit         
                end else if (tags[2] == tag && valid_bits[2] == 1 && enable == 1) begin
                        read_data <= data_memory[1];    // Output the data
                        hit <= 1;                       // Send a hit   
                end else if (tags[3] == tag && valid_bits[3] == 1 && enable == 1) begin
                        read_data <= data_memory[1];    // Output the data
                        hit <= 1;                       // Send a hit
                end else if (tags[4] == tag && valid_bits[4] == 1 && enable == 1) begin
                        read_data <= data_memory[1];    // Output the data
                        hit <= 1;                       // Send a hit
                end else if (tags[5] == tag && valid_bits[5] == 1 && enable == 1) begin
                        read_data <= data_memory[1];    // Output the data
                        hit <= 1;                       // Send a hit
                end else if (tags[6] == tag && valid_bits[6] == 1 && enable == 1) begin
                        read_data <= data_memory[1];    // Output the data
                        hit <= 1;                       // Send a hit
                end else if (tags[7] == tag && valid_bits[7] == 1 && enable == 1) begin
                        read_data <= data_memory[1];    // Output the data
                        hit <= 1;                       // Send a hit
                end else if (tags[8] == tag && valid_bits[8] == 1 && enable == 1) begin
                        read_data <= data_memory[1];    // Output the data
                        hit <= 1;                       // Send a hit
                end else if (tags[9] == tag && valid_bits[9] == 1 && enable == 1) begin
                        read_data <= data_memory[1];    // Output the data
                        hit <= 1;                       // Send a hit
                end else if (tags[10] == tag && valid_bits[10] == 1 && enable == 1) begin
                        read_data <= data_memory[1];    // Output the data
                        hit <= 1;                       // Send a hit
                end else if (tags[11] == tag && valid_bits[11] == 1 && enable == 1) begin
                        read_data <= data_memory[1];    // Output the data
                        hit <= 1;                       // Send a hit
                end else if (tags[12] == tag && valid_bits[12] == 1 && enable == 1) begin
                        read_data <= data_memory[1];    // Output the data
                        hit <= 1;                       // Send a hit
                end else if (tags[13] == tag && valid_bits[13] == 1 && enable == 1) begin
                        read_data <= data_memory[1];    // Output the data
                        hit <= 1;                       // Send a hit
                end else if (tags[14] == tag && valid_bits[14] == 1 && enable == 1) begin
                        read_data <= data_memory[1];    // Output the data
                        hit <= 1;                       // Send a hit
                end else if (tags[15] == tag && valid_bits[15] == 1 && enable == 1) begin
                        read_data <= data_memory[1];    // Output the data
                        hit <= 1;                       // Send a hit
                end else begin
                    // Check if the cache is full first
                    if (cache_size == 16) begin
                        // replace the reference at the READ POINTER with the new reference
                        // then increment both the read pointer and write pointer
                        tags[read_ptr] <= tag;                  // Update the tag at the pointer
                        read_ptr <= read_ptr + 1;               // Increment the read pointer
                        write_ptr <= write_ptr + 1;             // Increment the write pointer as well
                        data_memory[write_ptr] <= write_data;   // Update the data that the address refers to

                    // Otherwise we can just add a new reference
                    end else begin 
                        // add the reference to the location referred to by the write pointer
                        // Then increment the write pointer and the total size
                        tags[write_ptr] <= tag;         // Set the set's tag cell to the tag we were looking for
                        valid_bits[write_ptr] <= 1;     // The valid bit is now one since there is now a reference in the cell
                        write_ptr <= write_ptr + 1;     // Increment the write pointer which tells us where to write subsequent data to
                        cache_size <= cache_size + 1;   // Increment the cache set's queue size
                    end
                end
            end
            // Update the cache
            1: begin
                // Only update the cache if there was no hit and the set was enabled
                if (enable == 1) begin
                    // Check if the cache is full first
                    if (cache_size == 16) begin
                        // replace the reference at the READ POINTER with the new reference
                        // then increment both the read pointer and write pointer
                        tags[read_ptr] <= tag;                  // Update the tag at the pointer
                        read_ptr <= read_ptr + 1;               // Increment the read pointer
                        write_ptr <= write_ptr + 1;             // Increment the write pointer as well
                        data_memory[write_ptr] <= write_data;   // Update the data that the address refers to

                    // Otherwise we can just add a new reference
                    end else begin 
                        // add the reference to the location referred to by the write pointer
                        // Then increment the write pointer and the total size
                        tags[write_ptr] <= tag;         // Set the set's tag cell to the tag we were looking for
                        valid_bits[write_ptr] <= 1;     // The valid bit is now one since there is now a reference in the cell
                        write_ptr <= write_ptr + 1;     // Increment the write pointer which tells us where to write subsequent data to
                        cache_size <= cache_size + 1;   // Increment the cache set's queue size
                    end
                end
                // Reset the hit enable in the write stage
                hit <= 0;
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