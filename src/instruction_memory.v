`timescale 1ns / 1ps
module instruction_memory (
    input [7:0] address,
    output [7:0] instruction,
    output [7:0] next_byte     // NEW: fetch next byte for multi-byte instructions
);

reg [7:0] mem [0:255];

assign instruction = mem[address];
assign next_byte = (address < 255) ? mem[address + 1] : 8'b0;  // Lookahead

initial begin
    $readmemb("/home/frost/Projects/project_1/program.mem", mem);
end

endmodule