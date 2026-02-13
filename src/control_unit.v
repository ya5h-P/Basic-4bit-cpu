`timescale 1ns / 1ps
module control_unit (
    input [7:0] instruction,      // 8-bit instruction from memory
    output [2:0] alu_op,          // ALU operation
    output [1:0] dest_reg,        // destination register address
    output [1:0] source_reg,      // source register address
    output reg_we                 // register write enable
);

// Decode instruction fields
assign alu_op     = instruction[7:5];  // bits [7:5] = opcode
assign dest_reg   = instruction[4:3];  // bits [4:3] = destination
assign source_reg = instruction[2:1];  // bits [2:1] = source

// Generate write enable signal
// For this basic CPU, we write to register after every instruction
assign reg_we = 1'b1;

endmodule