// ----------------------------------------------------------------------------
// Board top-level for the DE10-Standard.
// Wraps mips_datapath and exposes ONLY signals that map to real board pins.
//
// The clock divider lives HERE (not in the datapath): the datapath is
// clock-agnostic and testbenches drive it at full speed, while the board
// build slows the CPU to 1 Hz so the HEX displays are readable.
//   cpu_clk = CLOCK_50 / (2 * DIVISOR);  25_000_000 -> 1 Hz.
// tb_mips_top overrides DIVISOR to a small value to keep simulation short.
//
// Reset note: the divider holds cpu_clk at 0 while reset is asserted; the
// PC/register file use ASYNC resets, so the CPU still initialises correctly.
// ----------------------------------------------------------------------------
module mips_top #(
    parameter DIVISOR = 25000000
)(
    input  wire        CLOCK_50,   // 50 MHz board oscillator
    input  wire [3:0]  KEY,        // push buttons, ACTIVE-LOW (pressed = 0)
    output wire [9:0]  LEDR,       // red LEDs  -> control signals
    output wire [6:0]  HEX0,       // operand A : ones
    output wire [6:0]  HEX1,       // operand A : tens
    output wire [6:0]  HEX2,       // operand B : ones
    output wire [6:0]  HEX3,       // operand B : tens
    output wire [6:0]  HEX4,       // result    : ones
    output wire [6:0]  HEX5        // result    : tens
);

    // KEY[0] is active-low; the CPU reset is active-high.
    wire reset = ~KEY[0];

    // Slow CPU clock for a human-readable demo.
    wire cpu_clk;

    ClockDivider #(.DIVISOR(DIVISOR)) ClockDivider (
        .clk_in  (CLOCK_50),
        .rst     (reset),
        .clk_out (cpu_clk)
    );

    mips_datapath CPU (
        .clk             (cpu_clk),
        .reset           (reset),

        // simulation-only observation outputs: intentionally unconnected
        .pc              (),
        .instruction     (),
        .alu_result      (),
        .write_back_data (),

        .HEX0 (HEX0), .HEX1 (HEX1),
        .HEX2 (HEX2), .HEX3 (HEX3),
        .HEX4 (HEX4), .HEX5 (HEX5),
        .LEDR (LEDR)
    );

endmodule
