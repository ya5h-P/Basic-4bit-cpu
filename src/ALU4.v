`timescale 1ns / 1ps
module ALU4(
    input  [3:0] A,
    input  [3:0] B,
    input  [3:0] ALUop,        // 4-bit opcode now (was 3-bit)
    input  [3:0] immediate,    // NEW: for LDI instruction
    output reg [3:0] result,
    output zero                // NEW: zero flag for conditional jumps
);

// Zero flag: true if result is 0
assign zero = (result == 4'b0000);

always @(*) begin
    case (ALUop)
        // Arithmetic
        4'b0000: result = A + B;           // ADD
        4'b0001: result = A - B;           // SUB
        4'b0010: result = A + 1;           // INC (ignore B)
        4'b0011: result = A - 1;           // DEC (ignore B)
        
        // Logic
        4'b0100: result = A & B;           // AND
        4'b0101: result = A | B;           // OR
        4'b0110: result = A ^ B;           // XOR
        4'b0111: result = ~A;              // NOT (ignore B)
        
        // Data Movement
        4'b1000: result = B;               // MOV (result = source)
        4'b1001: result = immediate;       // LDI (load immediate value)
        4'b1010: result = A;               // LDR (pass through memory data)
        4'b1011: result = B;               // STR (pass through register data)
        
        // These don't use ALU, but need placeholder
        4'b1100: result = 4'b0000;         // JMP (no ALU operation)
        4'b1101: result = 4'b0000;         // JZ (no ALU operation)
        4'b1110: result = 4'b0000;         // CALL (no ALU operation)
        4'b1111: result = 4'b0000;         // RET/HALT (no ALU operation)
        
        default: result = 4'b0000;
    endcase
end

endmodule