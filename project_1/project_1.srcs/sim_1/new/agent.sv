`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/23/2025 03:50:44 PM
// Design Name:
// Module Name: agent
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


module agent (
    input clk_i,
    input rst_i,
    output [15:0] gpio_switch,
    input [15:0] gpio_led
);

    logic [15:0] tmp_sequence[49];
    logic [15:0] result_sequence[49];
    logic [15:0] matrix_a[49];
    logic [15:0] matrix_b[49];
    logic sequence_valid, sequence_send, result_valid;
    logic matrix_a_stored, matrix_b_stored;

    // Store matrices as they come from sequencer
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            matrix_a_stored <= 0;
            matrix_b_stored <= 0;
        end else if (sequence_valid) begin
            if (!matrix_a_stored) begin
                matrix_a <= tmp_sequence;
                matrix_a_stored <= 1;
            end else if (!matrix_b_stored) begin
                matrix_b <= tmp_sequence;
                matrix_b_stored <= 1;
            end
        end
    end

    sequencer sequencer_impl (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .sequence_o(tmp_sequence),
        .sequence_valid_o(sequence_valid),
        .sequence_send_i(sequence_send)
    );

    driver driver_impl (
        .clk(clk_i),
        .rst(rst_i),

        .sequence_i(tmp_sequence),
        .sequence_valid(sequence_valid),
        .sequence_send(sequence_send),

        .gpio_switch(gpio_switch),
        .gpio_led(gpio_led)
    );

    monitor monitor_impl (
        .clk(clk_i),
        .rst(rst_i),
        .gpio_led(gpio_led),

        .result_matrix_o(result_sequence),
        .result_valid(result_valid),

        .input_matrix_a(matrix_a),
        .input_matrix_b(matrix_b),
        .inputs_valid(matrix_b_stored)
    );

    scoreboard scoreboard_impl (
        .clk_i(clk_i),
        .rst_i(rst_i),

        .matrix_input(tmp_sequence),
        .matrix_vld  (sequence_valid),

        .result_matrix(result_sequence),
        .result_vld(result_valid)
    );
endmodule
