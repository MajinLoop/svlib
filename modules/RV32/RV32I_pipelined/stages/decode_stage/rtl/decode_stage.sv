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
    output logic reg_write_D,
    output logic [1:0] result_source_D,
    output logic [2:0] width_type_D,
    output logic [2:0] mem_write_D,
    output logic [3:0] ALU_op_D,
    output logic [2:0] cond_code,
    output logic ALU_source_D,
    output logic jump_D,
    output logic i_jump_D,
    output logic branch_D,
    output logic PC_to_ALU_D,
    output logic memory_transaction_D,
    output logic branch_prediction_select_D,
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
    output logic [DATA_WIDTH-1:0]    predicted_PC_addr_D,
);

    logic [PC_WIDTH-1:0] mux_PC_source_out;
    logic [PC_WIDTH-1:0] reg_PC_out;

    mux_generic
    #(
        .CHANNELS_COUNT(4),
        .CHANNELS_WIDTH(PC_WIDTH)
    )
    mux_PC_source
    (
        .select(PC_source_E),
        .channels
        (
            {
                '0,             // 3
                ALU_result_E,   // 2
                PC_plus_4_E,    // 1
                PC_plus_4_F     // 0
            }
        ),
        .channel_out(mux_PC_source_out)
    );

    dff_async_rst_n_en
    #(
        .WIDTH(PC_WIDTH)
    )
    reg_PC
    (
        .clk(clk),
        .async_rst_n(async_rst_n),
        .enabler(enable_fetch_H),
        .data(mux_PC_source_out),
        .q(reg_PC_out)
    );

    mux_generic
    #(
        .CHANNELS_COUNT(2),
        .CHANNELS_WIDTH(PC_WIDTH)
    )
    mux_predictor
    (
        .select(prediction_source_D),
        .channels
        (
            {
                predicted_PC_D, // 1
                reg_PC_out      // 0
            }
        ),
        .channel_out(PC_F)
    );

    assign PC_plus_4_F = PC_F + 4;
endmodule