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
                state <= WAIT_RESULT;
            end
        end else if (state == WAIT_RESULT) begin
            if (result_vld) state <= CHECK;
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

            $display("\n=== INPUT MATRIX A (7x7) ===");
            for (int i = 0; i < 7; i++) begin
                $display("  [%0d %0d %0d %0d %0d %0d %0d]", matrix_a[i*7+0], matrix_a[i*7+1],
                         matrix_a[i*7+2], matrix_a[i*7+3], matrix_a[i*7+4], matrix_a[i*7+5],
                         matrix_a[i*7+6]);
            end

            $display("\n=== INPUT MATRIX B (7x7) ===");
            for (int i = 0; i < 7; i++) begin
                $display("  [%0d %0d %0d %0d %0d %0d %0d]", matrix_b[i*7+0], matrix_b[i*7+1],
                         matrix_b[i*7+2], matrix_b[i*7+3], matrix_b[i*7+4], matrix_b[i*7+5],
                         matrix_b[i*7+6]);
            end

            $display("\n=== EXPECTED B*B (7x7) ===");
            for (int i = 0; i < 7; i++) begin
                $display("  [%0d %0d %0d %0d %0d %0d %0d]", bb_matrix[i*7+0], bb_matrix[i*7+1],
                         bb_matrix[i*7+2], bb_matrix[i*7+3], bb_matrix[i*7+4], bb_matrix[i*7+5],
                         bb_matrix[i*7+6]);
            end

            $display("\n=== EXPECTED RESULT: A + B*B (7x7) ===");
            for (int i = 0; i < 7; i++) begin
                $display("  [%0d %0d %0d %0d %0d %0d %0d]", expected_matrix[i*7+0],
                         expected_matrix[i*7+1], expected_matrix[i*7+2], expected_matrix[i*7+3],
                         expected_matrix[i*7+4], expected_matrix[i*7+5], expected_matrix[i*7+6]);
            end

            $display("\n=== ACTUAL RESULT FROM DUT (7x7) ===");
            for (int i = 0; i < 7; i++) begin
                $display("  [%0d %0d %0d %0d %0d %0d %0d]", result_matrix[i*7+0],
                         result_matrix[i*7+1], result_matrix[i*7+2], result_matrix[i*7+3],
                         result_matrix[i*7+4], result_matrix[i*7+5], result_matrix[i*7+6]);
            end

            $display("\n=== DETAILED COMPARISON ===");

            for (int i = 0; i < 49; i++) begin
                expected = expected_matrix[i];
                $display("[%d] expected=%0d, result=%0d", i, expected, result_matrix[i]);

                if (expected != result_matrix[i]) begin
                    $display("INCORRECT RESULT IN [%d] elem: expected=%0d, got=%0d", i, expected,
                             result_matrix[i]);
                    test_passed = 0;
                end
            end

            if (test_passed) begin
                $display("\n=== TEST RESULT: PASSED ===\n");
            end else begin
                $display("\n=== TEST RESULT: FAILED ===\n");
            end

            $finish();
        end
    end

endmodule
