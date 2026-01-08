module ALU
#(
    parameter DATA_WIDTH = 32
)
(
    // Inputs
        // Control signals
        input rv32i_types_pkg::ALU_op_enum ALU_op,
        // Data signlas 
        input logic [DATA_WIDTH-1:0] A,
        input logic [DATA_WIDTH-1:0] B,
    // Outputs
        // Data outputs
        output logic [DATA_WIDTH-1:0] ALU_result
);
    import rv32i_types_pkg::*;

    always_comb begin
        ALU_result = '0;
        unique case (ALU_op)
            ALU_ADD:        ALU_result = A + B;
            ALU_SUB:        ALU_result = A - B;
            ALU_XOR:        ALU_result = A ^ B;
            ALU_OR:         ALU_result = A | B;
            ALU_AND:        ALU_result = A & B;
            ALU_SLL:        ALU_result = A << B[$clog2(DATA_WIDTH)-1:0];
            ALU_SRL:        ALU_result = $unsigned(A) >> B[$clog2(DATA_WIDTH)-1:0];
            ALU_SRA:        ALU_result = $signed(A) >>> B[$clog2(DATA_WIDTH)-1:0];
            ALU_SLT: begin
                if ($signed(A) < $signed(B))
                            ALU_result = {{(DATA_WIDTH-1){1'b0}}, 1'b1};
            end
            ALU_SLTU: begin
                if ($unsigned(A) < $unsigned(B))
                            ALU_result = {{(DATA_WIDTH-1){1'b0}}, 1'b1};
            end
            ALU_OPERAND_A:  ALU_result = A;
            ALU_OPERAND_B:  ALU_result = B;
            ALU_NONE:       ALU_result = '0;
            default:        ALU_result = '0;
        endcase
    end
endmodule