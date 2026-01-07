module decode_stage
#(
    parameter DATA_WIDTH = 32
)
(
    // --- Secuential input signals ---
    input  logic clk,
    input  logic async_rst_n,

    // --- Control input signals ---
    input logic [4:0] rf_write_addr_W,
    input logic rf_write_enable_W,

    // --- Data input signals ---
    input logic [DATA_WIDTH-1:0] instruction,
    // Regfile
    input logic [DATA_WIDTH-1:0] rf_write_data_W,
    // Prediction
    input logic [DATA_WIDTH-1:0] PC_D,


    // --- Control output signals ---
        // [Jumping]
    output logic jump_D,
    output logic i_jump_D,
    output logic branch_D,
        // [EXECUTE]
    output rv32i_types_pkg::cond_code_enum cond_code_D,
    output rv32i_types_pkg::mux_ALU_operand_A_enum mux_ALU_operand_A_select_D,
    output rv32i_types_pkg::mux_ALU_operand_B_enum mux_ALU_operand_B_select_D,
    output rv32i_types_pkg::ALU_op_enum ALU_op_D,
        // [MEMORY]
    output logic memory_transaction_D,
    output logic mem_write_D,
    output rv32i_types_pkg::width_type_enum width_type_D,
        // [WRITEBACK]
    output logic reg_write_D,
    output rv32i_types_pkg::mux_writeback_enum mux_writeback_select_D,
        // Register addresses
    output logic [4:0] rs1_addr_D,
    output logic [4:0] rs2_addr_D,
    output logic [4:0] rd_addr_D,

    // Data output signals
        // Regfile
    output logic [DATA_WIDTH-1:0]    rs1_data_D,
    output logic [DATA_WIDTH-1:0]    rs2_data_D,
        // MUX_ALU_OPERAND_B_IMMEDIATE
    output logic [DATA_WIDTH-1:0]    immediate_D,
        // Prediction
    output logic [DATA_WIDTH-1:0]    predicted_PC_addr_D
);
    import rv32i_types_pkg::*;

    // --- About control signals ---
    /*
    immediate_type : indicates the type of immediate to be built
        I-type -> immediate = { {20{instruction[31]}}, instruction[31:20] }
        S-type -> immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}
        B-type -> immediate = { {19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8] , 1'b0 }
        U-type -> immediate = { instruction[31:12], 12'b0 }
        J-type -> immediate = { {11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0 }
        Default -> immediate = '0
    
    [Jumping control signals]
        jump : Jump instruction
            0 -> No jump
            1 -> Jump
        
        i_jump : I-type jump instruction
            0 -> No jump
            1 -> Jump

        branch : Branch instruction
            0 -> No jump
            1 -> if branch condition
                0 -> Jump
                1 -> No jump

    [Execute control signals]
        operands muxes:
            PC_to_ALU : Selects between rs1_data from rf or PC to set ALU input A
                0 -> rs1_data from rf
                1 -> PC

            ALU_source : Selects between operand_2 from rf or MUX_ALU_OPERAND_B_IMMEDIATE for ALU input B
                0 -> operand_2 from rf
                1 -> MUX_ALU_OPERAND_B_IMMEDIATE

        ALU_op : ALU operation code
            0000 -> ADD
            0001 -> SUB
            0010 -> XOR
            0011 -> OR
            0100 -> AND
            0101 -> SLL
            0110 -> SRL
            0111 -> SRA
            1000 -> SLT
            1001 -> SLTU
            1010 -> Direct operand A
            1011 -> Direct operand B
            1110 -> (not used) -> ALU should return 0
            1111 -> (not used) -> ALU should return 0
   
    [Memory control signals]
        memory_transaction : If any Memory transaction
            0 -> No transaction
            1 -> Transaction

        mem_write_D : Controls whether to write to the external memory
            0 -> no write
            1 -> write memory

        width_type_D : Controls the data width for load and store instructions
            000 -> byte
            001 -> halfword
            010 -> word
            100 -> byte unsigned
            101 -> halfword unsigned
            110 -> (not used)
            111 -> (not used)
    
    [Writeback control signals]
        reg_write : controls whether to write to the register file
            0 -> No write rf
            1 -> Write rf

        mux_writeback_select_D : selects the source for the data to write back to the register file
    */

    // immediate types
    typedef enum logic [2:0]
    {
        IMM_I       = 3'd0,
        IMM_S       = 3'd1,
        IMM_B       = 3'd2,
        IMM_U       = 3'd3,
        IMM_J       = 3'd4,
        IMM_NONE    = 3'd7
    } immediate_enum;
    immediate_enum immediate_type;


    // Instruction fields
    typedef enum logic [6:0]
    {
        OPCODE_R       = 7'b0110011,
        OPCODE_I_ALU   = 7'b0010011,
        OPCODE_I_LOAD  = 7'b0000011,
        OPCODE_S       = 7'b0100011,
        OPCODE_B       = 7'b1100011,
        OPCODE_J       = 7'b1101111,
        OPCODE_I_JUMP  = 7'b1100111,
        OPCODE_U       = 7'b0110111,
        OPCODE_U_PC    = 7'b0010111
    } opcode_enum;
    opcode_enum opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = opcode_enum'(instruction[6:0]);
    assign rd_addr_D = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1_addr_D = instruction[19:15];
    assign rs2_addr_D = instruction[24:20];
    assign funct7 = instruction[31:25];

    // Main decoder (for direct opcode-dependient control signals)
    always_comb begin
        unique case (opcode) // Instruction type
            OPCODE_R: begin
                // [Immediate]
                immediate_type = IMM_NONE;
                // [Jumping]
                jump_D = 0;
                i_jump_D = 0;
                branch_D = 0;
                // [ALU]
                mux_ALU_operand_A_select_D = MUX_ALU_OPERAND_A_RS1;
                mux_ALU_operand_B_select_D = MUX_ALU_OPERAND_B_RS2;
                // [Memory]
                memory_transaction_D = 0;
                mem_write_D = 0;
                // [Regfile]
                reg_write_D = 1;
            end
            OPCODE_I_ALU: begin
                // [Immediate]
                immediate_type = IMM_I;
                // [Jumping]
                jump_D = 0;
                i_jump_D = 0;
                branch_D = 0;
                // [ALU]
                mux_ALU_operand_A_select_D = MUX_ALU_OPERAND_A_RS1;
                mux_ALU_operand_B_select_D = MUX_ALU_OPERAND_B_IMMEDIATE;
                // [Memory]
                memory_transaction_D = 0;
                mem_write_D = 0;
                // [Regfile]
                reg_write_D = 1;
            end
            OPCODE_I_LOAD: begin
                // [Immediate]
                immediate_type = IMM_I;
                // [Jumping]
                jump_D = 0;
                i_jump_D = 0;
                branch_D = 0;
                // [ALU]
                mux_ALU_operand_A_select_D = MUX_ALU_OPERAND_A_RS1;
                mux_ALU_operand_B_select_D = MUX_ALU_OPERAND_B_IMMEDIATE;
                // [Memory]
                memory_transaction_D = 1;
                mem_write_D = 0;
                // [Regfile]
                reg_write_D = 1;
            end
            OPCODE_S: begin
                // [Immediate]
                immediate_type = IMM_S;
                // [Jumping]
                jump_D = 0;
                i_jump_D = 0;
                branch_D = 0;
                // [ALU]
                mux_ALU_operand_A_select_D = MUX_ALU_OPERAND_A_RS1;
                mux_ALU_operand_B_select_D = MUX_ALU_OPERAND_B_IMMEDIATE;
                // [Memory]
                memory_transaction_D = 1;
                mem_write_D = 1;
                // [Regfile]
                reg_write_D = 0;
            end
            OPCODE_B: begin
                // [Immediate]
                immediate_type = IMM_B;
                // [Jumping]
                jump_D = 0;
                i_jump_D = 0;
                branch_D = 1;
                // [ALU]
                mux_ALU_operand_A_select_D = MUX_ALU_OPERAND_A_PC;
                mux_ALU_operand_B_select_D = MUX_ALU_OPERAND_B_IMMEDIATE;
                // [Memory]
                memory_transaction_D = 0;
                mem_write_D = 0;
                // [REGFILE]
                reg_write_D = 0;
            end
            OPCODE_J: begin
                // [Immediate]
                immediate_type = IMM_J;
                // [Jumping]
                jump_D = 1;
                i_jump_D = 0;
                branch_D = 0;
                // [ALU]
                mux_ALU_operand_A_select_D = MUX_ALU_OPERAND_A_PC;
                mux_ALU_operand_B_select_D = MUX_ALU_OPERAND_B_IMMEDIATE;
                // [Memory]
                memory_transaction_D = 0;
                mem_write_D = 0;
                // [REGFILE]
                reg_write_D = 1;
            end
            OPCODE_I_JUMP: begin
                // [Immediate]
                immediate_type = IMM_I;
                // [Jumping]
                jump_D = 0;
                i_jump_D = 1;
                branch_D = 0;
                // [ALU]
                mux_ALU_operand_A_select_D = MUX_ALU_OPERAND_A_RS1;
                mux_ALU_operand_B_select_D = MUX_ALU_OPERAND_B_IMMEDIATE;
                // [Memory]
                memory_transaction_D = 0;
                mem_write_D = 0;
                // [REGFILE]
                reg_write_D = 1;
            end
            OPCODE_U: begin
                // [Immediate]
                immediate_type = IMM_U;
                // [Jumping]
                jump_D = 0;
                i_jump_D = 0;
                branch_D = 0;
                // [ALU]
                mux_ALU_operand_A_select_D = MUX_ALU_OPERAND_A_RS1;
                mux_ALU_operand_B_select_D = MUX_ALU_OPERAND_B_IMMEDIATE;
                // [Memory]
                memory_transaction_D = 0;
                mem_write_D = 0;
                // [REGFILE]
                reg_write_D = 1;
            end
            OPCODE_U_PC: begin
                // [Immediate]
                immediate_type = IMM_U;
                // [Jumping]
                jump_D = 0;
                i_jump_D = 0;
                branch_D = 0;
                // [ALU]
                mux_ALU_operand_A_select_D = MUX_ALU_OPERAND_A_PC;
                mux_ALU_operand_B_select_D = MUX_ALU_OPERAND_B_IMMEDIATE;
                // [Memory]
                memory_transaction_D = 0;
                mem_write_D = 0;
                // [REGFILE]
                reg_write_D = 1;
            end
            default: begin
                // [Immediate]
                immediate_type = IMM_NONE;
                // [Jumping]
                jump_D = 0;
                i_jump_D = 0;
                branch_D = 0;
                // [ALU]
                mux_ALU_operand_A_select_D = MUX_ALU_OPERAND_A_RS1;
                mux_ALU_operand_B_select_D = MUX_ALU_OPERAND_B_RS2;
                // [Memory]
                memory_transaction_D = 0;
                mem_write_D = 0;
                // [REGFILE]
                reg_write_D = 0;
            end
        endcase
    end

    // ALU_op decoder
    always_comb begin
        unique case (opcode)
            OPCODE_R: begin
                unique case ({funct3, funct7})
                    {3'h0, 7'h0}:   ALU_op_D = ALU_ADD;
                    {3'h0, 7'h20}:  ALU_op_D = ALU_SUB;
                    {3'h4, 7'h0}:   ALU_op_D = ALU_XOR;
                    {3'h6, 7'h0}:   ALU_op_D = ALU_OR;
                    {3'h7, 7'h0}:   ALU_op_D = ALU_AND;
                    {3'h1, 7'h0}:   ALU_op_D = ALU_SLL;
                    {3'h5, 7'h0}:   ALU_op_D = ALU_SRL;
                    {3'h5, 7'h20}:  ALU_op_D = ALU_SRA;
                    {3'h2, 7'h0}:   ALU_op_D = ALU_SLT;
                    {3'h3, 7'h0}:   ALU_op_D = ALU_SLTU;
                    default:        ALU_op_D = ALU_ADD;
                endcase
            end
            OPCODE_I_ALU: begin
                ALU_op_D = ALU_ADD; // To handle ifs cases when do not match
                unique case (funct3)
                    3'h0:   ALU_op_D = ALU_ADD;
                    3'h4:   ALU_op_D = ALU_XOR;
                    3'h6:   ALU_op_D = ALU_OR;
                    3'h7:   ALU_op_D = ALU_AND;
                    3'h1: begin
                        if (funct7 == 7'h0)
                            ALU_op_D = ALU_SLL;
                    end
                    3'h5: begin
                        if (funct7 == 7'h0)
                            ALU_op_D = ALU_SRL;
                        else if (funct7 == 7'h20)
                            ALU_op_D = ALU_SRA;
                    end    
                    3'h2:       ALU_op_D = ALU_SLT;
                    3'h3:       ALU_op_D = ALU_SLTU;
                    default:    ALU_op_D = ALU_ADD;
                endcase
            end
            OPCODE_U: ALU_op_D = ALU_OPERAND_B;
            OPCODE_U_PC: ALU_op_D = ALU_ADD;
            default: ALU_op_D = ALU_ADD;
        endcase
    end

    // Cond Code decoder
    always_comb begin
        unique case ({opcode, funct3})
            {OPCODE_B, 3'h0}: cond_code_D = COND_EQUALS;
            {OPCODE_B, 3'h1}: cond_code_D = COND_NOT_EQUALS;
            {OPCODE_B, 3'h4}: cond_code_D = COND_LOWER;
            {OPCODE_B, 3'h5}: cond_code_D = COND_GREATER_OR_EQUAL;
            {OPCODE_B, 3'h6}: cond_code_D = COND_LOWER_UNSIGNED;
            {OPCODE_B, 3'h7}: cond_code_D = COND_GREATER_OR_EQUAL_UNSIGNED;
            default: cond_code_D          = COND_NONE;
        endcase
    end

    // Immediate builder
    always_comb begin
        unique case (immediate_type)
            IMM_I:      immediate_D = { {20{instruction[31]}}, instruction[31:20] };
            IMM_S:      immediate_D = {{20{instruction[31]}}, instruction[31:25], instruction[11:7] };
            IMM_B:      immediate_D = { {19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8] , 1'b0 };
            IMM_U:      immediate_D = { instruction[31:12], 12'b0 };
            IMM_J:      immediate_D = { {11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0 };
            IMM_NONE:   immediate_D = '0;
            default:    immediate_D = '0;
        endcase
    end

    // Mux writeback select decoder
    always_comb begin
        unique case (opcode)
            OPCODE_I_LOAD:      mux_writeback_select_D = MUX_WB_MEMORY;
            OPCODE_J:           mux_writeback_select_D = MUX_WB_PC_PLUS_4;
            OPCODE_I_JUMP: begin
                unique case (funct3)
                    3'h0:       mux_writeback_select_D = MUX_WB_PC_PLUS_4;
                    default:    mux_writeback_select_D = MUX_WB_ALU;
                endcase
            end
            default:            mux_writeback_select_D = MUX_WB_ALU;
        endcase
    end

    // Width Type decoder
    always_comb begin
        unique case ({opcode, funct3})
            {OPCODE_I_LOAD, 3'h0}:  width_type_D = WT_BYTE;
            {OPCODE_I_LOAD, 3'h1}:  width_type_D = WT_HALF_WORD;
            {OPCODE_I_LOAD, 3'h2}:  width_type_D = WT_WORD;
            {OPCODE_I_LOAD, 3'h4}:  width_type_D = WT_BYTE_UNSIGNED;
            {OPCODE_I_LOAD, 3'h5}:  width_type_D = WT_HALF_WORD_UNSIGNED;

            {OPCODE_S, 3'h0}:       width_type_D = WT_BYTE;
            {OPCODE_S, 3'h1}:       width_type_D = WT_HALF_WORD;
            {OPCODE_S, 3'h2}:       width_type_D = WT_WORD;

            default:                width_type_D = WT_WORD;
        endcase
    end

    // Register file instance
    regfile
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(5)
    )
    rf
    (
        .clk(clk),
        .async_rst_n(async_rst_n),
        .write_enable(rf_write_enable_W),
        .write_addr(rf_write_addr_W),
        .write_data(rf_write_data_W),
        .rs1_addr(rs1_addr_D),
        .rs2_addr(rs2_addr_D),

        .rs1_data(rs1_data_D),
        .rs2_data(rs2_data_D)
    );

    // Predicted PC address
    assign predicted_PC_addr_D = PC_D + immediate_D;

endmodule