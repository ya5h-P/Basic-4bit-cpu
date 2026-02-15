`timescale 1ns / 1ps
module stack (
    input clk,
    input reset,
    input push,
    input pop,
    input [7:0] data_in,
    output [7:0] data_out,      // Changed to wire
    output reg overflow,
    output reg underflow
);

reg [7:0] stack_mem [0:15];
reg [3:0] sp;

// Combinational read - immediate output
assign data_out = (sp > 0) ? stack_mem[sp - 1] : 8'b0;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        sp <= 4'b0;
        overflow <= 1'b0;
        underflow <= 1'b0;
    end else begin
        overflow <= 1'b0;
        underflow <= 1'b0;
        
        if (push && !pop) begin
            if (sp < 15) begin
                stack_mem[sp] <= data_in;
                sp <= sp + 1;
            end else begin
                overflow <= 1'b1;
            end
        end else if (pop && !push) begin
            if (sp > 0) begin
                sp <= sp - 1;
            end else begin
                underflow <= 1'b1;
            end
        end
    end
end

endmodule