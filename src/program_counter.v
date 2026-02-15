`timescale 1ns / 1ps
module program_counter (
    input clk,
    input reset,
    input halt,                // stop incrementing
    input jump_enable,         // enable jump
    input [7:0] jump_addr,     // jump target address
    input pc_inc_2,            // increment by 2 (for multi-byte instructions)
    output reg [7:0] pc
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc <= 8'b0;
    end else if (!halt) begin
        if (jump_enable) begin
            pc <= jump_addr;      // Jump to new address
        end else if (pc_inc_2) begin
            pc <= pc + 2;         // Skip next byte (multi-byte instruction)
        end else begin
            pc <= pc + 1;         // Normal increment
        end
    end
    // If halt=1, PC stays the same
end

endmodule