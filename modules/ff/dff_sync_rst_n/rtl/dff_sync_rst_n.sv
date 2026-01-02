// Parametrized D flip-flop (dff) with synchronous (sync) active-low (_n) reset
module dff_sync_rst_n
#(
    parameter int unsigned WIDTH = 4
)
(
    input logic clk,
    input logic sync_rst_n,

    input logic [WIDTH-1:0] data,

    output logic [WIDTH-1:0] q
);

always_ff @(posedge clk)
begin
    if(!sync_rst_n)
        q <= {WIDTH{1'b0}};
    else
        q <= data;
end

endmodule
