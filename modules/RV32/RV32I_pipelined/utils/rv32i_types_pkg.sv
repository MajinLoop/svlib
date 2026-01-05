package rv32i_types_pkg;

// --- Mux selects / control enums ---


typedef enum logic
{
    OPERAND_1   = 1'd0,
    PC          = 1'd1
} mux_ALU_operand_A_options_t;

typedef enum logic
{
    OPERAND_2   = 1'd0,
    IMMEDIATE   = 1'd1
} mux_ALU_operand_B_options_t;

typedef enum logic [1:0]
{
    ALU         = 2'd0,
    MEMORY      = 2'd1,
    PC_PLUS_4   = 2'd2,
    NONE        = 2'd3
} mux_writeback_options_t;

typedef enum logic [3:0]
{
    ADD,
    SUB,
    XOR,
    OR,
    AND,
    SLL,
    SRL,
    SRA,
    SLT,
    SLTU,
    A,
    B,
    NONE
} ALU_op_options_t;



endpackage