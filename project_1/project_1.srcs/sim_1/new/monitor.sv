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
    output result_valid,

    input [15:0] input_matrix_a[9],
    input [15:0] input_matrix_b[9],
    input inputs_valid
);

    localparam RECEIVE = 0;
    localparam DELAY = 1;

    logic [3:0] temp_idx;
    logic state;

    integer log_file;
    integer start_time;
    integer end_time;
    logic algorithm_started;
    logic inputs_logged;
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
            state <= RECEIVE;
            algorithm_started <= 0;
            inputs_logged <= 0;
            for (int i = 0; i < 9; i++) begin
                result_matrix_o[i] <= '0;
            end
        end else begin
            // Log input matrices when they are valid
            if (inputs_valid && !inputs_logged) begin
                $fwrite(log_file, "=== INPUT SIGNALS ===\n");
                $fwrite(log_file, "Matrix A:\n");
                for (int i = 0; i < 9; i++) begin
                    $fwrite(log_file, "A[%0d] = %0d (0x%h)\n", i, input_matrix_a[i], input_matrix_a[i]);
                end
                $fwrite(log_file, "\nMatrix B:\n");
                for (int i = 0; i < 9; i++) begin
                    $fwrite(log_file, "B[%0d] = %0d (0x%h)\n", i, input_matrix_b[i], input_matrix_b[i]);
                end
                $fwrite(log_file, "\n");
                inputs_logged <= 1;
            end

            if (state == RECEIVE) begin
                if (gpio_led[14]) begin
                    // Mark algorithm start on first output
                    if (!algorithm_started) begin
                        start_time = $time;
                        algorithm_started <= 1;
                        $fwrite(log_file, "Algorithm started at time: %0t ns\n\n", start_time);
                    end

                    result_matrix_o[temp_idx] <= gpio_led[7:0];
                    temp_idx <= temp_idx + 1'b1;
                    state <= DELAY;
                end
            end else begin
                if (!gpio_led[14]) begin
                    state <= RECEIVE;
                end
            end

            // Log outputs when all results received
            if (temp_idx == 9 && algorithm_started) begin
                end_time = $time;
                $fwrite(log_file, "=== OUTPUT SIGNALS ===\n");
                for (int i = 0; i < 9; i++) begin
                    $fwrite(log_file, "Result[%0d] = %0d (0x%h)\n", i, result_matrix_o[i], result_matrix_o[i]);
                end
                $fwrite(log_file, "\n=== EXECUTION TIME ===\n");
                $fwrite(log_file, "Algorithm finished at time: %0t ns\n", end_time);
                $fwrite(log_file, "Total execution time: %0t ns\n\n", end_time - start_time);
            end
        end
    end

    assign result_valid = (temp_idx == 9) ? 1 : 0;

    final begin
        $fclose(log_file);
    end
endmodule
