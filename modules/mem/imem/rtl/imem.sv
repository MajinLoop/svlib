// Modelo “1-cycle latency” con buffer ready/valid
module imem
#(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int WORDS = 4096,
    parameter string MEMFILE = "prog.hex"
)
(
    input  logic clk,
    input  logic async_rst_n,

    // Request: PC -> IMEM
    input  logic [ADDR_WIDTH-1:0] pc,
    input  logic                  pc_valid_in,
    output logic                  pc_ready_out,

    // Response: instruction -> core
    output logic [DATA_WIDTH-1:0] instruction,
    output logic                  instruction_valid_out,
    input  logic                  instruction_ready_in
);
    localparam int WORD_SHIFT = 2;
    localparam int IDX_W = $clog2(WORDS);

    logic [DATA_WIDTH-1:0] mem [0:WORDS-1];

    initial $readmemh(MEMFILE, mem);

    logic [IDX_W-1:0] idx;
    assign idx = pc[WORD_SHIFT + IDX_W - 1 : WORD_SHIFT]; // word aligned

    assign pc_ready_out = (!instruction_valid_out) || (instruction_ready_in); // puedo aceptar request si mi output buffer está libre o se va a consumir

    always_ff @(posedge clk or negedge async_rst_n) begin
        if (!async_rst_n) begin
            instruction <= '0;
            instruction_valid_out <= 1'b0;
        end
        else begin
            // Send
            if (instruction_ready_in && instruction_valid_out) instruction_valid_out <= 1'b0;
            // Take
            if (pc_valid_in && pc_ready_out) begin
                instruction <= mem[idx];
                instruction_valid_out <= 1'b1;
            end
        end
    end
endmodule
