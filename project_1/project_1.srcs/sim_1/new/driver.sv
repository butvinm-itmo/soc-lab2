`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/23/2025 02:37:35 PM
// Design Name:
// Module Name: driver
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


module driver (
    input clk,
    input rst,

    input [15:0] sequence_i[49],
    input sequence_valid,
    output logic sequence_send,

    output logic [15:0] gpio_switch,
    input [15:0] gpio_led
);
    localparam WAIT_SEQ = 0;
    localparam SEND_SEQ = 1;

    logic state;
    logic receive;

    logic [15:0] temp_matrix[49];
    logic [5:0] temp_idx;

    wire send_vld = gpio_switch[15];
    wire receive_vld = gpio_led[15];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < 49; i++) begin
                temp_matrix[i] <= '0;
            end
            temp_idx <= 0;
            state <= WAIT_SEQ;
            receive <= 0;
        end else begin
            case (state)
                WAIT_SEQ: begin
                    if (sequence_valid) begin
                        temp_matrix <= sequence_i;
                        state <= SEND_SEQ;
                    end
                    receive <= 0;
                    temp_idx <= 0;
                    sequence_send <= 0;
                end
                SEND_SEQ: begin
                    if (temp_idx == 49) begin
                        state <= WAIT_SEQ;
                        sequence_send <= 1;
                    end else begin
                        if (send_vld) begin
                            if (receive && !receive_vld) begin
                                temp_idx <= temp_idx + 1'b1;
                                gpio_switch <= 0;
                                receive <= 0;
                            end else if (receive_vld) begin
                                receive <= 1;
                            end
                        end else begin
                            gpio_switch <= temp_matrix[temp_idx] | 16'h8000;
                        end
                    end
                end
            endcase
        end
    end
endmodule
