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

    output logic [15:0] result_matrix_o[49],
    output result_valid,

    input [15:0] input_matrix_a[49],
    input [15:0] input_matrix_b[49],
    input inputs_valid
);

    localparam RECEIVE_LOW = 0;
    localparam DELAY_LOW = 1;
    localparam RECEIVE_HIGH = 2;
    localparam DELAY_HIGH = 3;

    logic [5:0] temp_idx;
    logic [1:0] state;
    logic [7:0] low_byte;

    integer log_file;
    integer start_time;
    integer end_time;
    logic algorithm_started;
    logic inputs_logged;
    logic outputs_logged;
    logic log_file_opened;

    initial begin
        log_file = $fopen("monitor_log.txt", "w");
        if (log_file == 0) begin
            $display("Error: Could not open log file");
            $finish;
        end
        log_file_opened = 1;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            temp_idx <= 0;
            state <= RECEIVE_LOW;
            algorithm_started <= 0;
            inputs_logged <= 0;
            outputs_logged <= 0;
            low_byte <= 0;
            for (int i = 0; i < 49; i++) begin
                result_matrix_o[i] <= '0;
            end
        end else begin
            // Log input matrices when they are valid
            if (inputs_valid && !inputs_logged) begin
                $fwrite(log_file, "Matrix A (7x7):\n");
                for (int i = 0; i < 7; i++) begin
                    $fwrite(log_file, "  [%5d %5d %5d %5d %5d %5d %5d]\n",
                        input_matrix_a[i*7 + 0], input_matrix_a[i*7 + 1], input_matrix_a[i*7 + 2],
                        input_matrix_a[i*7 + 3], input_matrix_a[i*7 + 4], input_matrix_a[i*7 + 5],
                        input_matrix_a[i*7 + 6]);
                end

                $fwrite(log_file, "\nMatrix B (7x7):\n");
                for (int i = 0; i < 7; i++) begin
                    $fwrite(log_file, "  [%5d %5d %5d %5d %5d %5d %5d]\n",
                        input_matrix_b[i*7 + 0], input_matrix_b[i*7 + 1], input_matrix_b[i*7 + 2],
                        input_matrix_b[i*7 + 3], input_matrix_b[i*7 + 4], input_matrix_b[i*7 + 5],
                        input_matrix_b[i*7 + 6]);
                end

                $fwrite(log_file, "\n");
                inputs_logged <= 1;
            end

            case (state)
                RECEIVE_LOW: begin
                    if (gpio_led[14]) begin
                        // Mark algorithm start on first output
                        if (!algorithm_started) begin
                            start_time = $time;
                            algorithm_started <= 1;
                            $fwrite(log_file, "Algorithm started at time: %0t ns\n\n", start_time);
                        end

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

            // Log outputs when all results received (only once)
            if (temp_idx == 49 && algorithm_started && !outputs_logged) begin
                end_time = $time;

                $fwrite(log_file, "Result Matrix C (7x7):\n");
                for (int i = 0; i < 7; i++) begin
                    $fwrite(log_file, "  [%5d %5d %5d %5d %5d %5d %5d]\n",
                        result_matrix_o[i*7 + 0], result_matrix_o[i*7 + 1], result_matrix_o[i*7 + 2],
                        result_matrix_o[i*7 + 3], result_matrix_o[i*7 + 4], result_matrix_o[i*7 + 5],
                        result_matrix_o[i*7 + 6]);
                end

                $fwrite(log_file, "Algorithm started at:  %0t ns\n", start_time);
                $fwrite(log_file, "Algorithm finished at: %0t ns\n", end_time);
                $fwrite(log_file, "Total execution time:  %0t ns\n\n", end_time - start_time);

                outputs_logged <= 1;
            end
        end
    end

    assign result_valid = (temp_idx == 49) ? 1 : 0;

    final begin
        $fclose(log_file);
    end
endmodule
