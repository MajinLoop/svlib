module core
#(
    parameter PC_WIDTH = 32,
    parameter DATA_WIDTH = 32
)
(
    // Secuential control
        input logic clk,
        input logic async_rst_n,

    // IMEM interface
        // Sending PC
            output logic [PC_WIDTH-1:0] PC_F,
        
            input logic pc_ready_in, // next_ready
            output logic pc_valid_out, // current_valid

        // Recieving instruction
            input logic [DATA_WIDTH-1:0] instruction_F,

            output logic instruction_ready_out, // current_ready
            input logic instruction_valid_in, // prev_valid

    // DMEM interface
        // Sending data
            output logic write_enable,

            output logic [DATA_WIDTH-1:0] addr, // DMEM addr
            output logic [DATA_WIDTH-1:0] data_to_dmem,
            output logic [3:0] byte_enablers,

            input logic data_to_dmem_ready_in, // next_ready
            output logic data_to_dmem_valid_out, // current_valid
        // Recieving data
            input logic [DATA_WIDTH-1:0] data_from_dmem,

            output logic data_from_dmem_ready_out, // current_ready
            input logic data_from_dmem_valid_in, // prev_valid
);
    import rv32i_types_pkg::*;


    // Fetch stage
        // Fetch outputs
            logic [DATA_WIDTH-1:0] PC_plus_4_F;
        // Fetch stage instance
            fetch_stage
            #(
                .PC_WIDTH(32)
            )
            fetch_stage_i
            (
                // Secuential input signals
                    .clk(clk),
                    .async_rst_n(async_rst_n),

                // Control input signals
                    .PC_source_E(),
                    .enable_fetch_H(),
                    .prediction_source_D(),

                // Data input signals
                    .PC_plus_4_E(),
                    .ALU_result_E(),
                    .predicted_PC_D(),

                // Data output signals
                    .PC_F(PC_F),
                    .PC_plus_4_F(PC_plus_4_F)
            );


    // Pipe
        // Pipe setup
            FD_pipe_bus_t fd_d, fd_q; // I/O Bus
            logic fd_ready_in, fd_valid_out; // Handshake
            // I/O signals
                assign fd_d.instruction_F = instruction_F;
                assign fd_d.PC_F = PC_F;
                assign fd_d.PC_plus_4_F = PC_plus_4_F;
        // Pipe instantistion
            pipe
            #(
                .T(FD_pipe_bus_t)
            )
            instance_name
            (
                // Secuential control
                    .clk(clk),
                    .async_rst_n(async_rst_n),
                    .sync_rst_n(), //// Not connectable yet because there is no instance of the required module
                    .flush(1'b0),
                // Recieving data
                    // Data
                        .d(fd_d),
                        // Handshake
                            .ready_out(instruction_ready_out), // current_ready
                            .valid_in(instruction_valid_in), // prev_valid
                // Sending data
                    // Data
                        .q(fd_q),
                        // Handshake
                            .ready_in(fd_ready_in), // next_ready //// Not connectable yet because there is no instance of the required module
                            .valid_out(fd_valid_out) // current_valid
            );

endmodule
