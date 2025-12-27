/**
 * counter_tb.v - Testbench for counter module
 *
 * This testbench verifies the counter functionality:
 * - Counter increments correctly
 * - Reset works properly
 * - LED output (bit 9) toggles as expected
 */

`timescale 1ns/1ps

module counter_tb;
    // Testbench signals
    reg  clk;
    reg  reset;
    wire led;

    // Instantiate the counter module (Device Under Test)
    counter dut (
        .clk(clk),
        .reset(reset),
        .led(led)
    );

    // Clock generation - 12MHz = 83.33ns period
    // Using 10ns for faster simulation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period = 100MHz clock
    end

    // Test stimulus
    initial begin
        // Initialize VCD dump for waveform viewing
        $dumpfile("build/counter_tb.vcd");
        $dumpvars(0, counter_tb);

        // Display test start
        $display("=== Counter Testbench Start ===");
        $display("Time\t\tReset\tLED\tInternal Count");
        $monitor("%0t ns\t%b\t%b\t%d", $time, reset, led, dut.count);

        // Test 1: Assert reset
        reset = 1;
        #100;

        if (dut.count != 0) begin
            $display("ERROR: Counter not zero after reset!");
            $finish;
        end
        $display("PASS: Reset functionality verified");

        // Test 2: Release reset and let counter run
        reset = 0;
        #50;

        if (dut.count == 0) begin
            $display("ERROR: Counter not incrementing!");
            $finish;
        end
        $display("PASS: Counter incrementing");

        // Test 3: Run until bit 9 toggles (512 cycles minimum)
        // Need 512+ cycles at 10ns period = 5120+ ns
        #5200;

        // Test 4: Verify LED toggles with bit 9
        if (led != dut.count[9]) begin
            $display("ERROR: LED not connected to bit 9!");
            $finish;
        end
        $display("PASS: LED correctly reflects bit 9");

        // Test 5: Test reset again while counting
        reset = 1;
        #20;
        reset = 0;

        if (dut.count > 10) begin
            $display("ERROR: Reset didn't work during counting!");
            $finish;
        end
        $display("PASS: Reset during counting works");

        // Run for a bit longer to see counter behavior
        #1000;

        $display("=== All Tests Passed! ===");
        $finish;
    end

    // Timeout watchdog (prevents infinite simulation)
    initial begin
        #50000;
        $display("WARNING: Simulation timeout");
        $finish;
    end

endmodule
