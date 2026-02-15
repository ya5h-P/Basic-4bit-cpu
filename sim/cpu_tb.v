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

// Clock generation - 10ns period (100MHz)
always begin
    #5 clk = ~clk;
end

// Test sequence
initial begin
    // Initialize
    clk = 0;
    reset = 1;
    
    // Display header
    $display("========================================");
    $display("  Enhanced 4-bit CPU Simulation");
    $display("  Features: LDI, LDR, STR, CALL, RET");
    $display("========================================\n");
    
    // Hold reset for 2 clock cycles
    #20;
    reset = 0;
    $display("Time=%0t: Reset released\n", $time);
    
    // Let the program run
    #500;  // Run for 500ns
    
    // Display final state
    $display("\n========================================");
    $display("  Final CPU State");
    $display("========================================");
    $display("Registers:");
    $display("  R0 = %b (%d)", CPU.REG_BANK.regs[0], CPU.REG_BANK.regs[0]);
    $display("  R1 = %b (%d)", CPU.REG_BANK.regs[1], CPU.REG_BANK.regs[1]);
    $display("  R2 = %b (%d)", CPU.REG_BANK.regs[2], CPU.REG_BANK.regs[2]);
    $display("  R3 = %b (%d)", CPU.REG_BANK.regs[3], CPU.REG_BANK.regs[3]);
    
    $display("\nData Memory (first 10 locations):");
    $display("  Mem[0] = %d", CPU.DMEM.mem[0]);
    $display("  Mem[1] = %d", CPU.DMEM.mem[1]);
    $display("  Mem[2] = %d", CPU.DMEM.mem[2]);
    $display("  Mem[3] = %d", CPU.DMEM.mem[3]);
    $display("  Mem[4] = %d", CPU.DMEM.mem[4]);
    $display("  Mem[5] = %d", CPU.DMEM.mem[5]);
    
    $display("\nStack Info:");
    $display("  Stack Pointer = %d", CPU.STACK.sp);
    $display("  Overflow = %b, Underflow = %b", 
             CPU.stack_overflow, CPU.stack_underflow);
    
    $display("\nProgram Counter:");
    $display("  Final PC = %d", CPU.pc);
    
    $display("\n========================================");
    $display("  Simulation Complete");
    $display("========================================\n");
    
    $finish;
end

// Monitor key signals during execution
always @(posedge clk) begin
    if (!reset && !CPU.halt) begin
        $display("T=%0t | PC=%3d | Inst=%b | Op=%b | D=R%d | S=R%d | ALU=%d | R0=%d R1=%d R2=%d R3=%d", 
                 $time, 
                 CPU.pc, 
                 CPU.instruction,
                 CPU.alu_op,
                 CPU.dest_reg,
                 CPU.source_reg,
                 CPU.alu_result,
                 CPU.REG_BANK.regs[0],
                 CPU.REG_BANK.regs[1],
                 CPU.REG_BANK.regs[2],
                 CPU.REG_BANK.regs[3]);
    end
end

// Monitor special events
always @(posedge clk) begin
    if (CPU.push_stack)
        $display(">>> CALL: Pushing PC+2=%d to stack", CPU.pc + 2);
    
    if (CPU.pop_stack)
        $display(">>> RET: Popping address=%d from stack", CPU.stack_data_out);
    
    if (CPU.mem_we)
        $display(">>> STR: Writing R%d=%d to Mem[%d]", 
                 CPU.source_reg, CPU.reg_data_a, CPU.mem_addr);
    
    if (CPU.mem_to_reg)
        $display(">>> LDR: Loading Mem[%d]=%d to R%d", 
                 CPU.mem_addr, CPU.mem_read_data, CPU.dest_reg);
    
    if (CPU.halt)
        $display(">>> HALT: CPU stopped at PC=%d", CPU.pc);
end

endmodule