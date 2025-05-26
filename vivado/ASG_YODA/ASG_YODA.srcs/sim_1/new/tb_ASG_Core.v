`timescale 1ns / 1ps

module tb_ASG_Core();

    // DUT Parameters
    parameter CLK_PERIOD = 10; // 100MHz clock

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

    // Q8.8 to real conversion
    function real q8_to_real;
        input [15:0] qval;
        begin
            q8_to_real = $signed(qval) / 256.0;
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

            // Verify
            $display("Test: a1=%.2f, d=%.2f, n=%0d", 
                    q8_to_real(a1), q8_to_real(d), n);
            $display("Last term: %.4f (Expected: %.4f)", 
                    q8_to_real(term_out), expected_last);
            if ($abs(q8_to_real(term_out) - expected_last) < 0.01)
                $display("PASS");
            else
                $display("FAIL");
            $display("------------------");
            #200;
        end
    endtask

    initial begin
        // Initialize
        $display("Starting ASG_Core Testbench");
        clk = 0;
        reset_n = 0;
        activate = 0;
        a1 = 0;
        d = 0;
        n = 0;
        
        // Reset
        #100;
        reset_n = 1;
        #100;

        // ===== Test Cases =====
        // Basic positive sequence (1.0 + 0.5*3 = 2.5)
        run_test(16'h0100, 16'h0080, 8'd4, 2.5);
        
        // Small steps (0.5 + 0.25*3 = 1.25)
        run_test(16'h0080, 16'h0040, 8'd4, 1.25);
        
        // Negative difference (4.0 + (-1.0)*3 = 1.0)
        run_test(16'h0400, 16'hFF00, 8'd4, 1.0);
        
        // Large numbers (100.0 + 10.0*2 = 120.0)
        run_test(16'h6400, 16'h0A00, 8'd3, 120.0);
        
        // Single term (n=1)
        run_test(16'h0280, 16'h0028, 8'd1, 2.5);
        
        // Precision test (1.0 + 0.00390625*3 ≈ 1.0117)
        run_test(16'h0100, 16'h0001, 8'd4, 1.01171875);
        
        // Negative start (-3.0 + 1.5*3 = 1.5)
        run_test(16'hFD00, 16'h0180, 8'd4, 1.5);
        
        // Max terms (n=255)
        run_test(16'h0000, 16'h0001, 8'd255, 0.99609375);

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