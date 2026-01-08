module execute_stage
#(
    parameter DATA_WIDTH = 32
)
(
    // Inputs
        // Control input signals
            // Jumping
            input logic jump_E,
            input logic i_jump_E,
            input logic branch_E,
            // ALU_op
            input rv32i_types_pkg::ALU_op_enum ALU_op_E,
            // Cond code
            input rv32i_types_pkg::cond_code_enum cond_code_E,
            // Forward muxes selects
            input rv32i_types_pkg::mux_forward_A_enum mux_forward_A_select_E,
            input rv32i_types_pkg::mux_forward_B_enum mux_forward_B_select_E,
            // ALU operand muxes selects
            input rv32i_types_pkg::mux_ALU_operand_A_enum mux_ALU_operand_A_select_E,
            input rv32i_types_pkg::mux_ALU_operand_B_enum mux_ALU_operand_B_select_E,        

        // Data input signals
            // Forward muxes data sources
            input logic [DATA_WIDTH-1:0] rs1_data_E,
            input logic [DATA_WIDTH-1:0] rs2_data_E,
            input logic [DATA_WIDTH-1:0] ALU_result_M,
            input logic [DATA_WIDTH-1:0] ALU_result_W,
            // ALU operand A data sources
            input logic [DATA_WIDTH-1:0] PC_E,
            // ALU operand B data sources
            input logic [DATA_WIDTH-1:0] immediate_E,

    // Outputs
        // Control output signals
        output logic [1:0] PC_source_E,
        output logic fk_go_back_E,
        // Data input signals
        output logic [DATA_WIDTH-1:0] ALU_result_E,
        output logic [DATA_WIDTH-1:0] mux_forward_B_out_E
);
    import rv32i_types_pkg::*;


    // Forward mux A
    logic [DATA_WIDTH-1:0] mux_forward_A_out_E;
    always_comb begin
        unique case (mux_forward_A_select_E)
            MUX_F_A_RS1_DATA_D:     mux_forward_A_out_E = rs1_data_E;
            MUX_F_A_ALU_RESULT_M:   mux_forward_A_out_E = ALU_result_M;
            MUX_F_A_ALU_RESULT_W:   mux_forward_A_out_E = ALU_result_W;
            MUX_F_A_NONE:           mux_forward_A_out_E = '0;
            default:                mux_forward_A_out_E = '0;
        endcase
    end

    // Forward mux B
    always_comb begin
        unique case (mux_forward_B_select_E)
            MUX_F_B_RS2_DATA_D:     mux_forward_B_out_E = rs2_data_E;
            MUX_F_B_ALU_RESULT_M:   mux_forward_B_out_E = ALU_result_M;
            MUX_F_B_ALU_RESULT_W:   mux_forward_B_out_E = ALU_result_W;
            MUX_F_B_NONE:           mux_forward_B_out_E = '0;
            default:                mux_forward_B_out_E = '0;
        endcase
    end

    // Mux ALU operand A
    logic [DATA_WIDTH-1:0] mux_ALU_operand_A_out;
    always_comb begin
        unique case (mux_ALU_operand_A_select_E)
            MUX_ALU_OPERAND_A_RS1:  mux_ALU_operand_A_out = mux_forward_A_out_E;
            MUX_ALU_OPERAND_A_PC:   mux_ALU_operand_A_out = PC_E;
            default:                mux_ALU_operand_A_out = mux_forward_A_out_E;
        endcase
    end

    // Mux ALU operand B
    logic [DATA_WIDTH-1:0] mux_ALU_operand_B_out;
    always_comb begin
        unique case (mux_ALU_operand_B_select_E)
            MUX_ALU_OPERAND_B_RS2:          mux_ALU_operand_B_out = mux_forward_B_out_E;
            MUX_ALU_OPERAND_B_IMMEDIATE:    mux_ALU_operand_B_out = immediate_E;
            default:                        mux_ALU_operand_B_out = mux_forward_B_out_E;
        endcase
    end

    // Comparison Unit
    logic cmp_taken;
    always_comb begin
        cmp_taken = 1'b0;
        unique case (cond_code_E)
            COND_EQUALS: begin
                if (mux_forward_A_out_E == mux_forward_B_out_E)
                    cmp_taken = 1'b1;
            end
            COND_NOT_EQUALS: begin
                if (mux_forward_A_out_E != mux_forward_B_out_E)
                    cmp_taken = 1'b1;
            end
            COND_LOWER: begin
                if (mux_forward_A_out_E < mux_forward_B_out_E)
                    cmp_taken = 1'b1;
            end
            COND_GREATER_OR_EQUAL: begin
                if (mux_forward_A_out_E >= mux_forward_B_out_E)
                    cmp_taken = 1'b1;
            end
            COND_LOWER_UNSIGNED: begin
                if ($unsigned(mux_forward_A_out_E) < $unsigned(mux_forward_B_out_E))
                    cmp_taken = 1'b1;
            end
            COND_GREATER_OR_EQUAL_UNSIGNED: begin
                if ($unsigned(mux_forward_A_out_E) >= $unsigned(mux_forward_B_out_E))
                    cmp_taken = 1'b1;
            end
            COND_NONE: begin
                    cmp_taken = 1'b0;
            end
            default: cmp_taken = 1'b0;
        endcase
    end

    always_comb begin
        PC_source_E = 2'b00;
        if (jump_E || i_jump_E)             PC_source_E = 2'b10;
        else if (branch_E && !cmp_taken)    PC_source_E = 2'b01; // Do branch
    end
    assign fk_go_back_E = PC_source_E == 2'b00; // Resets F_D and D_E pipes

    ALU
    #(
        .DATA_WIDTH(32)
    )
    alu
    (
        // Inputs
            // Control signals
            .ALU_op(ALU_op_E),
            // Data signlas 
            .A(mux_ALU_operand_A_out),
            .B(mux_ALU_operand_B_out),
        // Outputs
            // Data outputs
            .ALU_result(ALU_result_E)
    );


endmodule