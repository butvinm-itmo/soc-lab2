`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/23/2025 02:58:40 PM
// Design Name:
// Module Name: monitor
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

module monitor (
    input clk,
    input rst,
    input [15:0] gpio_led,

    output logic [15:0] result_matrix_o[`MATRIX_SIZE],
    output result_valid,

    input test_done_i
);

    localparam RECEIVE_LOW = 0;
    localparam DELAY_LOW = 1;
    localparam RECEIVE_HIGH = 2;
    localparam DELAY_HIGH = 3;

    logic [5:0] temp_idx;
    logic [1:0] state;
    logic [7:0] low_byte;

    always_ff @(posedge clk) begin
        if (rst) begin
            temp_idx <= 0;
            state <= RECEIVE_LOW;
            low_byte <= 0;
            for (int i = 0; i < `MATRIX_SIZE; i++) begin
                result_matrix_o[i] <= '0;
            end
        end else begin
            // Reset for next test when scoreboard signals completion
            if (test_done_i) begin
                temp_idx <= 0;
                state <= RECEIVE_LOW;
                low_byte <= 0;
            end else begin
                case (state)
                    RECEIVE_LOW: begin
                        if (gpio_led[14]) begin
                            low_byte <= gpio_led[7:0];
                            state <= DELAY_LOW;
                        end
                    end

                    DELAY_LOW: begin
                        if (!gpio_led[14]) begin
                            state <= RECEIVE_HIGH;
                        end
                    end

                    RECEIVE_HIGH: begin
                        if (gpio_led[14]) begin
                            result_matrix_o[temp_idx] <= {gpio_led[7:0], low_byte};
                            temp_idx <= temp_idx + 1'b1;
                            state <= DELAY_HIGH;
                        end
                    end

                    DELAY_HIGH: begin
                        if (!gpio_led[14]) begin
                            state <= RECEIVE_LOW;
                        end
                    end
                endcase
            end
        end
    end

    assign result_valid = (temp_idx == `MATRIX_SIZE) ? 1 : 0;

endmodule
