/*

The general goal of non interference:  The high inputs should have no influence on the low outputs.

Let CPU_LOW(H, L, I) be the function mapping high inputs H, low inputs L, and instructions I to low outputs.

Forall H1, H2, L, I -> CPU_LOW(H1, L, I) == CPU_LOW(H2, L, I)

*/

import highLowCpuPkg::*;

module highLowCpuVerify (
    // Free variables for verification, i.e. H1, H2, L, and I.
    input logic clk,
    input logic high1_i,  // Different high input sequences.
    input logic high2_i,
    input logic low_i,    // Common low input sequence.
    input instr_t instr   // Common instruction stream.
);

// Reset generation.
logic reset;

initial
    reset = 1'b1;

always_ff @(posedge clk)
    reset <= 1'b0;

// Low outputs.  Ignore the high outputs.
logic low1_o;
logic low2_o;

// Two instances of the cpu, each with a different high input sequence.
highLowCpu cpu1 (
    .clk(clk),
    .reset(reset),
    .high_i(high1_i),
    .low_i(low_i),
    .instr(instr),
    .high_o(),
    .low_o(low1_o)
);

highLowCpu cpu2 (
    .clk(clk),
    .reset(reset),
    .high_i(high2_i),
    .low_i(low_i),
    .instr(instr),
    .high_o(),
    .low_o(low2_o)
);

// Logical implication.
function automatic logic imply(logic a, logic b);
    return !a || b;
endfunction

// Compare corresponding registers between the two CPUs.  If either is labeled low, the values and the labels must be equal.
function automatic logic if_low_then_equal(value_label_t r1, value_label_t r2);
    return imply(!r1.label || !r2.label, r1 == r2);
endfunction

// Lemma: All mutable registers that are labeled low must be equal between the two CPUs.
assert property (@(posedge clk)
  imply (!reset,
    if_low_then_equal(cpu1.reg_a, cpu2.reg_a) &&
    if_low_then_equal(cpu1.reg_b, cpu2.reg_b) &&
    if_low_then_equal(cpu1.reg_c, cpu2.reg_c) &&
    if_low_then_equal(cpu1.reg_output_high, cpu2.reg_output_high) &&
    if_low_then_equal(cpu1.reg_output_low, cpu2.reg_output_low)
  ));

// Theorem: Regardless of high input sequences between the two CPUs, low outputs are always the same.
assert property (@(posedge clk) imply(!reset, low1_o == low2_o));

endmodule