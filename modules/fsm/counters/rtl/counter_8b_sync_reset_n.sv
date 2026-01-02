module counter_8b_sync_reset_n
(
    input logic clk,
    input logic sync_rst,
    
    output logic [7:0] q
);

always_ff @(posedge clk)
begin
    if(!sync_rst)
    {
        q <= 8'b0;
    }
    else
    {
        q <= q+1;
    }
end
endmodule