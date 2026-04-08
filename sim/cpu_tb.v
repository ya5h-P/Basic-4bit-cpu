`timescale 1ns / 1ps
module cpu_tb;

// ============================================================
//  Signals
// ============================================================
reg clk;
reg reset;

// Instantiate the CPU
cpu_top CPU (
    .clk(clk),
    .reset(reset)
);

// ============================================================
//  Clock - 10 ns period (100 MHz)
// ============================================================
always begin
    #5 clk = ~clk;
end

// ============================================================
//  Mnemonic decoder (for readable cycle trace)
// ============================================================
reg [8*5-1:0] mnemonic;   // up to 5 characters

always @(*) begin
    case (CPU.alu_op)
        4'b0000: mnemonic = " ADD ";
        4'b0001: mnemonic = " SUB ";
        4'b0010: mnemonic = " INC ";
        4'b0011: mnemonic = " DEC ";
        4'b0100: mnemonic = " AND ";
        4'b0101: mnemonic = "  OR ";
        4'b0110: mnemonic = " XOR ";
        4'b0111: mnemonic = " NOT ";
        4'b1000: mnemonic = " MOV ";
        4'b1001: mnemonic = " LDI ";
        4'b1010: mnemonic = " LDR ";
        4'b1011: mnemonic = " STR ";
        4'b1100: mnemonic = " JMP ";
        4'b1101: mnemonic = "  JZ ";
        4'b1110: mnemonic = "CALL ";
        4'b1111: mnemonic = " RET ";
        default: mnemonic = " ??? ";
    endcase
end

// ============================================================
//  Main test sequence
// ============================================================
initial begin
    clk   = 0;
    reset = 1;

    $display("");
    $display("╔══════════════════════════════════════════════╗");
    $display("║         4-bit CPU - Behavioural Sim          ║");
    $display("║   Instructions: LDI LDR STR JMP JZ CALL RET ║");
    $display("╚══════════════════════════════════════════════╝");
    $display("");

    // Hold reset for 2 clock cycles
    #20;
    reset = 0;
    $display("[  RESET ] Released at t=%0t ns", $time);
    $display("");

    // Column headers for the cycle trace
    $display("%-8s  %-4s  %-5s  %-12s  %-14s  %s",
             "Time(ns)", "PC", "Instr", "Registers", "ALU", "Notes");
    $display("%-8s  %-4s  %-5s  %-12s  %-14s  %s",
             "--------", "----", "-----", "R0 R1 R2 R3", "Op   Result", "-----");

    // Run the program
    #500;

    // -------------------------------------------------------
    //  Final state dump
    // -------------------------------------------------------
    $display("");
    $display("╔══════════════════════════════════════════════╗");
    $display("║                 Final CPU State              ║");
    $display("╚══════════════════════════════════════════════╝");

    $display("");
    $display("  Registers:");
    $display("    R0 = %0d  (0b%04b)", CPU.REG_BANK.regs[0], CPU.REG_BANK.regs[0]);
    $display("    R1 = %0d  (0b%04b)", CPU.REG_BANK.regs[1], CPU.REG_BANK.regs[1]);
    $display("    R2 = %0d  (0b%04b)", CPU.REG_BANK.regs[2], CPU.REG_BANK.regs[2]);
    $display("    R3 = %0d  (0b%04b)", CPU.REG_BANK.regs[3], CPU.REG_BANK.regs[3]);

    $display("");
    $display("  Data Memory (first 6 locations):");
    $display("    ┌──────┬───────┐");
    $display("    │ Addr │ Value │");
    $display("    ├──────┼───────┤");
    $display("    │  [0] │  %2d   │", CPU.DMEM.mem[0]);
    $display("    │  [1] │  %2d   │", CPU.DMEM.mem[1]);
    $display("    │  [2] │  %2d   │", CPU.DMEM.mem[2]);
    $display("    │  [3] │  %2d   │", CPU.DMEM.mem[3]);
    $display("    │  [4] │  %2d   │", CPU.DMEM.mem[4]);
    $display("    │  [5] │  %2d   │", CPU.DMEM.mem[5]);
    $display("    └──────┴───────┘");

    $display("");
    $display("  Call Stack:");
    $display("    Stack pointer = %0d", CPU.STACK.sp);
    $display("    Overflow  = %0b", CPU.stack_overflow);
    $display("    Underflow = %0b", CPU.stack_underflow);

    $display("");
    $display("  Program Counter (final) = %0d", CPU.pc);

    $display("");
    $display("╔══════════════════════════════════════════════╗");
    $display("║              Simulation Complete             ║");
    $display("╚══════════════════════════════════════════════╝");
    $display("");

    $finish;
end

// ============================================================
//  Per-cycle trace  (one line per clock, human-readable)
// ============================================================
always @(posedge clk) begin
    if (!reset && !CPU.halt) begin
        $display("%7t ns  PC=%-3d  %s  R0=%-2d R1=%-2d R2=%-2d R3=%-2d  %-4s -> %-2d",
                 $time,
                 CPU.pc,
                 mnemonic,
                 CPU.REG_BANK.regs[0],
                 CPU.REG_BANK.regs[1],
                 CPU.REG_BANK.regs[2],
                 CPU.REG_BANK.regs[3],
                 mnemonic,
                 CPU.alu_result);
    end
end

// ============================================================
//  Event markers  (CALL, RET, STR, LDR, HALT)
// ============================================================
always @(posedge clk) begin
    if (CPU.push_stack)
        $display("  >> CALL  : pushed return address %0d onto stack", CPU.pc + 2);

    if (CPU.pop_stack)
        $display("  >> RET   : popped address %0d from stack", CPU.stack_data_out);

    if (CPU.mem_we)
        $display("  >> STR   : Mem[%0d] <- R%0d = %0d",
                 CPU.mem_addr, CPU.source_reg, CPU.reg_data_a);

    if (CPU.mem_to_reg)
        $display("  >> LDR   : R%0d <- Mem[%0d] = %0d",
                 CPU.dest_reg, CPU.mem_addr, CPU.mem_read_data);

    if (CPU.halt)
        $display("  >> HALT  : CPU stopped at PC=%0d", CPU.pc);
end

endmodule
