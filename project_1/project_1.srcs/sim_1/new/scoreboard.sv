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


module scoreboard(
    input clk_i,
    input rst_i,

    input [15:0] matrix_input[9],
    input matrix_vld,

    input[15:0] result_matrix[9],
    input result_vld
);

    localparam WAIT_A = 0;
    localparam WAIT_B = 1;
    localparam WAIT_RESULT = 2;
    localparam CHECK = 3;

    logic [15:0] matrix_a [9];
    logic [15:0] matrix_b [9];

    logic [1:0] state;

    // Function to compute matrix multiplication B*B and then A + B*B
    function automatic logic [15:0] compute_expected(int idx);
        logic [15:0] bb_matrix[9];
        logic [15:0] result[9];
        int row, col;

        // Compute B*B (3x3 matrix multiplication)
        for (int i = 0; i < 3; i++) begin
            for (int j = 0; j < 3; j++) begin
                bb_matrix[i*3 + j] = 0;
                for (int k = 0; k < 3; k++) begin
                    bb_matrix[i*3 + j] = bb_matrix[i*3 + j] +
                                         (matrix_b[i*3 + k] * matrix_b[k*3 + j]);
                end
            end
        end

        // Compute A + B*B
        for (int i = 0; i < 9; i++) begin
            result[i] = matrix_a[i] + bb_matrix[i];
        end

        return result[idx];
    endfunction

    always_ff @( posedge clk_i) begin
        if (rst_i) begin
            state <= WAIT_A;
            for (int i = 0; i < 9; i++) begin
                matrix_a[i] <=0;
            end
            for (int i = 0; i < 9; i++) begin
                matrix_b[i] <=0;
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
            logic [15:0] expected_matrix[9];
            logic [15:0] bb_matrix[9];
            logic test_passed;
            test_passed = 1;

            // Compute B*B matrix
            for (int i = 0; i < 3; i++) begin
                for (int j = 0; j < 3; j++) begin
                    bb_matrix[i*3 + j] = 0;
                    for (int k = 0; k < 3; k++) begin
                        bb_matrix[i*3 + j] = bb_matrix[i*3 + j] +
                                             (matrix_b[i*3 + k] * matrix_b[k*3 + j]);
                    end
                end
            end

            // Compute expected result (A + B*B)
            for (int i = 0; i < 9; i++) begin
                expected_matrix[i] = matrix_a[i] + bb_matrix[i];
            end

            // Display Matrix A
            $display("\n=== INPUT MATRIX A (3x3) ===");
            for (int i = 0; i < 3; i++) begin
                $display("  [%0d %0d %0d]",
                    matrix_a[i*3 + 0], matrix_a[i*3 + 1], matrix_a[i*3 + 2]);
            end

            // Display Matrix B
            $display("\n=== INPUT MATRIX B (3x3) ===");
            for (int i = 0; i < 3; i++) begin
                $display("  [%0d %0d %0d]",
                    matrix_b[i*3 + 0], matrix_b[i*3 + 1], matrix_b[i*3 + 2]);
            end

            // Display B*B
            $display("\n=== EXPECTED B*B (3x3) ===");
            for (int i = 0; i < 3; i++) begin
                $display("  [%0d %0d %0d]",
                    bb_matrix[i*3 + 0], bb_matrix[i*3 + 1], bb_matrix[i*3 + 2]);
            end

            // Display Expected Result (A + B*B)
            $display("\n=== EXPECTED RESULT: A + B*B (3x3) ===");
            for (int i = 0; i < 3; i++) begin
                $display("  [%0d %0d %0d]",
                    expected_matrix[i*3 + 0], expected_matrix[i*3 + 1], expected_matrix[i*3 + 2]);
            end

            // Display Actual Result from DUT
            $display("\n=== ACTUAL RESULT FROM DUT (3x3) ===");
            for (int i = 0; i < 3; i++) begin
                $display("  [%0d %0d %0d]",
                    result_matrix[i*3 + 0], result_matrix[i*3 + 1], result_matrix[i*3 + 2]);
            end

            $display("\n=== DETAILED COMPARISON ===");

            for (int i = 0; i < 9; i++) begin
                expected = expected_matrix[i];
                $display("[%d] expected=%0d, result=%0d", i, expected, result_matrix[i]);

                if (expected != result_matrix[i]) begin
                    $display("INCORRECT RESULT IN [%d] elem: expected=%0d, got=%0d",
                            i, expected, result_matrix[i]);
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
