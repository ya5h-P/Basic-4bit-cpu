`timescale 1ns / 1ps
module cpu_tb;

// Testbench signals
reg clk;
reg reset;

// Instantiate the CPU
cpu_top CPU (
    .clk(clk),
    .reset(reset)
);

// Clock generation - toggles every 5ns (100MHz clock)
always begin
    #5 clk = ~clk;
end

// Test sequence
initial begin
    // Initialize signals
    clk = 0;
    reset = 1;
    
    // Display header
    $display("========================================");
    $display("Starting CPU Simulation");
    $display("========================================");
    
    // Hold reset for 2 clock cycles
    #10;
    reset = 0;
    $display("Reset released at time %0t", $time);
    
    // Run for several clock cycles to execute instructions
    #100;
    
    // Display register values
    $display("\n========================================");
    $display("Register Values After Execution:");
    $display("========================================");
    $display("R0 = %b (%d)", CPU.REG_BANK.regs[0], CPU.REG_BANK.regs[0]);
    $display("R1 = %b (%d)", CPU.REG_BANK.regs[1], CPU.REG_BANK.regs[1]);
    $display("R2 = %b (%d)", CPU.REG_BANK.regs[2], CPU.REG_BANK.regs[2]);
    $display("R3 = %b (%d)", CPU.REG_BANK.regs[3], CPU.REG_BANK.regs[3]);
    $display("========================================\n");
    
    // End simulation
    $finish;
end

// Monitor instruction execution (optional - helpful for debugging)
always @(posedge clk) begin
    if (!reset) begin
        $display("Time=%0t | PC=%d | Inst=%b | ALU_OP=%b | Dest=R%d | Src=R%d | Result=%d", 
                 $time, CPU.pc, CPU.instruction, CPU.alu_op, 
                 CPU.dest_reg, CPU.source_reg, CPU.alu_result);
    end
end

endmodule



/*## **Example Test Program (`program.mem`):**

Create this file in your project directory:
```
00000010
00001000
01010110
10111100
00000000
00000000
```

**What this program does:**
```
Instruction 0: 00000010 = 000_00_01_0 → ADD R0, R1  (R0 = R0 + R1)
Instruction 1: 00001000 = 000_01_00_0 → ADD R1, R0  (R1 = R1 + R0)
Instruction 2: 01010110 = 010_10_11_0 → AND R2, R3  (R2 = R2 & R3)
Instruction 3: 10111100 = 101_11_10_0 → NOT R3, R2  (R3 = ~R3)
Instruction 4: 00000000 = 000_00_00_0 → ADD R0, R0  (R0 = R0 + R0)
Instruction 5: 00000000 = ...*/