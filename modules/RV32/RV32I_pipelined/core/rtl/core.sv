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
            input logic [DATA_WIDTH-1:0] instruction,

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
        // Fetch inputs
            // Control
                logic [1:0] PC_source_E;    
                logic enable_fetch_H;
                logic prediction_source_D;
            // Data
                logic [DATA_WIDTH-1:0] PC_plus_4_E;
                logic [DATA_WIDTH-1:0] ALU_result_E;
                logic [DATA_WIDTH-1:0] predicted_PC_D;

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
                    .PC_source_E(PC_source_E), // todo
                    .enable_fetch(pc_ready_in),
                    .prediction_source_D(prediction_source_D), // todo

                // Data input signals
                    .PC_plus_4_E(PC_plus_4_E), // todo
                    .ALU_result_E(ALU_result_E), // todo
                    .predicted_PC_D(predicted_PC_D), // todo

                // Data output signals
                    .PC_F(PC_F),
                    .PC_plus_4_F(PC_plus_4_F)
            );
        logic PC_F_valid_out; assign PC_F_valid_out = 1'b1;
        

    // // IMEM
    //     logic imem_instruction_valid_out;
    //     imem
    //     #(
    //         .ADDR_WIDTH(32),
    //         .DATA_WIDTH(32),
    //         .WORDS(4096),
    //         .MEMFILE("prog.hex")
    //     )
    //     imem_i
    //     (
    //         // Secuential input signals
    //             .clk(clk),
    //             .async_rst_n(async_rst_n),
    //         // Request: PC -> IMEM
    //             .pc(PC_F),
    //             .pc_valid_in(PC_F_valid_out),
    //             .pc_ready_out(enable_fetch_H),
    //         // Response: instruction -> core
    //             .instruction(instruction),
    //             .instruction_valid_out(imem_instruction_valid_out),
    //             .instruction_ready_in()
    //     );



    // Pipe
        // Pipe setup
            pipe_FD_bus_t pipe_FD_d, pipe_FD_q; // I/O Bus
            logic pipe_FD_ready_in, pipe_FD_valid_out; // Handshake
            // I/O signals
                assign pipe_FD_d.instruction = instruction;
                assign pipe_FD_d.PC_F = PC_F;
                assign pipe_FD_d.PC_plus_4_F = PC_plus_4_F;
        // Pipe instantistion
            pipe
            #(
                .T(FD_pipe_bus_t)
            )
            pipe_FD_i
            (
                // Secuential control
                    .clk(clk),
                    .async_rst_n(async_rst_n),
                    .sync_rst_n(), // todo
                    .flush(1'b0),
                // Recieving data
                    // Data
                        .d(pipe_FD_d),
                        // Handshake
                            .ready_out(instruction_ready_out), // current_ready
                            .valid_in(instruction_valid_in), // prev_valid
                // Sending data
                    // Data
                        .q(pipe_FD_q),
                        // Handshake
                            .ready_in(pipe_FD_ready_in), // next_ready // todo
                            .valid_out(pipe_FD_valid_out) // current_valid
            );

    // Decode stage
        // Decode inputs
            // Control
                logic [4:0] rf_write_addr_W;
                logic rf_write_enable_W;
                logic 
            // Data
                logic 
                logic 
                logic 
        // Decode outputs
            logic 
        // Decode instance
        decode_stage
        #(
            .DATA_WIDTH(32)
        )
        decode_stage_i
        (
            // Secuential input signals
                .clk(clk),
                .async_rst_n(async_rst_n),
            // Control input signals
                .rf_write_addr_W(rf_write_addr_W),
                .rf_write_enable_W(rf_write_enable_W),
            // Data input signals
                .instruction(pipe_FD_q.instruction),
                // Regfile
                    .rf_write_data_W(),
                // Prediction
                    .PC_D(),
            // Control output signals
                // Jumping
                    .jump_D(),
                    .i_jump_D(),
                    .branch_D(),
                // Execute
                    .cond_code_D(),
                    .mux_ALU_operand_A_select_D(),
                    .mux_ALU_operand_B_select_D(),
                    .ALU_op_D(),
                // Memory
                    .memory_transaction_D(),
                    .mem_write_D(),
                    .width_type_D(),
                // Writeback
                    .reg_write_D(),
                    .mux_writeback_select_D(),
                // Register addresses
                    .rs1_addr_D(),
                    .rs2_addr_D(),
                    .rd_addr_D(),

            // Data output signals
                // Regfile
                    .rs1_data_D(),
                    .rs2_data_D(),
                // MUX_ALU_OPERAND_B_IMMEDIATE
                    .immediate_D(),
                // Prediction
                    .predicted_PC_addr_D()
        );






endmodule
