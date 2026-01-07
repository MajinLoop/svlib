module regfile
#(
    parameter int unsigned DATA_WIDTH = 32,
    parameter int unsigned ADDR_WIDTH = 5
)
(
    // Secuential input signals
    input logic clk,
    input logic async_rst_n,

    // Write ports
    input logic write_enable,
    input logic [ADDR_WIDTH-1:0] write_addr,
    input logic [DATA_WIDTH-1:0] write_data,

    // Read ports
    input logic [ADDR_WIDTH-1:0] rs1_addr,
    input logic [ADDR_WIDTH-1:0] rs2_addr,

    output logic [DATA_WIDTH-1:0] rs1_data,
    output logic [DATA_WIDTH-1:0] rs2_data
);

localparam int unsigned POSSIBLE_REG_COUNT = 2**ADDR_WIDTH;
localparam int unsigned REAL_REG_COUNT = POSSIBLE_REG_COUNT - 1; // Register x0 is hardwired to 0

logic [REAL_REG_COUNT-1:0][DATA_WIDTH-1:0] rf;

integer i;
always_ff @(negedge clk or negedge async_rst_n) begin
    if (!async_rst_n)begin
        // rf <= '{default: '0}; // Icarus no le sabe a eso
        for (i = 0; i < REAL_REG_COUNT; i = i + 1) begin
            rf[i] <= '0;
        end
    end
    else begin
        if (write_enable && (write_addr != '0)) begin
            rf[write_addr - 1] <= write_data;
        end
    end
end
assign rs1_data = (rs1_addr != '0) ? rf[rs1_addr - 1] : '0;
assign rs2_data = (rs2_addr != '0) ? rf[rs2_addr - 1] : '0;

endmodule