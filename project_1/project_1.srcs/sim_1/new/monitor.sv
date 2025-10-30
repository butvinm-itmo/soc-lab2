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


module monitor (
    input clk,
    input rst,
    input [15:0] gpio_led,

    output logic [15:0] result_matrix_o[9],
    output result_valid
);

    localparam RECEIVE = 0;
    localparam DELAY = 1;

    logic [3:0] temp_idx;
    logic state;

    always_ff @(posedge clk) begin
        if (rst) begin
            temp_idx <= 0;
            state <= RECEIVE;
            for (int i = 0; i < 9; i++) begin
                result_matrix_o[i] <= '0;
            end
        end else if (state == RECEIVE) begin
            if (gpio_led[14]) begin
                result_matrix_o[temp_idx] <= gpio_led[7:0];
                temp_idx <= temp_idx + 1'b1;
                state <= DELAY;
            end
        end else begin
            if (!gpio_led[14]) begin
                state <= RECEIVE;
            end
        end
    end

    assign result_valid = (temp_idx == 9) ? 1 : 0;
endmodule
