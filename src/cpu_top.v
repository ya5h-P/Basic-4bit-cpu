`timescale 1ns / 1ps
module cpu_top (
    input clk,
    input reset
);

// Internal wires
wire [7:0] pc;                    // Program Counter output
wire [7:0] instruction;           // Current instruction
wire [2:0] alu_op;                // ALU operation
wire [1:0] dest_reg;              // Destination register address
wire [1:0] source_reg;            // Source register address
wire reg_we;                      // Register write enable
wire [3:0] reg_data_a;            // Data from source register
wire [3:0] reg_data_b;            // Data from dest register
wire [3:0] alu_result;            // ALU output

// Program Counter
program_counter PC (
    .clk(clk),
    .reset(reset),
    .pc(pc)
);

// Instruction Memory
instruction_memory IMEM (
    .address(pc),
    .instruction(instruction)
);

// Control Unit
control_unit CU (
    .instruction(instruction),
    .alu_op(alu_op),
    .dest_reg(dest_reg),
    .source_reg(source_reg),
    .reg_we(reg_we)
);

// Register Bank
registers REG_BANK (
    .clk(clk),
    .reset(reset),
    .we(reg_we),
    .w_addr(dest_reg),           // write to destination register
    .w_data(alu_result),         // write ALU result
    .r_addr_a(source_reg),       // read source register
    .r_addr_b(dest_reg),         // read destination register
    .r_data_a(reg_data_a),       // source register output
    .r_data_b(reg_data_b)        // dest register output
);

// ALU
ALU4 ALU (
    .A(reg_data_b),              // A = destination register (for operations like R0 = R0 + R1)
    .B(reg_data_a),              // B = source register
    .ALUop(alu_op),
    .result(alu_result)
);

endmodule