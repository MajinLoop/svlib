// Parametrized D flip-flop (dff) with asynchronous (async) active-low (_n) reset and enable (en)
module dff_async_rst_n_en
#(
    parameter int unsigned WIDTH = 4
)
(
    input logic clk,
    input logic async_rst_n,

    input logic enabler,

    input logic [WIDTH-1:0] data,

    output logic [WIDTH-1:0] q
);

always_ff @(posedge clk, negedge async_rst_n)
begin
    if(!async_rst_n)
        q <= {WIDTH{1'b0}};
    else if (enabler)
        q <= data;
end

endmodule