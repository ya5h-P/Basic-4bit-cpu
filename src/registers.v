`timescale 1ns / 1ps
module registers (
    input        clk,
    input        reset,
    input        we,              // single write enable
    input  [1:0] w_addr,          // write address (which register to write)
    input  [3:0] w_data,          // write data
    input  [1:0] r_addr_a,        // read address A (source)
    input  [1:0] r_addr_b,        // read address B (destination, for ALU input)
    output [3:0] r_data_a,        // read data A
    output [3:0] r_data_b         // read data B
);

reg [3:0] regs [0:3];  // 4 registers, 4 bits each

// Read operations (combinational)
assign r_data_a = regs[r_addr_a];
assign r_data_b = regs[r_addr_b];

// Write operation (sequential)
integer i;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 4; i = i + 1)
            regs[i] <= 4'b0000;
    end else if (we) begin
        regs[w_addr] <= w_data;
    end
end

endmodule