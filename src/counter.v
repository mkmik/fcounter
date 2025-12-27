/**
 * counter.v - Simple binary counter for ice40-up5k FPGA
 *
 * This module implements a simple binary counter that:
 * - Increments on every clock cycle
 * - Can be reset to zero with a reset button
 * - Outputs bit 9 (10th bit) to drive an LED
 *
 * The counter is 32 bits wide, providing plenty of room for counting.
 * Bit 9 will toggle approximately every 512 clock cycles.
 */

module counter (
    input  wire clk,        // Clock input (typically 12MHz on ice40-up5k boards)
    input  wire reset,      // Reset button (active high)
    output wire led         // LED output (driven by bit 9 of counter)
);

    // 32-bit counter register
    reg [31:0] count;

    // Counter logic
    always @(posedge clk) begin
        if (reset) begin
            // Reset counter to zero when reset button is pressed
            count <= 32'b0;
        end else begin
            // Increment counter on every clock cycle
            count <= count + 1;
        end
    end

    // Connect bit 9 (10th bit, zero-indexed) to LED output
    // This bit toggles every 2^9 = 512 clock cycles
    // At 12MHz, this is approximately 23kHz, which will appear as "always on"
    // to the human eye but can be verified with a scope
    assign led = count[9];

endmodule
