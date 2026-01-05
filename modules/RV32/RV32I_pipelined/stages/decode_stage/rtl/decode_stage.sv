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
    output logic [2:0] cond_code,
    output rv32i_types_pkg::mux_ALU_operand_B_options_t mux_ALU_operand_B_select_D,
    output rv32i_types_pkg::mux_ALU_operand_A_options_t mux_ALU_operand_A_select_D,
    output rv32i_types_pkg::ALU_op_options_t ALU_op_D,
        // [MEMORY]
    output logic memory_transaction_D,
    output logic mem_write_D,
    output logic [2:0] width_type_D,
        // [WRITEBACK]
    output logic reg_write_D,
    output rv32i_types_pkg::mux_writeback_options_t mux_writeback_select_D,
        // Register addresses
    output logic [4:0] rs1_D,
    output logic [4:0] rs2_D,
    output logic [4:0] rd_D,

    // Data output signals
        // Regfile
    output logic [DATA_WIDTH-1:0]    rf_Operand_1_D,
    output logic [DATA_WIDTH-1:0]    rf_Operand_2_D,
        // Sign-extended immediate
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
        101 -> (not used) -> immediate = '0
        110 -> (not used) -> immediate = '0
        111 -> (not used) -> immediate = '0
    
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
            PC_to_ALU : Selects between operand_1 from rf or PC to set ALU input A
                0 -> operand 1 from rf
                1 -> PC

            ALU_source : Selects between operand_2 from rf or immediate for ALU input B
                0 -> operand_2 from rf
                1 -> Immediate

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


    // Instruction fields
    logic [6:0] opcode;
    logic [4:0] rd;
    logic [2:0] funct3;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [6:0] funct7;

    assign opcode = instruction[6:0];
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign funct7 = instruction[31:25];

    // Instruction types
    localparam logic [6:0]
        R       = 7'b0110011,
        I_ALU   = 7'b0010011,
        I_LOAD  = 7'b0000011,
        S       = 7'b0100011,
        B       = 7'b1100011,
        J       = 7'b1101111,
        I_JUMP  = 7'b1100111,
        U       = 7'b0110111,
        U_PC    = 7'b0010111;


    typedef enum logic [2:0]
    {
        IMM_I = 3'd0,
        IMM_S = 3'd1,
        IMM_B = 3'd2,
        IMM_U = 3'd3,
        IMM_J = 3'd4,
        IMM_NONE = 3'd7
    } imm_type_t;
    imm_type_t immediate_type;

    // Main decoder (for direct opcode-dependient control signals)
    always_comb begin
        immediate_type = IMM_NONE;
        unique case (opcode) // Instruction type
            R: begin
                // [Immediate]
                // N/A
                // [Jumping]
                jump_D = 0;
                i_jump_D = 0;
                branch_D = 0;
                // [ALU]
                mux_ALU_operand_A_select_D = OPERAND_1;
                mux_ALU_operand_B_select_D = OPERAND_2;
                // [Memory]
                memory_transaction_D = 0;
                mem_write_D = 0;
                // [REGFILE]
                reg_write_D = 1;
            end
            I_ALU: begin
                // [Immediate]
                immediate_type = IMM_I;
                // [Jumping]
                jump_D = 0;
                i_jump_D = 0;
                branch_D = 0;
                // [ALU]
                mux_ALU_operand_A_select_D = OPERAND_1;
                mux_ALU_operand_B_select_D = IMMEDIATE;
                // [Memory]
                memory_transaction_D = 0;
                mem_write_D = 0;
                // [REGFILE]
                reg_write_D = 1;
            end
            I_LOAD: begin
                // [Immediate]
                immediate_type = IMM_I;
                // [Jumping]
                jump_D = 0;
                i_jump_D = 0;
                branch_D = 0;
                // [ALU]
                mux_ALU_operand_A_select_D = OPERAND_1;
                mux_ALU_operand_B_select_D = IMMEDIATE;
                // [Memory]
                memory_transaction_D = 1;
                mem_write_D = 0;
                // [REGFILE]
                reg_write_D = 1;
            end
            S: begin
                // [Immediate]
                immediate_type = IMM_S;
                // [Jumping]
                jump_D = 0;
                i_jump_D = 0;
                branch_D = 0;
                // [ALU]
                mux_ALU_operand_A_select_D = OPERAND_1;
                mux_ALU_operand_B_select_D = IMMEDIATE;
                // [Memory]
                memory_transaction_D = 1;
                mem_write_D = 1;
                // [REGFILE]
                reg_write_D = 0;
            end
            B: begin
                // [Immediate]
                immediate_type = IMM_B;
                // [Jumping]
                jump_D = 0;
                i_jump_D = 0;
                branch_D = 1;
                // [ALU]
                mux_ALU_operand_A_select_D = PC;
                mux_ALU_operand_B_select_D = IMMEDIATE;
                // [Memory]
                memory_transaction_D = 0;
                mem_write_D = 0;
                // [REGFILE]
                reg_write_D = 0;
            end
            J: begin
                // [Immediate]
                immediate_type = IMM_J;
                // [Jumping]
                jump_D = 1;
                i_jump_D = 0;
                branch_D = 0;
                // [ALU]
                mux_ALU_operand_A_select_D = PC;
                mux_ALU_operand_B_select_D = IMMEDIATE;
                // [Memory]
                memory_transaction_D = 0;
                mem_write_D = 0;
                // [REGFILE]
                reg_write_D = 1;
            end
            I_JUMP: begin
                // [Immediate]
                immediate_type = IMM_I;
                // [Jumping]
                jump_D = 0;
                i_jump_D = 1;
                branch_D = 0;
                // [ALU]
                mux_ALU_operand_A_select_D = OPERAND_1;
                mux_ALU_operand_B_select_D = IMMEDIATE;
                // [Memory]
                memory_transaction_D = 0;
                mem_write_D = 0;
                // [REGFILE]
                reg_write_D = 1;
            end
            U: begin
                // [Immediate]
                immediate_type = IMM_U;
                // [Jumping]
                jump_D = 0;
                i_jump_D = 0;
                branch_D = 0;
                // [ALU]
                mux_ALU_operand_A_select_D = OPERAND_1;
                mux_ALU_operand_B_select_D = IMMEDIATE;
                // [Memory]
                memory_transaction_D = 0;
                mem_write_D = 0;
                // [REGFILE]
                reg_write_D = 1;
            end
            U_PC: begin
                // [Immediate]
                immediate_type = IMM_U;
                // [Jumping]
                jump_D = 0;
                i_jump_D = 0;
                branch_D = 0;
                // [ALU]
                mux_ALU_operand_A_select_D = PC;
                mux_ALU_operand_B_select_D = IMMEDIATE;
                // [Memory]
                memory_transaction_D = 0;
                mem_write_D = 0;
                // [REGFILE]
                reg_write_D = 1;
            end
            default:                begin /* illegal */ end
        endcase
    end

    // Alu_op decoder
    unique case ({opcode, funct3, funct7})
        // For R-type instructions
        {R, 3'h0, 7'h0}:    ALU_op_D = ADD;
        {R, 3'h0, 7'h20}:   ALU_op_D = SUB;
        {R, 3'h4, 7'h0}:    ALU_op_D = XOR;
        {R, 3'h6, 7'h0}:    ALU_op_D = OR;
        {R, 3'h7, 7'h0}:    ALU_op_D = AND;
        {R, 3'h1, 7'h0}:    ALU_op_D = SLL;
        {R, 3'h5, 7'h0}:    ALU_op_D = SRL;
        {R, 3'h5, 7'h20}:   ALU_op_D = SRA;
        {R, 3'h2, 7'h0}:    ALU_op_D = SLT;
        {R, 3'h3, 7'h0}:    ALU_op_D = SLTU;
        // For I-type instructions
        {R, 3'h0, }:    ALU_op_D = ADD;
        {R, 3'h0, 7'h20}:   ALU_op_D = SUB;
        {R, 3'h4, 7'h0}:    ALU_op_D = XOR;
        {R, 3'h6, 7'h0}:    ALU_op_D = OR;
        {R, 3'h7, 7'h0}:    ALU_op_D = AND;
        {R, 3'h1, 7'h0}:    ALU_op_D = SLL;
        {R, 3'h5, 7'h0}:    ALU_op_D = SRL;
        {R, 3'h5, 7'h20}:   ALU_op_D = SRA;
        {R, 3'h2, 7'h0}:    ALU_op_D = SLT;
        {R, 3'h3, 7'h0}:    ALU_op_D = SLTU;

        default: ;
    endcase




    // Immediate builder
    // logic [DATA_WIDTH-1:0] immediate;
    // always_comb begin
    //     unique case ()
    // end


    // Register file instance
    // regfile
    // #(
    //     .DATA_WIDTH(DATA_WIDTH),
    //     .ADDR_WIDTH(5)
    // )
    // rf
    // (
    //     .clk(clk),
    //     .async_rst_n(async_rst_n),
    //     .write_enable(rf_write_enable_W),
    //     .write_addr(rf_write_addr_W),
    //     .write_data(rf_write_data_W),
    //     .operand_1_addr(rs1_D),
    //     .operand_2_addr(rs2_D),

    //     .operand_1_data(rf_Operand_1_D),
    //     .operand_2_data(rf_Operand_2_D)
    // );




    // Predicted PC address
    // assign predicted_PC_addr_D = PC_D + immediate_D;

endmodule