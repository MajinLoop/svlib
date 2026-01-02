module fsm_example
(
    input logic clk,
    input logic sync_rst,

    input logic in,

    output logic done
);

typedef enum logic [1:0]
{
    S0 = 2'b00,
    S1 = 2'b01,
    S2 = 2'b10,
    S3 = 2'b11,
}state_t;

state_t current_state, next_state;

always_ff @(posedge clk)
begin
    if(!sync_rst)
        current_state <= S0;
    else
        current_state <= next_state;
end

always_comb
begin
    case (current_state)
        S0: next_state = (in == 1) ? S1 : S0;
        S1: next_state = (in == 1) ? S2 : S1;
        S2: next_state = (in == 1) ? S3 : S2;
        S3: next_state = (in == 1) ? S3 : S0;
        default: next_state = current_state;
    endcase    
end

always_comb
begin
    done = (current_state == S3);
end


endmodule
