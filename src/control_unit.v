`timescale 1ns / 1ps
module control_unit (
    input clk,
    input reset,
    input [7:0] instruction,      // Current instruction
    input [7:0] next_byte,        // Next byte (for multi-byte instructions)
    input zero_flag,              // From ALU
    input [3:0] reg_data_src,     // Source register value (for JZ checking)
    output reg [3:0] alu_op,
    output reg [1:0] dest_reg,
    output reg [1:0] source_reg,
    output reg [3:0] immediate,   // Immediate value for ALU
    output reg reg_we,            // Register write enable
    output reg mem_we,            // Data memory write enable
    output reg [7:0] mem_addr,    // Memory address for LDR/STR
    output reg mem_to_reg,        // 1=write memory data to reg, 0=write ALU result
    output reg jump_enable,       // Enable jump
    output reg [7:0] jump_addr,   // Jump target address
    output reg pc_inc_2,          // Increment PC by 2 (multi-byte instruction)
    output reg push_stack,        // Push to stack (CALL)
    output reg pop_stack,         // Pop from stack (RET)
    output reg halt,              // Halt CPU
    output reg use_immediate      // Tell ALU to use immediate input
);

reg [1:0] state;  // State machine: 00=normal, 01=wait for multi-byte
wire [3:0] opcode;
wire is_multi_byte;

assign opcode = instruction[7:4];
assign is_multi_byte = (opcode >= 4'b1001 && opcode <= 4'b1110);  // LDI, LDR, STR, JMP, JZ, CALL

// State machine
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= 2'b00;
    end else begin
        case (state)
            2'b00: begin  // Normal execution
                if (is_multi_byte)
                    state <= 2'b01;  // Wait one cycle for next byte
                else
                    state <= 2'b00;
            end
            2'b01: begin  // Multi-byte instruction, execute
                state <= 2'b00;
            end
        endcase
    end
end

// Control signal generation
always @(*) begin
    // Defaults
    alu_op = opcode;
    dest_reg = instruction[3:2];
    source_reg = instruction[1:0];
    immediate = 4'b0000;
    reg_we = 1'b1;           // Most instructions write to register
    mem_we = 1'b0;           // Most don't write to memory
    mem_addr = 8'b0;
    mem_to_reg = 1'b0;       // Most use ALU result
    jump_enable = 1'b0;
    jump_addr = 8'b0;
    pc_inc_2 = 1'b0;
    push_stack = 1'b0;
    pop_stack = 1'b0;
    halt = 1'b0;
    use_immediate = 1'b0;
    
    case (opcode)
        // ===== Single-byte instructions =====
        
        4'b0000: begin  // ADD
            // Defaults work fine
        end
        
        4'b0001: begin  // SUB
            // Defaults work fine
        end
        
        4'b0010: begin  // INC
            // Defaults work fine
        end
        
        4'b0011: begin  // DEC
            // Defaults work fine
        end
        
        4'b0100: begin  // AND
            // Defaults work fine
        end
        
        4'b0101: begin  // OR
            // Defaults work fine
        end
        
        4'b0110: begin  // XOR
            // Defaults work fine
        end
        
        4'b0111: begin  // NOT
            // Defaults work fine
        end
        
        4'b1000: begin  // MOV
            // Defaults work fine
        end
        
        // ===== Multi-byte instructions =====
        
        4'b1001: begin  // LDI R[dest], immediate
            pc_inc_2 = 1'b1;
            immediate = next_byte[3:0];  // Use lower 4 bits of next byte
            use_immediate = 1'b1;
        end
        
        4'b1010: begin  // LDR R[dest], [address]
            pc_inc_2 = 1'b1;
            mem_addr = next_byte;
            mem_to_reg = 1'b1;  // Write memory data to register, not ALU result
        end
        
        4'b1011: begin  // STR R[source], [address]
            pc_inc_2 = 1'b1;
            mem_addr = next_byte;
            mem_we = 1'b1;      // Write to memory
            reg_we = 1'b0;      // Don't write to register
        end
        
        4'b1100: begin  // JMP address
            pc_inc_2 = 1'b1;
            jump_enable = 1'b1;
            jump_addr = next_byte;
            reg_we = 1'b0;
        end
        
        4'b1101: begin  // JZ R[source], address (jump if R[source] == 0)
            pc_inc_2 = 1'b1;
            reg_we = 1'b0;
            if (reg_data_src == 4'b0000) begin  // Check if source register is zero
                jump_enable = 1'b1;
                jump_addr = next_byte;
            end
        end
        
        4'b1110: begin  // CALL address
            pc_inc_2 = 1'b1;
            push_stack = 1'b1;
            jump_enable = 1'b1;
            jump_addr = next_byte;
            reg_we = 1'b0;
        end
        
        4'b1111: begin  // RET or HALT
            if (instruction[3:0] == 4'b0000) begin  // RET (1111_00_00)
                pop_stack = 1'b1;
                jump_enable = 1'b1;
                // jump_addr comes from stack output
                reg_we = 1'b0;
            end else begin  // HALT (1111_xx_xx, anything else)
                halt = 1'b1;
                reg_we = 1'b0;
            end
        end
        
        default: begin
            // Unknown instruction - treat as NOP
            reg_we = 1'b0;
        end
    endcase
end

endmodule