module pipe
#(
    parameter type T = logic [31:0]
)
(
    // Secuential control
        input logic clk,
        input logic async_rst_n,
        input logic sync_rst_n,
        input logic flush,
    // Recieving data
        // Data
            input T d,
            // Handshake
                output logic ready_out, // current_ready
                input logic valid_in, // prev_valid

    // Sending data
        // Data
            output T q,
            // Handshake
                input logic ready_in, // next_ready
                output logic valid_out // current_valid
);
    assign ready_out = ready_in || !valid_out;

    logic able_to_take;
    logic able_to_drop;
    assign able_to_take = ready_out && valid_in;
    assign able_to_drop = ready_in && valid_out;
    
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
            if (able_to_drop && !able_to_take) valid_out <= 1'b0;
            // We can take
            if (able_to_take) begin
                q <= d;
                valid_out <= 1'b1;
            end
        end
    end
endmodule