package rv32i_types_pkg;

// --- Mux selects / control enums ---


// Execute
typedef enum logic
{
    MUX_ALU_OPERAND_A_RS1,
    MUX_ALU_OPERAND_A_PC
} mux_ALU_operand_A_enum;

typedef enum logic
{
    MUX_ALU_OPERAND_B_RS2,
    MUX_ALU_OPERAND_B_IMMEDIATE
} mux_ALU_operand_B_enum;

typedef enum logic [2:0]
{
    COND_EQUALS,
    COND_NOT_EQUALS,
    COND_LOWER,
    COND_GREATER_OR_EQUAL,
    COND_LOWER_UNSIGNED,
    COND_GREATER_OR_EQUAL_UNSIGNED,
    COND_NONE
} cond_code_enum;


typedef enum logic [3:0]
{
    ALU_ADD,
    ALU_SUB,
    ALU_XOR,
    ALU_OR,
    ALU_AND,
    ALU_SLL,
    ALU_SRL,
    ALU_SRA,
    ALU_SLT,
    ALU_SLTU,
    ALU_OPERAND_A,
    ALU_OPERAND_B,
    ALU_NONE
} ALU_op_enum;


// Memory
typedef enum logic [2:0]
{
    WT_BYTE,               // Less significant Byte
    WT_HALF_WORD,          // Fisrt half
    WT_WORD,               // 
    WT_BYTE_UNSIGNED,      // Less significant Byte
    WT_HALF_WORD_UNSIGNED  // Fisrt half
} width_type_enum;


// Writeback
typedef enum logic [1:0]
{
    MUX_WB_ALU,
    MUX_WB_MEMORY,
    MUX_WB_PC_PLUS_4,
    MUX_WB_NONE
} mux_writeback_enum;


endpackage