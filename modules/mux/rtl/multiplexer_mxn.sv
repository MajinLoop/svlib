// CHANNELS_COUNT must be >= 2
// CHANNELS_WIDTH must be >= 1
// select signal is ceil(log2(CHANNELS_COUNT)) bits wide
module multiplexer_mxn
#(
    parameter int unsigned CHANNELS_COUNT = 5,
    parameter int unsigned CHANNELS_WIDTH = 4
)
(
	input logic [$clog2(CHANNELS_COUNT)-1:0] select,
	input logic [CHANNELS_COUNT-1:0][CHANNELS_WIDTH-1:0] channels,
	
	output logic [CHANNELS_WIDTH-1:0] selected_channel
);

initial begin
    if (CHANNELS_COUNT < 2) $fatal("multiplexer_mxn: CHANNELS_COUNT must be >= 2 (got %0d)", CHANNELS_COUNT);
    if (CHANNELS_WIDTH < 1) $fatal("multiplexer_mxn: CHANNELS_WIDTH must be >= 1 (got %0d)", CHANNELS_WIDTH);
end

always_comb begin
    int unsigned sel;
    sel = select;
    if (sel < CHANNELS_COUNT) begin
        selected_channel = channels[sel];
    end
    else begin
        selected_channel = '0;
        // selected_channel = 'x; // alternatively if you want out-of-range to be loud in sim
    end
end

endmodule