`timescale 1ns / 1ps
module cpu_top (
    input clk,
    input reset
);

// ========== Internal Wires ==========

// Program Counter
wire [7:0] pc;
wire halt;
wire jump_enable;
wire [7:0] jump_addr;
wire pc_inc_2;

// Instruction Memory
wire [7:0] instruction;
wire [7:0] next_byte;

// Control Unit
wire [3:0] alu_op;
wire [1:0] dest_reg;
wire [1:0] source_reg;
wire [3:0] immediate;
wire reg_we;
wire mem_we;
wire [7:0] mem_addr;
wire mem_to_reg;
wire push_stack;
wire pop_stack;
wire use_immediate;

// Register Bank
wire [3:0] reg_data_a;      // Source register output
wire [3:0] reg_data_b;      // Dest register output
wire [3:0] reg_write_data;  // Data to write to register

// ALU
wire [3:0] alu_result;
wire zero_flag;

// Data Memory
wire [3:0] mem_read_data;

// Stack
wire [7:0] stack_data_out;
wire stack_overflow;
wire stack_underflow;

// Jump address mux (for CALL/RET)
wire [7:0] final_jump_addr;

// ========== Module Instantiations ==========

// Program Counter
program_counter PC (
    .clk(clk),
    .reset(reset),
    .halt(halt),
    .jump_enable(jump_enable),
    .jump_addr(final_jump_addr),
    .pc_inc_2(pc_inc_2),
    .pc(pc)
);

// Instruction Memory
instruction_memory IMEM (
    .address(pc),
    .instruction(instruction),
    .next_byte(next_byte)
);

// Control Unit
control_unit CU (
    .clk(clk),
    .reset(reset),
    .instruction(instruction),
    .next_byte(next_byte),
    .zero_flag(zero_flag),
    .reg_data_src(reg_data_a),      // Source register value for JZ
    .alu_op(alu_op),
    .dest_reg(dest_reg),
    .source_reg(source_reg),
    .immediate(immediate),
    .reg_we(reg_we),
    .mem_we(mem_we),
    .mem_addr(mem_addr),
    .mem_to_reg(mem_to_reg),
    .jump_enable(jump_enable),
    .jump_addr(jump_addr),
    .pc_inc_2(pc_inc_2),
    .push_stack(push_stack),
    .pop_stack(pop_stack),
    .halt(halt),
    .use_immediate(use_immediate)
);

// Register Bank
registers REG_BANK (
    .clk(clk),
    .reset(reset),
    .we(reg_we),
    .w_addr(dest_reg),
    .w_data(reg_write_data),
    .r_addr_a(source_reg),          // Read source register
    .r_addr_b(dest_reg),            // Read dest register
    .r_data_a(reg_data_a),
    .r_data_b(reg_data_b)
);

// ALU
ALU4 ALU (
    .A(reg_data_b),                 // Dest register (for operations like ADD R0, R1)
    .B(reg_data_a),                 // Source register
    .ALUop(alu_op),
    .immediate(immediate),
    .result(alu_result),
    .zero(zero_flag)
);

// Data Memory
data_memory DMEM (
    .clk(clk),
    .we(mem_we),
    .address(mem_addr),
    .write_data(reg_data_a),        // Store: write source register to memory
    .read_data(mem_read_data)
);

// Stack
stack STACK (
    .clk(clk),
    .reset(reset),
    .push(push_stack),
    .pop(pop_stack),
    .data_in(pc + 2),               // Push return address (PC + 2)
    .data_out(stack_data_out),
    .overflow(stack_overflow),
    .underflow(stack_underflow)
);

// ========== Multiplexers / Combinational Logic ==========

// Select register write data: memory or ALU result
assign reg_write_data = mem_to_reg ? mem_read_data : alu_result;

// Select jump address: from control unit (JMP/JZ/CALL) or from stack (RET)
assign final_jump_addr = pop_stack ? stack_data_out : jump_addr;

endmodule