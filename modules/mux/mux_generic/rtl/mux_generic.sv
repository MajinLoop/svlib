// CHANNELS_COUNT must be >= 2
// CHANNELS_WIDTH must be >= 1
// select signal is ceil(log2(CHANNELS_COUNT)) bits wide
module mux_generic
#(
    parameter int unsigned CHANNELS_COUNT = 4,
    parameter int unsigned CHANNELS_WIDTH = 8
)
(
	input logic [$clog2(CHANNELS_COUNT)-1:0] select,
	input logic [CHANNELS_COUNT-1:0][CHANNELS_WIDTH-1:0] channels,
	
	output logic [CHANNELS_WIDTH-1:0] channel_out
);

initial begin
    if (CHANNELS_COUNT < 2) $fatal("multiplexer_mxn: CHANNELS_COUNT must be >= 2 (got %0d)", CHANNELS_COUNT);
    if (CHANNELS_WIDTH < 1) $fatal("multiplexer_mxn: CHANNELS_WIDTH must be >= 1 (got %0d)", CHANNELS_WIDTH);
end

always_comb begin
    int unsigned sel;
    sel = select;
    if (sel < CHANNELS_COUNT) begin
        channel_out = channels[sel];
    end
    else begin
        channel_out = '0;
        // channel_out = 'x; // alternatively if you want out-of-range to be loud in sim
    end
end

endmodule