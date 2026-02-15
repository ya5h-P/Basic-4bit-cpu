# 4-bit CPU in Verilog

A 4-bit CPU that started simple and got carried away. Built as a learning project to understand computer architecture from the ground up.

> **Note:** This is Version 2 with significant enhancements. The original simpler version is preserved in the [`v1-basic`](../../tree/v1-basic) branch if you want to see where this journey started.

## About This Project

This began as my first Verilog project - a basic CPU with 7 instructions. Then I got ambitious (and AI got involved), and now it has data memory, a call stack, function calls, and 16 instructions. Most of the code was generated with significant help from AI (Claude), but the architectural decisions, debugging sessions, and "wait, why doesn't this work?" moments were all mine. Think of it as pair programming where one person is very fast at typing and occasionally hallucinates syntax.

**Purpose:** To understand how CPUs actually work by building one from scratch, even if "from scratch" means "with a very helpful AI assistant."

## Version History

- **V2 (Current)** - Enhanced CPU with 16 instructions, data memory, stack, function calls
- **V1 (Basic)** - Simple CPU with 7 instructions, registers only - see [`v1-basic`](../../tree/v1-basic) branch

## What's New in V2

The CPU graduated from "toy project" to "could almost be useful":

- **16 instructions** instead of 7
- **Multi-byte instructions** - some instructions are 2 bytes (like real CPUs!)
- **Data memory** - 256 x 4-bit RAM for actually storing things
- **Call stack** - 16 levels deep, for proper function calls
- **CALL/RET** - write actual subroutines
- **LDR/STR** - load and store data to/from memory
- **Jump instructions** - both unconditional and conditional

Basically, it went from "can do math" to "can run actual programs."

## Features

### Architecture
- **4-bit data path** - operates on 4-bit values (0-15)
- **4 general-purpose registers** (R0, R1, R2, R3)
- **8-bit instruction format** - some 1 byte, some 2 bytes
- **256-byte instruction memory** - room for 256 one-byte instructions
- **256 x 4-bit data memory** - actual RAM for storing data
- **16-level call stack** - for function calls and returns
- **8-bit program counter** - can address all 256 memory locations

### Instruction Set (16 operations)

#### Arithmetic (4 instructions)
| Opcode | Instruction | Operation | Description |
|--------|-------------|-----------|-------------|
| 0000 | ADD Rd, Rs | Rd = Rd + Rs | Addition |
| 0001 | SUB Rd, Rs | Rd = Rd - Rs | Subtraction |
| 0010 | INC Rd | Rd = Rd + 1 | Increment |
| 0011 | DEC Rd | Rd = Rd - 1 | Decrement |

#### Logic (4 instructions)
| Opcode | Instruction | Operation | Description |
|--------|-------------|-----------|-------------|
| 0100 | AND Rd, Rs | Rd = Rd & Rs | Bitwise AND |
| 0101 | OR Rd, Rs | Rd = Rd \| Rs | Bitwise OR |
| 0110 | XOR Rd, Rs | Rd = Rd ^ Rs | Bitwise XOR |
| 0111 | NOT Rd | Rd = ~Rd | Bitwise NOT |

#### Data Movement (4 instructions)
| Opcode | Instruction | Operation | Bytes | Description |
|--------|-------------|-----------|-------|-------------|
| 1000 | MOV Rd, Rs | Rd = Rs | 1 | Copy register |
| 1001 | LDI Rd, imm | Rd = immediate | 2 | Load immediate value |
| 1010 | LDR Rd, addr | Rd = Memory[addr] | 2 | Load from memory |
| 1011 | STR Rs, addr | Memory[addr] = Rs | 2 | Store to memory |

#### Control Flow (4 instructions)
| Opcode | Instruction | Operation | Bytes | Description |
|--------|-------------|-----------|-------|-------------|
| 1100 | JMP addr | PC = addr | 2 | Unconditional jump |
| 1101 | JZ Rs, addr | If Rs == 0, PC = addr | 2 | Jump if zero |
| 1110 | CALL addr | Push PC, jump to addr | 2 | Call subroutine |
| 1111 | RET / HALT | Pop PC or stop | 1 | Return or halt |

### Instruction Format

**Single-byte instructions:**
```
[7:4] - Opcode (4 bits)
[3:2] - Destination Register (2 bits)
[1:0] - Source Register (2 bits)
```

**Multi-byte instructions:**
```
Byte 1: [7:4] Opcode | [3:2] Register | [1:0] Modifier
Byte 2: [7:0] Immediate value or address
```

### Components

- **ALU** - Arithmetic Logic Unit with 16 operations
- **Register Bank** - 4 registers with dual-read, single-write ports
- **Program Counter** - Tracks current instruction, handles jumps
- **Instruction Memory** - 256 x 8-bit ROM for program storage
- **Data Memory** - 256 x 4-bit RAM for data storage
- **Stack** - 16-level deep stack for function calls
- **Control Unit** - State machine that decodes instructions and orchestrates everything

### Block Diagram
```
     ┌─────────────┐
     │  Program    │
     │  Counter    │
     └──────┬──────┘
            │
     ┌──────▼──────────┐
     │  Instruction    │
     │  Memory (ROM)   │
     └──────┬──────────┘
            │
     ┌──────▼──────────┐
     │  Control Unit   │
     │  (State Machine)│
     └──┬───┬───┬───┬──┘
        │   │   │   │
   ┌────▼───▼───▼───▼────┐
   │   Register Bank     │
   └────┬──────────┬──────┘
        │          │
     ┌──▼──────────▼──┐
     │      ALU       │
     └────────┬───────┘
              │
   ┌──────────▼────────┐    ┌──────────┐
   │  Data Memory      │    │  Stack   │
   │  (RAM)            │    │ (CALL/   │
   └───────────────────┘    │  RET)    │
                            └──────────┘
```

