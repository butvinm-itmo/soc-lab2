`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/23/2025 03:37:33 PM
// Design Name:
// Module Name: scoreboard
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

module scoreboard (
    input clk_i,
    input rst_i,

    input [15:0] matrix_input[`MATRIX_SIZE],
    input matrix_vld,

    input [15:0] result_matrix[`MATRIX_SIZE],
    input result_vld,

    output logic test_done
);

    localparam WAIT_A = 0;
    localparam WAIT_B = 1;
    localparam WAIT_RESULT = 2;
    localparam CHECK = 3;

    logic [15:0] matrix_a[`MATRIX_SIZE];
    logic [15:0] matrix_b[`MATRIX_SIZE];

    logic [1:0] state;

    integer log_file;
    integer start_time;
    integer end_time;

    integer test_count;
    integer tests_passed;
    integer tests_failed;

    initial begin
        log_file = $fopen("scoreboard_log.txt", "w");
        if (log_file == 0) begin
            $display("Error: Could not open scoreboard log file");
            $finish;
        end
    end

    function automatic logic [15:0] compute_expected(int idx);
        logic [15:0] bb_matrix[`MATRIX_SIZE];
        logic [15:0] result[`MATRIX_SIZE];
        int row, col;

        for (int i = 0; i < `MATRIX_DIM; i++) begin
            for (int j = 0; j < `MATRIX_DIM; j++) begin
                bb_matrix[i*`MATRIX_DIM+j] = 0;
                for (int k = 0; k < `MATRIX_DIM; k++) begin
                    bb_matrix[i*`MATRIX_DIM+j] = bb_matrix[i*`MATRIX_DIM+j] + (matrix_b[i*`MATRIX_DIM+k] * matrix_b[k*`MATRIX_DIM+j]);
                end
            end
        end

        for (int i = 0; i < `MATRIX_SIZE; i++) begin
            result[i] = matrix_a[i] + bb_matrix[i];
        end

        return result[idx];
    endfunction

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            state <= WAIT_A;
            test_done <= 0;
            test_count <= 0;
            tests_passed <= 0;
            tests_failed <= 0;
            for (int i = 0; i < `MATRIX_SIZE; i++) begin
                matrix_a[i] <= 0;
            end
            for (int i = 0; i < `MATRIX_SIZE; i++) begin
                matrix_b[i] <= 0;
            end
        end else if (state == WAIT_A) begin
            test_done <= 0;
            if (matrix_vld) begin
                matrix_a <= matrix_input;
                state <= WAIT_B;
            end
        end else if (state == WAIT_B) begin
            if (matrix_vld) begin
                matrix_b <= matrix_input;
                start_time = $time;
                state <= WAIT_RESULT;
            end
        end else if (state == WAIT_RESULT) begin
            if (result_vld) begin
                end_time = $time;
                state <= CHECK;
            end
        end else begin
            logic [15:0] expected;
            logic [15:0] expected_matrix[`MATRIX_SIZE];
            logic [15:0] bb_matrix[`MATRIX_SIZE];
            logic test_passed;
            test_passed = 1;
            test_count  = test_count + 1;

            for (int i = 0; i < `MATRIX_DIM; i++) begin
                for (int j = 0; j < `MATRIX_DIM; j++) begin
                    bb_matrix[i*`MATRIX_DIM+j] = 0;
                    for (int k = 0; k < `MATRIX_DIM; k++) begin
                        bb_matrix[i*`MATRIX_DIM+j] = bb_matrix[i*`MATRIX_DIM+j] + (matrix_b[i*`MATRIX_DIM+k] * matrix_b[k*`MATRIX_DIM+j]);
                    end
                end
            end

            for (int i = 0; i < `MATRIX_SIZE; i++) begin
                expected_matrix[i] = matrix_a[i] + bb_matrix[i];
            end

            $display("\nTest #%0d", test_count);
            $fwrite(log_file, "\nTest #%0d\n", test_count);

            $display("Input Matrix A:");
            $fwrite(log_file, "Input Matrix A:\n");
            for (int i = 0; i < `MATRIX_DIM; i++) begin
                $display("  [%0d %0d %0d %0d %0d %0d %0d]", matrix_a[i*`MATRIX_DIM+0],
                         matrix_a[i*`MATRIX_DIM+1], matrix_a[i*`MATRIX_DIM+2],
                         matrix_a[i*`MATRIX_DIM+3], matrix_a[i*`MATRIX_DIM+4],
                         matrix_a[i*`MATRIX_DIM+5], matrix_a[i*`MATRIX_DIM+6]);
                $fwrite(log_file, "  [%0d %0d %0d %0d %0d %0d %0d]\n", matrix_a[i*`MATRIX_DIM+0],
                        matrix_a[i*`MATRIX_DIM+1], matrix_a[i*`MATRIX_DIM+2],
                        matrix_a[i*`MATRIX_DIM+3], matrix_a[i*`MATRIX_DIM+4],
                        matrix_a[i*`MATRIX_DIM+5], matrix_a[i*`MATRIX_DIM+6]);
            end

            $display("Input Matrix B:");
            $fwrite(log_file, "Input Matrix B:\n");
            for (int i = 0; i < `MATRIX_DIM; i++) begin
                $display("  [%0d %0d %0d %0d %0d %0d %0d]", matrix_b[i*`MATRIX_DIM+0],
                         matrix_b[i*`MATRIX_DIM+1], matrix_b[i*`MATRIX_DIM+2],
                         matrix_b[i*`MATRIX_DIM+3], matrix_b[i*`MATRIX_DIM+4],
                         matrix_b[i*`MATRIX_DIM+5], matrix_b[i*`MATRIX_DIM+6]);
                $fwrite(log_file, "  [%0d %0d %0d %0d %0d %0d %0d]\n", matrix_b[i*`MATRIX_DIM+0],
                        matrix_b[i*`MATRIX_DIM+1], matrix_b[i*`MATRIX_DIM+2],
                        matrix_b[i*`MATRIX_DIM+3], matrix_b[i*`MATRIX_DIM+4],
                        matrix_b[i*`MATRIX_DIM+5], matrix_b[i*`MATRIX_DIM+6]);
            end

            $display("Expected Result:");
            $fwrite(log_file, "Expected Result:\n");
            for (int i = 0; i < `MATRIX_DIM; i++) begin
                $display("  [%0d %0d %0d %0d %0d %0d %0d]", expected_matrix[i*`MATRIX_DIM+0],
                         expected_matrix[i*`MATRIX_DIM+1], expected_matrix[i*`MATRIX_DIM+2],
                         expected_matrix[i*`MATRIX_DIM+3], expected_matrix[i*`MATRIX_DIM+4],
                         expected_matrix[i*`MATRIX_DIM+5], expected_matrix[i*`MATRIX_DIM+6]);
                $fwrite(log_file, "  [%0d %0d %0d %0d %0d %0d %0d]\n",
                        expected_matrix[i*`MATRIX_DIM+0], expected_matrix[i*`MATRIX_DIM+1],
                        expected_matrix[i*`MATRIX_DIM+2], expected_matrix[i*`MATRIX_DIM+3],
                        expected_matrix[i*`MATRIX_DIM+4], expected_matrix[i*`MATRIX_DIM+5],
                        expected_matrix[i*`MATRIX_DIM+6]);
            end

            $display("Actual Result:");
            $fwrite(log_file, "Actual Result:\n");
            for (int i = 0; i < `MATRIX_DIM; i++) begin
                $display("  [%0d %0d %0d %0d %0d %0d %0d]", result_matrix[i*`MATRIX_DIM+0],
                         result_matrix[i*`MATRIX_DIM+1], result_matrix[i*`MATRIX_DIM+2],
                         result_matrix[i*`MATRIX_DIM+3], result_matrix[i*`MATRIX_DIM+4],
                         result_matrix[i*`MATRIX_DIM+5], result_matrix[i*`MATRIX_DIM+6]);
                $fwrite(log_file, "  [%0d %0d %0d %0d %0d %0d %0d]\n",
                        result_matrix[i*`MATRIX_DIM+0], result_matrix[i*`MATRIX_DIM+1],
                        result_matrix[i*`MATRIX_DIM+2], result_matrix[i*`MATRIX_DIM+3],
                        result_matrix[i*`MATRIX_DIM+4], result_matrix[i*`MATRIX_DIM+5],
                        result_matrix[i*`MATRIX_DIM+6]);
            end

            for (int i = 0; i < `MATRIX_SIZE; i++) begin
                expected = expected_matrix[i];
                $fwrite(log_file, "[%d] expected=%0d, result=%0d", i, expected, result_matrix[i]);

                if (expected != result_matrix[i]) begin
                    $display("MISMATCH at [%d]: expected=%0d, got=%0d", i, expected,
                             result_matrix[i]);
                    $fwrite(log_file, " [MISMATCH]\n");
                    test_passed = 0;
                end else begin
                    $fwrite(log_file, "\n");
                end
            end

            if (test_passed) begin
                $display("Result: PASSED");
                $fwrite(log_file, "Result: PASSED\n");
                tests_passed = tests_passed + 1;
            end else begin
                $display("Result: FAILED");
                $fwrite(log_file, "Result: FAILED\n");
                tests_failed = tests_failed + 1;
            end

            $display("Execution time: %0t ns", end_time - start_time);
            $display("Progress: %0d/%0d\n", test_count, `TEST_RUNS);

            $fwrite(log_file, "Execution time: %0t ns\n", end_time - start_time);
            $fwrite(log_file, "Progress: %0d/%0d\n\n", test_count, `TEST_RUNS);

            // Signal test completion and return to WAIT_A for next test
            test_done <= 1;
            state <= WAIT_A;
        end
    end

    final begin
        $display("\nFINAL SUMMARY:");
        $display("Total:  %0d", test_count);
        $display("Passed: %0d", tests_passed);
        $display("Failed: %0d", tests_failed);
        $display("Rate:   %0.1f%%\n", (tests_passed * 100.0) / test_count);

        $fwrite(log_file, "\nFINAL SUMMARY:\n");
        $fwrite(log_file, "Total:  %0d\n", test_count);
        $fwrite(log_file, "Passed: %0d\n", tests_passed);
        $fwrite(log_file, "Failed: %0d\n", tests_failed);
        $fwrite(log_file, "Rate:   %0.1f%%\n", (tests_passed * 100.0) / test_count);

        $fclose(log_file);
    end

endmodule
