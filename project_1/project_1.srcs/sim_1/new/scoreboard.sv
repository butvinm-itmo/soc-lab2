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
                matrix_a <= matrix_input;
                state <= WAIT_RESULT;
            end
        end else if (state == WAIT_RESULT) begin
            if (result_vld) state <= CHECK;
        end else begin
            for (int i = 0; i < 9; i++) begin
                if (matrix_a[i] + matrix_b[i] != result_matrix[i]) begin
                    $display("INCORRECT RESULT IN [%d] elem", i);
                    $finish();
                end
            end
            $display("RESULT CORRECT!!!");
            $finish();
        end
    end
    
endmodule
