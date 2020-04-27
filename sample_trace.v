`timescale 1ns/ 1ps

module trace_file(input [15:0] addr,
                  output reg [31:0] reference);
    // Use these as the tags for now         
    always @ (*) begin
        case (addr)
            16'h0000: reference <= 32'h00000000;
            16'h0001: reference <= 32'h00000000;
            16'h0002: reference <= 32'h50000000;
            16'h0003: reference <= 32'h50000000;
            16'h0004: reference <= 32'h50000000;
            16'h0005: reference <= 32'h00000000;
            default: reference <= 32'hXXXX;
        endcase
    end
endmodule