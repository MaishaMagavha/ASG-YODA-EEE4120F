`timescale 1ns / 1ps

module tb_ASG_Core();

    // DUT Parameters
    parameter CLK_PERIOD = 10; // 100MHz clock (10ns period)

    // DUT Signals
    reg clk;
    reg reset_n;
    reg activate;
    reg [15:0] a1;
    reg [15:0] d;
    reg [7:0] n;
    wire done;
    wire [15:0] term_out;

    // Instantiate DUT
    ASG_Core uut (
        .clk(clk),
        .reset_n(reset_n),
        .activate(activate),
        .a1(a1),
        .d(d),
        .n(n),
        .done(done),
        .term_out(term_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Q8.8 to real conversion function
    function real q8_to_real;
        input [15:0] qval;
        begin
            q8_to_real = $signed(qval) / 256.0;
        end
    endfunction

    // Absolute value for real numbers
    function real abs_real;
        input real val;
        begin
            abs_real = (val < 0.0) ? -val : val;
        end
    endfunction

    // Test task
    task run_test;
        input [15:0] a1_val;
        input [15:0] d_val;
        input [7:0] n_val;
        input real expected_last;
        begin
            // Load parameters
            a1 = a1_val;
            d = d_val;
            n = n_val;
            
            // Pulse activate
            activate = 0;
            #100;
            activate = 1;
            #20;
            activate = 0;

            // Wait for completion
            wait(done);
            #50;

            // Verify results
            $display("Test: a1=%.2f, d=%.2f, n=%0d", 
                    q8_to_real(a1), q8_to_real(d), n);
            $display("Last term: %.4f (Expected: %.4f)", 
                    q8_to_real(term_out), expected_last);
            if (abs_real(q8_to_real(term_out) - expected_last) < 0.01)
                $display("PASS");
            else
                $display("FAIL");
            $display("------------------");
            #200;
        end
    endtask

    // Main test sequence
    initial begin
        // Initialize
        $display("Starting ASG_Core Testbench");
        reset_n = 0;
        activate = 0;
        a1 = 0;
        d = 0;
        n = 0;
        
        // Reset sequence
        #100;
        reset_n = 1;
        #100;

        // ===== Test Cases =====
        run_test(16'h0100, 16'h0080, 8'd4, 2.5);
        run_test(16'h0080, 16'h0040, 8'd4, 1.25);
        run_test(16'h0400, 16'hFF00, 8'd4, 1.0);
        run_test(16'h6400, 16'h0A00, 8'd3, 120.0);
        run_test(16'h0280, 16'h0028, 8'd1, 2.5);
        run_test(16'h0100, 16'h0001, 8'd4, 1.01171875);
        run_test(16'hFD00, 16'h0180, 8'd4, 1.5);
        run_test(16'h0000, 16'h0001, 8'd255, 0.99609375);

        // Completion
        $display("\nAll tests completed");
        $finish;
    end

    // Waveform monitoring
    initial begin
        $timeformat(-9, 3, "ns", 6);
        $monitor("At %t: state=%d term_out=0x%h (%.2f)", 
                $time, uut.state, term_out, q8_to_real(term_out));
    end
endmodule
