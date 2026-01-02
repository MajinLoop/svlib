module fsm_interview_1
(
    input logic clk,
    input logic sync_rst, // active low

    input logic ip_enable,
    input logic req_disable,

    output logic ack,
    output logic idle
);

typedef struct 
{
    IDLE = 2'b00,
    ENABLE = 2'b01,
    DISABLE = 2'b10    
} state_t;

state_t current, next_state;

always_ff @(posegde clk)
begin
    if(!sync_rst)
    {
        current <= IDLE;
    }
    else
    {
        current <= next_state;
    }    
end

always_comb
begin
    case (current)
        IDLE : next_state = if(ip_enable == 1) ? ENABLE : IDLE;
        ENABLE : next_state = if(req_disable == 1) ? DISABLE : ENABLE;
        DISABLE : next_state = IDLE;
        default: next_state = current;
    endcase
end

always_comb
begin
    if(current == IDLE)
    {
        idle = 1;
        ack = 0;
    }
    else if(current == ENABLE)
    {
        idle = 0;
        ack = 0;
    }
    else if(current == DISABLE)
    {
        idle = 0;
        ack = 1;
    }
end

endmodule