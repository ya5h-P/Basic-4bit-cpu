`timescale 1ns / 1ps

module ALU4(
    input  [3:0] A,
    input  [3:0] B,
    input  [2:0] ALUop,
    output reg [3:0] result
);

always @(*) begin
    case (ALUop)
        3'b000: result = A + B;        // ADD
        3'b001: result = A - B;        // SUB
        3'b010: result = A & B;        // AND
        3'b011: result = A | B;        // OR
        3'b100: result = A ^ B;        // XOR
        3'b101: result = ~A;           // NOT 
        3'b110: result = A;
        default: result = 4'b0000;
    endcase
end

endmodule
