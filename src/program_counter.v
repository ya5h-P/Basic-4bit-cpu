`timescale 1ns / 1ps
module program_counter (
    input clk,
    input reset,
    output reg [7:0] pc  // 8-bit PC = can address 256 instructions
);

always @(posedge clk or posedge reset) begin
    if (reset)
        pc <= 8'b0;      // start at instruction 0
    else
        pc <= pc + 1;    // increment every clock cycle
end

endmodule