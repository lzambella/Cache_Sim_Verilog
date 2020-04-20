`timescale 1ns/ 1ps

module trace_file(input [15:0] addr,
                  output reg [31:0] reference);
    // Use these as the tags for now         
    always @ (*) begin
        case (addr)
            16'h0000: reference <= 32'h00000000;
            16'h0001: reference <= 32'h00000001;
            16'h0002: reference <= 32'h0000000A;
            16'h0003: reference <= 32'h00000000;
            16'h0004: reference <= 32'h000000B0;
            16'h0005: reference <= 32'h00000063;
            16'h0006: reference <= 32'h00000034;
            16'h0007: reference <= 32'h00000074;
            16'h0008: reference <= 32'h00000065;
            16'h0009: reference <= 32'h00000097;
            16'h000A: reference <= 32'h00000345;
            16'h000B: reference <= 32'h00000087;
            16'h000C: reference <= 32'h00000034;
            16'h000D: reference <= 32'h00000098;
            16'h000E: reference <= 32'h00000003;
            16'h000F: reference <= 32'h00000000;
            16'h0010: reference <= 32'h0000000A;
            16'h0011: reference <= 32'h0000045A;
            16'h0012: reference <= 32'h0457000A;
            16'h0014: reference <= 32'h56490986;
            16'h0015: reference <= 32'h75920768;
            16'h0016: reference <= 32'h75934768;
            16'h0017: reference <= 32'h75925768;
            16'h0018: reference <= 32'h75986768;
            16'h0019: reference <= 32'h75914768;
            16'h001A: reference <= 32'h75987768;
            16'h001B: reference <= 32'h75913768;
            default: reference <= 32'hFFFF;
        endcase
    end
endmodule