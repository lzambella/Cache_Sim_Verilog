`timescale 1ns / 1ps
module testbench();

    reg [26:0] tag;
    reg state;
    reg clk;
    reg [15:0] addr_in;
    wire [31:0] ref_addr;

    wire hit;

    cache_set set(.tag(ref_addr),
                       .hit(hit),
                       .state(state),
                       .clk(clk)
                       );

    trace_file tags(.addr(addr_in),
                    .reference(ref_addr));
    always begin
        #5
        clk = ~clk;
    end

    /*
    * Send reference to cache when in search state
    * Update to the next state
    */
    always @ (posedge clk) begin
        // FSM Code
        if (state == 0) begin
            // TODO: add code to send the next reference from the trace files to the cache
            // TODO: Get real reference addresses and split the tag index and offsets from them
            state <= 1;
        end else begin
            addr_in <= addr_in + 1;
            state <= 0;
        end
    end
    initial begin
        $dumpvars(0);
        clk = 0;
        addr_in = 0;
        state = 0;
        #1000
        $finish;
    end
endmodule