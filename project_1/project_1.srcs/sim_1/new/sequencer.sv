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


module sequencer (
    input clk_i,
    input rst_i,
    output logic [15:0] sequence_o[49],
    output logic sequence_valid_o,
    input sequence_send_i
);
    localparam SEND_A = 0;
    localparam WAIT = 1;
    localparam SEND_B = 2;

    logic [15:0] matrix_a[49];
    logic [15:0] matrix_b[49];

    logic [ 1:0] state;

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
            state <= SEND_A;
            for (int i = 0; i < 49; i++) begin
                sequence_o[i] <= '0;
                matrix_a[i]   <= gen_random_value();
                matrix_b[i]   <= gen_random_value();
            end
            sequence_valid_o <= '0;
        end else begin
            case (state)
                SEND_A: begin
                    sequence_o <= matrix_a;
                    sequence_valid_o <= 1;
                    state <= WAIT;
                end
                WAIT: begin
                    if (sequence_send_i) begin
                        state <= SEND_B;
                    end
                    sequence_valid_o <= 0;
                end
                SEND_B: begin
                    sequence_o <= matrix_b;
                    sequence_valid_o <= 1;
                end
            endcase
        end
    end
endmodule