## Project Structure
```
Basic-4bit-cpu/
├── src/
│   ├── ALU4.v               # Arithmetic Logic Unit (updated to 4-bit opcode)
│   ├── registers.v          # Register bank
│   ├── program_counter.v    # Program counter (updated with jump support)
│   ├── instruction_memory.v # Instruction ROM (updated with lookahead)
│   ├── control_unit.v       # Control unit (major rewrite with state machine)
│   ├── cpu_top.v            # Top module (major rewrite, wires everything)
│   ├── data_memory.v        # NEW: Data RAM
│   └── stack.v              # NEW: Call stack
├── sim/
│   └── cpu_tb.v             # Testbench (updated)
├── programs/
│   └── program.mem          # Example binary program
├── README.md
├── LICENSE
└── .gitignore
```

## Getting Started

### Prerequisites
- Xilinx Vivado (tested on 2025.x) or any Verilog simulator
- Basic understanding of digital logic
- Patience for debugging timing issues

### Running the Simulation

1. **Create a new Vivado project** and add all `.v` files:
   - Design sources: All files in `src/`
   - Simulation sources: `cpu_tb.v`

2. **Create your program** in binary format (`program.mem`):
```
10010000
00000101
10010100
00000011
00000100
11111111
```

3. **Place `program.mem`** in your Vivado project root directory

4. **Run behavioral simulation**

5. **Check console output** for execution trace and final register/memory state

### File Placement: Important!

The CPU loads its program from `program.mem`. Place this file in your **Vivado project root directory**:
```
YourVivadoProject/
├── program.mem          ← HERE
├── YourProject.xpr
└── YourProject.srcs/
```

If you see `$readmemb: File 'program.mem' not found`, copy `program.mem` to the simulation directory shown in the error message.

### Writing Programs (The Hard Way)

Programs are pure binary, one byte per line. Multi-byte instructions take multiple lines.

**Example program:**
```
10010000    // LDI R0, (next byte)
00000101    //   Immediate value = 5
10010100    // LDI R1, (next byte)
00000011    //   Immediate value = 3
00000100    // ADD R1, R0 (R1 = R1 + R0 = 8)
10110001    // STR R1, (next byte)
00000000    //   Address = 0 (store to memory[0])
11111111    // HALT
```

**Instruction encoding:**
```
Single-byte: Opcode(4) | Dest(2) | Source(2)
Multi-byte:  Opcode(4) | Reg(2)  | XX(2)
             Data/Address(8)

Example: ADD R2, R1
  0000 (ADD) | 10 (R2) | 01 (R1)
  = 00000101

Example: LDI R0, 10
  1001 (LDI) | 00 (R0) | 00
  = 10010000
  00001010 (value 10 in binary)
```

Yes, writing programs this way is tedious. An assembler would be nice. (Hint: future improvement.)

## Example Programs

### Example 1: Simple Arithmetic
```
10010000 00000101    // LDI R0, 5
10010100 00000011    // LDI R1, 3
00000100             // ADD R1, R0  (R1 = 8)
11111111             // HALT
```

### Example 2: Memory Operations
```
10010000 00001010    // LDI R0, 10
10110000 00000000    // STR R0, 0     (Memory[0] = 10)
10100100 00000000    // LDR R1, 0     (R1 = Memory[0] = 10)
11111111             // HALT
```

### Example 3: Function Call
```
10010000 00000101    // LDI R0, 5
11100000 00001000    // CALL 8        (call subroutine at address 8)
11111111             // HALT

// Subroutine at address 8:
00110000             // DEC R0        (R0 = 4)
11110000             // RET           (return to caller)
```

## What I Learned

Building V2 taught me way more than V1:

- How real CPUs handle variable-length instructions
- Why state machines are necessary for complex control logic
- Stack implementation for subroutines (push/pop mechanics)
- The pain of timing bugs in hardware
- Why you need both instruction memory (ROM) and data memory (RAM)
- How function calls actually work at the hardware level
- That "just one more feature" always leads to a complete rewrite

Also learned: AI is great at generating Verilog but terrible at catching subtle timing bugs. Those are all you.

## Future Improvements

Things I'd like to add but haven't gotten around to yet:

- [ ] Assembler (writing binary by hand gets old fast)
- [ ] More conditional jumps (JC, JN, JNZ)
- [ ] Interrupts
- [ ] Hardware multiply/divide
- [ ] I/O ports (LEDs, buttons, UART)
- [ ] Pipeline stages (make it faster but way more complex)
- [ ] Synthesize to actual FPGA hardware
- [ ] Better debugging tools

## Notes

- This is a **learning project**, not production code. Please don't use this to control anything important.
- The design is loosely RISC-inspired - simple, uniform instruction format (mostly).
- V1 was single-cycle. V2 has a simple state machine for multi-byte instructions.
- All registers are general-purpose. No special register 0 behavior.
- The stack can overflow. There's a flag for it, but nothing handles it. Don't nest functions 17 levels deep.

## Acknowledgments

Built with heavy assistance from Claude AI (Anthropic). The architecture, design decisions, and debugging were collaborative, but most of the actual Verilog code was AI-generated. I made the decisions, asked the questions, and did the testing. The AI did the typing and occasionally suggested things I hadn't thought of.

Think of this as: "I designed a CPU and had a very fast, very knowledgeable assistant implement it while I learned what all the pieces do."

Inspired by classic educational CPU designs (MIPS, SAP-1, RISC-V) and the realization that the best way to understand something is to build it yourself (with help).

## License

MIT License - Feel free to learn from this, break it, fix it, or improve it!
