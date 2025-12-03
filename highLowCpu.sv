import highLowCpuPkg::*;

module highLowCpu (
    input logic clk,
    input logic reset,
    input logic high_i,
    input logic low_i,
    input instr_t instr,
    output logic high_o,
    output logic low_o
);

// Registers.

// Constant zero register.
value_label_t reg_zero;
assign reg_zero = '{value: 1'b0, label: 1'b0};

// High input register.  Value tied to input, labeled high.
value_label_t reg_input_high;
assign reg_input_high = '{value: high_i, label: 1'b1};

// Low input register.  Value tied to input, labeled low.
value_label_t reg_input_low;
assign reg_input_low = '{value: low_i, label: 1'b0};

// Output registers.
value_label_t reg_output_high;
value_label_t reg_output_low;

// General purpose registers.
value_label_t reg_a;
value_label_t reg_b;
value_label_t reg_c;

// Assign outputs.
assign high_o = reg_output_high.value;
assign low_o  = reg_output_low.label ? 1'b0 : reg_output_low.value;   // If reg_output_low is labeled high, output 0 to prevent leak.

// Get a register by name.
function automatic value_label_t get_register(reg_t r);
  case (r)
    ZERO:        return reg_zero;
    INPUT_HIGH:  return reg_input_high;
    INPUT_LOW:   return reg_input_low;
    OUTPUT_HIGH: return reg_output_high;
    OUTPUT_LOW:  return reg_output_low;
    REG_A:       return reg_a;
    REG_B:       return reg_b;
    REG_C:       return reg_c;
  endcase
endfunction

// Source operands.
value_label_t src1, src2;
assign src1 = get_register(instr.src1);
assign src2 = get_register(instr.src2);

// Function to compute result.
function automatic value_label_t compute_result(instr_t instr);
  value_label_t result;
  case (instr.opcode)
    COPY: begin
      result = src1;
    end
    NOT: begin
      result.value = ~src1.value;
      result.label = src1.label;
    end
    AND: begin
      result.value = src1.value & src2.value;
      result.label = src1.label | src2.label; // High if either is high.
    end
    OR: begin
      result.value = src1.value | src2.value;
      result.label = src1.label | src2.label; // High if either is high.
    end
    CLASSIFY: begin
      result.value = src1.value;
      result.label = 1'b1; // Classified to high.
    end
    LABEL_OF: begin
      result.value = src1.label;
      result.label = 1'b0; // Label is always low.
    end
    default: begin
      result = reg_zero;  // Default to zero.
    end
  endcase
  return result;
endfunction

// Result.
value_label_t result;
assign result = compute_result(instr);

// Check if instruction writes to a dst register.
function automatic logic instr_writes_to_reg(instr_t instr);
  case (instr.opcode)
    COPY, NOT, AND, OR, CLASSIFY, LABEL_OF: return 1'b1;
    default: return 1'b0;
  endcase
endfunction

// Skip logic for SKIP_NEXT instruction.
logic skip;

// Update registers.
always_ff @(posedge clk) begin
  if (reset) begin
    reg_output_high <= reg_zero;
    reg_output_low  <= reg_zero;
    reg_a           <= reg_zero;
    reg_b           <= reg_zero;
    reg_c           <= reg_zero;
  end else begin
    if (!skip && instr_writes_to_reg(instr)) begin
      case (instr.dst)
        OUTPUT_HIGH: reg_output_high <= result;
        OUTPUT_LOW:  reg_output_low  <= result;
        REG_A:       reg_a           <= result;
        REG_B:       reg_b           <= result;
        REG_C:       reg_c           <= result;
      endcase
    end
  end
end

// Update skip flag.
always_ff @(posedge clk) begin
  if (reset) begin
    skip <= 1'b0;
  end else begin
    if (!skip && instr.opcode == SKIP_NEXT) begin
      skip <= 1'b0;
      //skip <= src1.value; // Skip next if src1 is true.
    end else begin
      skip <= 1'b0;
    end
  end   
end

/*

Implicit flows:

  if (secret)
    public = 1;
  else
    public = 0;

  SKIP_NEXT INPUT_HIGH
  NOT ZERO OUTPUT_LOW
  COPY ZERO OUTPUT_LOW

*/


endmodule