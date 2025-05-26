`timescale 1ns / 1ps

module ASG_Core(
    input wire clk,          // 100MHz clock
    input wire reset_n,      // Active-low reset
    input wire activate,     // Start generation
    input wire [15:0] a1,    // First term (Q8.8 fixed-point)
    input wire [15:0] d,     // Common difference (Q8.8)
    input wire [7:0] n,      // Number of terms (1-255)
    output reg done,         // Generation complete
    output reg [15:0] term_out // Current term (Q8.8)
);

    // FSM States
    localparam IDLE = 2'b00;
    localparam CALC = 2'b01;
    localparam DONE_ST = 2'b10;

    reg [1:0] state;
    reg [7:0] counter;
    reg [15:0] current_term;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            counter <= 0;
            done <= 0;
            current_term <= 0;
            term_out <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (activate) begin
                        current_term <= a1;
                        counter <= 1;
                        state <= CALC;
                    end
                end

                CALC: begin
                    term_out <= current_term;
                    if (counter < n) begin
                        current_term <= current_term + d;
                        counter <= counter + 1;
                    end
                    else begin
                        state <= DONE_ST;
                    end
                end

                DONE_ST: begin
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule