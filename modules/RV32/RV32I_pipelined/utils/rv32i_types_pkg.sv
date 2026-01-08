package rv32i_types_pkg;

localparam DATA_WIDTH = 32;

// Execute
typedef enum logic [1:0]
{
    MUX_F_A_RS1_DATA_D,
    MUX_F_A_ALU_RESULT_M,
    MUX_F_A_ALU_RESULT_W,
    MUX_F_A_NONE
} mux_forward_A_enum;

typedef enum logic [1:0]
{
    MUX_F_B_RS2_DATA_D,
    MUX_F_B_ALU_RESULT_M,
    MUX_F_B_ALU_RESULT_W,
    MUX_F_B_NONE
} mux_forward_B_enum;

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


  typedef struct packed
  {
    logic [DATA_WIDTH-1:0] instruction_F;
    logic [DATA_WIDTH-1:0] PC_F;
    logic [DATA_WIDTH-1:0] PC_plus_4_F;
  } F_D_bus_t;

  typedef struct packed
  {
    // Debug
        logic [31:0] instruction_D;

    // Control output signals
        // [Jumping]
            logic jump;
            logic i_jump;
            logic branch;
        // [EXECUTE]
            cond_code_enum cond_code;
            mux_ALU_operand_A_enum mux_ALU_operand_A_select;
            mux_ALU_operand_B_enum mux_ALU_operand_B_select;
            ALU_op_enum ALU_op;
        // [MEMORY]
            logic memory_transaction;
            logic mem_write;
            width_type_enum width_type;
        // [WRITEBACK]
            logic reg_write;
            mux_writeback_enum mux_writeback_select;
        // Register addresses
            logic [4:0] rs1_addr;
            logic [4:0] rs2_addr;
            logic [4:0] rd_addr;

    // Data signals
        logic [31:0] rs1_data_D;
        logic [31:0] rs2_data_D;
        logic [31:0] immediate_D;
  } D_E_bus_t;


endpackage