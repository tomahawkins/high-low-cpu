package highLowCpuPkg;

/*

A simple security CPU architecture.

- Two security levels: high and low.
- Inputs, outputs, registers are booleans.
- Internal data is labeled with security levels (0: low, 1: high).
- Instructions are streamed into the CPU.

                           +---------------------------+
                           |                           |
High Security Input   ---->|                           |----> High Security Output
                           |           CPU             |
Low Security Input    ---->|                           |----> Low Security Output
                           |                           |
                           +---------------------------+
                                         ^
                                         |
                                    Instructions

*/

// Value and label pairs for register data.
typedef struct packed {
  logic value;
  logic label;  // 0: low, 1: high.
} value_label_t;

// Machine registers.
typedef enum logic [2:0] {
  ZERO        = 3'b000,    // Constant zero register.
  INPUT_HIGH  = 3'b001,    // High security input.
  INPUT_LOW   = 3'b010,    // Low security input.
  OUTPUT_HIGH = 3'b011,    // High security output.
  OUTPUT_LOW  = 3'b100,    // Low security output.
  REG_A       = 3'b101,    // General purpose registers.
  REG_B       = 3'b110,
  REG_C       = 3'b111
} reg_t;

// Instruction opcodes.
typedef enum logic [2:0] {
  COPY      = 3'b000,  // COPY <src> <dst>
  NOT       = 3'b001,  // NOT <src> <dst>
  AND       = 3'b010,  // AND <src1> <src2> <dst>
  OR        = 3'b011,  // OR <src1> <src2> <dst>
  CLASSIFY  = 3'b100,  // CLASSIFY <src> <dst>  Classify data to high.
  LABEL_OF  = 3'b101,  // LABEL_OF <src> <dst>  Get the label of a value; labeled low.
  SKIP_NEXT = 3'b110   // SKIP_NEXT <src>       Skip next instruction if src is true.
} opcode_t;

// Instructions.
typedef struct packed {
  opcode_t opcode;
  reg_t src1;
  reg_t src2;  // Used only for binary operators.
  reg_t dst;   // Not used for SKIP_NEXT.
} instr_t;

endpackage