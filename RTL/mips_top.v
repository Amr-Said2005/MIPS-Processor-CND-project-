// ----------------------------------------------------------------------------
// Board top-level for the DE10-Standard.
// Wraps mips_datapath and exposes ONLY signals that map to real board pins.
// The datapath's 32-bit observation outputs (pc/instruction/alu_result/
// write_back_data) are left unconnected here -- they exist for simulation.
// ----------------------------------------------------------------------------
module mips_top (
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

    // DIVISOR = 25_000_000 -> 50MHz / (2*25e6) = 1 Hz (one instruction/second)
    mips_datapath #(.DIVISOR(25000000)) CPU (
        .clk_in          (CLOCK_50),
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
