`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/23/2025 02:15:36 PM
// Design Name:
// Module Name: sequencer
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

`include "tb_defines.svh"

module sequencer (
    input clk_i,
    input rst_i,
    output logic [15:0] sequence_o[`MATRIX_SIZE],
    output logic sequence_valid_o,
    input sequence_send_i,
    input test_start_i
);
    localparam IDLE = 0;
    localparam SEND_A = 1;
    localparam WAIT_A = 2;
    localparam SEND_B = 3;
    localparam WAIT_B = 4;

    logic [15:0] matrix_a[`MATRIX_SIZE];
    logic [15:0] matrix_b[`MATRIX_SIZE];

    logic [2:0] state;

    function automatic logic [15:0] gen_random_value();
        int rand_choice;
        int rand_val;

        rand_choice = $urandom_range(5, 0);

        if (rand_choice == 0) begin
            rand_val = $urandom_range(50, 0);
        end else begin
            rand_val = $urandom_range(150, 100);
        end

        return rand_val[15:0];
    endfunction

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            state <= IDLE;
            for (int i = 0; i < `MATRIX_SIZE; i++) begin
                sequence_o[i] <= '0;
                matrix_a[i]   <= '0;
                matrix_b[i]   <= '0;
            end
            sequence_valid_o <= '0;
        end else begin
            case (state)
                IDLE: begin
                    if (test_start_i) begin
                        for (int i = 0; i < `MATRIX_SIZE; i++) begin
                            matrix_a[i] <= gen_random_value();
                            matrix_b[i] <= gen_random_value();
                        end
                        state <= SEND_A;
                    end
                    sequence_valid_o <= 0;
                end
                SEND_A: begin
                    sequence_o <= matrix_a;
                    sequence_valid_o <= 1;
                    state <= WAIT_A;
                end
                WAIT_A: begin
                    sequence_valid_o <= 0;
                    if (sequence_send_i) begin
                        state <= SEND_B;
                    end
                end
                SEND_B: begin
                    sequence_o <= matrix_b;
                    sequence_valid_o <= 1;
                    state <= WAIT_B;
                end
                WAIT_B: begin
                    sequence_valid_o <= 0;
                    if (sequence_send_i) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
