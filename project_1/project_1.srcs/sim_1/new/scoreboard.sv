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


module scoreboard (
    input clk_i,
    input rst_i,

    input [15:0] matrix_input[49],
    input matrix_vld,

    input [15:0] result_matrix[49],
    input result_vld
);

    localparam WAIT_A = 0;
    localparam WAIT_B = 1;
    localparam WAIT_RESULT = 2;
    localparam CHECK = 3;

    logic [15:0] matrix_a[49];
    logic [15:0] matrix_b[49];

    logic [ 1:0] state;

    integer log_file;
    integer start_time;
    integer end_time;

    initial begin
        log_file = $fopen("scoreboard_log.txt", "w");
        if (log_file == 0) begin
            $display("Error: Could not open scoreboard log file");
            $finish;
        end
    end

    function automatic logic [15:0] compute_expected(int idx);
        logic [15:0] bb_matrix[49];
        logic [15:0] result[49];
        int row, col;

        for (int i = 0; i < 7; i++) begin
            for (int j = 0; j < 7; j++) begin
                bb_matrix[i*7+j] = 0;
                for (int k = 0; k < 7; k++) begin
                    bb_matrix[i*7+j] = bb_matrix[i*7+j] + (matrix_b[i*7+k] * matrix_b[k*7+j]);
                end
            end
        end

        for (int i = 0; i < 49; i++) begin
            result[i] = matrix_a[i] + bb_matrix[i];
        end

        return result[idx];
    endfunction

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            state <= WAIT_A;
            for (int i = 0; i < 49; i++) begin
                matrix_a[i] <= 0;
            end
            for (int i = 0; i < 49; i++) begin
                matrix_b[i] <= 0;
            end
        end else if (state == WAIT_A) begin
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
            logic [15:0] expected_matrix[49];
            logic [15:0] bb_matrix[49];
            logic test_passed;
            test_passed = 1;

            for (int i = 0; i < 7; i++) begin
                for (int j = 0; j < 7; j++) begin
                    bb_matrix[i*7+j] = 0;
                    for (int k = 0; k < 7; k++) begin
                        bb_matrix[i*7+j] = bb_matrix[i*7+j] + (matrix_b[i*7+k] * matrix_b[k*7+j]);
                    end
                end
            end

            for (int i = 0; i < 49; i++) begin
                expected_matrix[i] = matrix_a[i] + bb_matrix[i];
            end

            $display("\nInput Matrix A (7x7):");
            $fwrite(log_file, "\nInput Matrix A (7x7):\n");
            for (int i = 0; i < 7; i++) begin
                $display("  [%0d %0d %0d %0d %0d %0d %0d]", matrix_a[i*7+0], matrix_a[i*7+1],
                         matrix_a[i*7+2], matrix_a[i*7+3], matrix_a[i*7+4], matrix_a[i*7+5],
                         matrix_a[i*7+6]);
                $fwrite(log_file, "  [%0d %0d %0d %0d %0d %0d %0d]\n", matrix_a[i*7+0], matrix_a[i*7+1],
                         matrix_a[i*7+2], matrix_a[i*7+3], matrix_a[i*7+4], matrix_a[i*7+5],
                         matrix_a[i*7+6]);
            end

            $display("\nInput Matrix B (7x7):");
            $fwrite(log_file, "\nInput Matrix B (7x7):\n");
            for (int i = 0; i < 7; i++) begin
                $display("  [%0d %0d %0d %0d %0d %0d %0d]", matrix_b[i*7+0], matrix_b[i*7+1],
                         matrix_b[i*7+2], matrix_b[i*7+3], matrix_b[i*7+4], matrix_b[i*7+5],
                         matrix_b[i*7+6]);
                $fwrite(log_file, "  [%0d %0d %0d %0d %0d %0d %0d]\n", matrix_b[i*7+0], matrix_b[i*7+1],
                         matrix_b[i*7+2], matrix_b[i*7+3], matrix_b[i*7+4], matrix_b[i*7+5],
                         matrix_b[i*7+6]);
            end

            $display("\nExpected Result: A + B*B (7x7):");
            $fwrite(log_file, "\nExpected Result: A + B*B (7x7):\n");
            for (int i = 0; i < 7; i++) begin
                $display("  [%0d %0d %0d %0d %0d %0d %0d]", expected_matrix[i*7+0],
                         expected_matrix[i*7+1], expected_matrix[i*7+2], expected_matrix[i*7+3],
                         expected_matrix[i*7+4], expected_matrix[i*7+5], expected_matrix[i*7+6]);
                $fwrite(log_file, "  [%0d %0d %0d %0d %0d %0d %0d]\n", expected_matrix[i*7+0],
                         expected_matrix[i*7+1], expected_matrix[i*7+2], expected_matrix[i*7+3],
                         expected_matrix[i*7+4], expected_matrix[i*7+5], expected_matrix[i*7+6]);
            end

            $display("\nActual Result From DUT (7x7):");
            $fwrite(log_file, "\nActual Result From DUT (7x7):\n");
            for (int i = 0; i < 7; i++) begin
                $display("  [%0d %0d %0d %0d %0d %0d %0d]", result_matrix[i*7+0],
                         result_matrix[i*7+1], result_matrix[i*7+2], result_matrix[i*7+3],
                         result_matrix[i*7+4], result_matrix[i*7+5], result_matrix[i*7+6]);
                $fwrite(log_file, "  [%0d %0d %0d %0d %0d %0d %0d]\n", result_matrix[i*7+0],
                         result_matrix[i*7+1], result_matrix[i*7+2], result_matrix[i*7+3],
                         result_matrix[i*7+4], result_matrix[i*7+5], result_matrix[i*7+6]);
            end

            $display("\nDetailed Comparison:");
            $fwrite(log_file, "\nDetailed Comparison:\n");

            for (int i = 0; i < 49; i++) begin
                expected = expected_matrix[i];
                $display("[%d] expected=%0d, result=%0d", i, expected, result_matrix[i]);
                $fwrite(log_file, "[%d] expected=%0d, result=%0d", i, expected, result_matrix[i]);

                if (expected != result_matrix[i]) begin
                    $display("Incorrect Result in [%d] elem: expected=%0d, got=%0d", i, expected,
                             result_matrix[i]);
                    $fwrite(log_file, " [MISMATCH]\n");
                    test_passed = 0;
                end else begin
                    $fwrite(log_file, "\n");
                end
            end

            if (test_passed) begin
                $display("\nTest Result: Passed\n");
                $fwrite(log_file, "\nTest Result: Passed\n\n");
            end else begin
                $display("\nTest Result: Failed\n");
                $fwrite(log_file, "\nTest Result: Failed\n\n");
            end

            $display("Algorithm started at:  %0t ns", start_time);
            $display("Algorithm finished at: %0t ns", end_time);
            $display("Total execution time:  %0t ns\n", end_time - start_time);

            $fwrite(log_file, "Algorithm started at:  %0t ns\n", start_time);
            $fwrite(log_file, "Algorithm finished at: %0t ns\n", end_time);
            $fwrite(log_file, "Total execution time:  %0t ns\n\n", end_time - start_time);

            $finish();
        end
    end

    final begin
        $fclose(log_file);
    end

endmodule
