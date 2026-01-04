module regfile
#(
    parameter WIDTH = 32
)
(
    // Secuential input signals
    input logic clk,
    input logic async_rst_n,

    // Write ports
    input logic write_enable,
    input logic [4:0] write_addr,
    input logic [WIDTH-1:0] write_data,

    // Read ports
    input logic [4:0] operand_1_addr,
    input logic [4:0] operand_2_addr,

    output logic [WIDTH-1:0] operand_1_data,
    output logic [WIDTH-1:0] operand_2_data
);

logic [30:0][WIDTH-1:0] rf;

always_ff @(negedge clk or posedge async_rst_n) begin
    if (!async_rst_n) begin
        rf <= '{default: '0};
    end
    else begin
        if (write_enable && (write_addr != 0)) begin
            rf[write_addr] <= write_data;
        end
    end
end
assign operand_1_data = (operand_1_addr != 0) ? rf[operand_1_addr] : '0;
assign operand_2_data = (operand_2_addr != 0) ? rf[operand_2_addr] : '0;

endmodule