`timescale 1ns / 1ps
module testbench();
    `define TRACE_SIZE 57962

    reg [26:0] tag;
    reg state;
    reg clk;
    reg [31:0] addr_in;
    reg [15:0] hit_count;

    wire [31:0] ref_addr;

    wire hit;

    cache cache_sim(.addr_in(ref_addr),
                    .state(state),
                    .hit(hit));

    always begin
        #5
        clk = ~clk;
    end
    integer i;
    // 180KB of ROM data
    reg [31:0] test_memory [`TRACE_SIZE:0];
    assign ref_addr = test_memory[addr_in];
    /*
    * Send reference to cache when in search state
    * Update to the next state
    */
    always @ (posedge clk) begin
        // FSM Code
        if (state == 0) begin
            addr_in <= addr_in + 1;
            state <= 1;
        end else begin
            if (hit == 1) begin
                hit_count = hit_count + 1;
            end
            state <= 0;
            if(addr_in == `TRACE_SIZE) begin 
                $display("Total references: %d\nMiss Count: %d", addr_in, addr_in - hit_count);
                $finish;
            end
        end
    end
    initial begin
        $dumpvars(0);
        clk = 0;
        addr_in = 0;
        state = 0;
        hit_count = 0;
        $readmemh("TRACE1.TXT", test_memory);
        for (i = 0; i < 10; i = i + 1) begin
            $display("%h", test_memory[i]);
        end
    end
endmodule