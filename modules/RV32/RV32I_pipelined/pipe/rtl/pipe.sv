module pipe
#(
    parameter type   T     = logic [31:0]
)
(
    // Inputs
        // Secuential control
            input logic clk,
            input logic async_rst_n,
            input logic sync_rst_n,
            input logic flush,
        // Handshake
            input logic ready_in, // El siguiente tiene espacio
            input logic valid_in, // El anterior me puede dar un dato
        // Data
            input T d,

    // Outputs
        // Handshake
            output logic ready_out, // Puedo aceptar un dato
            output logic valid_out, // Puedo dar un dato
        // Data
            output T q
);

    assign ready_out = ready_in || !valid_out;

    logic able_to_take;
    logic able_to_drop;
    assign able_to_take = ready_out && valid_in; // carga d -> q
    assign able_to_drop = ready_in && valid_out; // consumidor acepta q
    
    always_ff @(posedge clk or negedge async_rst_n) begin
        if (!async_rst_n) begin
            q <= '0;
            valid_out <= 1'b0;
        end
        else if (!sync_rst_n) begin
            q <= '0;
            valid_out <= 1'b0;
        end
        else if (flush) begin
            q <= '0;
            valid_out <= 1'b0;
        end
        else begin
            // We send but not recieve
            if (able_to_drop && !able_to_take) begin
                valid_out <= 1'b0;
            end
            // We can take
            if (able_to_take) begin
                q <= d;
                valid_out <= 1'b1;
            end
        end
    end
endmodule