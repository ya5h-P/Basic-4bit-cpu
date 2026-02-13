`timescale 1ns / 1ps
module instruction_memory (
    input [7:0] address,           // address from PC
    output [7:0] instruction       // 8-bit instruction output
);

// Memory array: 256 locations, 8 bits each
reg [7:0] mem [0:255];

// Read operation (combinational)
assign instruction = mem[address];

// Load program from external file
initial begin
    $readmemb("program.mem", mem);
end

endmodule