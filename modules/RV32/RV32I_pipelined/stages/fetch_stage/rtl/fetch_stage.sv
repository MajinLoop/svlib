module fetch_stage
#(
    parameter PC_WIDTH = 32
)
(
    // Secuential input signals
    input  logic                     clk,
    input  logic                     async_rst_n,

    // Control input signals
    input logic [1:0] PC_source_E,
    input logic enable_fetch,
    input logic prediction_source_D,

    // Data input signals
    input logic [PC_WIDTH-1:0]    PC_plus_4_E,
    input logic [PC_WIDTH-1:0]    ALU_result_E,
    input logic [PC_WIDTH-1:0]    predicted_PC_D,

    // Data output signals
    output logic [PC_WIDTH-1:0]    PC_F,
    output logic [PC_WIDTH-1:0]    PC_plus_4_F
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
        .enabler(enable_fetch),
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