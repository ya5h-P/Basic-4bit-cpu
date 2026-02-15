`timescale 1ns / 1ps
module data_memory (
    input clk,
    input we,                  // write enable
    input [7:0] address,       // 8-bit address (256 locations)
    input [3:0] write_data,    // 4-bit data to write
    output [3:0] read_data     // 4-bit data to read
);

reg [3:0] mem [0:255];  // 256 x 4-bit memory

// Read operation (combinational)
assign read_data = mem[address];

// Write operation (sequential)
always @(posedge clk) begin
    if (we)
        mem[address] <= write_data;
end
endmodule