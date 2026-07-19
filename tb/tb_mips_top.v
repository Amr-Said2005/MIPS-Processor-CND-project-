`timescale 1ns/1ps
//
// Board-level testbench for mips_top -- the FPGA cross-reference bench.
//
// Drives ONLY the real board inputs (CLOCK_50, KEY) and observes ONLY the real
// board outputs (HEX0-5, LEDR), so every line of the printed "board view" is
// exactly what the DE10-Standard shows during that step. One step here = one
// second on the board (DIVISOR=25M in hardware; overridden small in sim).
//
// Cross-referencing a waveform with the board:
//   * open tb_mips_top.vcd and put markers on rising edges of DUT.cpu_clk --
//     each edge is one board "step" (one instruction);
//   * the [internal pc] column ties each step to the instruction address; the
//     HEX/LEDR columns are the pin values to compare against the physical board.
//
// Run (from RTL/):  iverilog -s tb_mips_top -o top.vvp ../tb/tb_mips_top.v *.v *.V
//                   vvp top.vvp
//
module tb_mips_top;

    // Small DIVISOR so simulation is short; the structure (divider included)
    // is identical to hardware. cpu_clk = CLOCK_50 / (2*DIVISOR) = /4 here.
    localparam SIM_DIVISOR = 2;

    reg         CLOCK_50;
    reg  [3:0]  KEY;
    wire [9:0]  LEDR;
    wire [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    mips_top #(.DIVISOR(SIM_DIVISOR)) DUT (
        .CLOCK_50 (CLOCK_50),
        .KEY      (KEY),
        .LEDR     (LEDR),
        .HEX0 (HEX0), .HEX1 (HEX1),
        .HEX2 (HEX2), .HEX3 (HEX3),
        .HEX4 (HEX4), .HEX5 (HEX5)
    );

    // 50 MHz -> 20 ns period
    always #10 CLOCK_50 = ~CLOCK_50;

    // 7-seg pattern -> displayed character (active-low segments)
    function [7:0] seg_char;
        input [6:0] s;
        case (s)
            7'b1000000: seg_char = "0";  7'b1111001: seg_char = "1";
            7'b0100100: seg_char = "2";  7'b0110000: seg_char = "3";
            7'b0011001: seg_char = "4";  7'b0010010: seg_char = "5";
            7'b0000010: seg_char = "6";  7'b1111000: seg_char = "7";
            7'b0000000: seg_char = "8";  7'b0010000: seg_char = "9";
            default:    seg_char = "?";
        endcase
    endfunction

    integer step, pass, fail;

    task chk;
        input [151:0] name;
        input [31:0]  got, exp;
        begin
            if (got === exp) pass = pass + 1;
            else begin
                fail = fail + 1;
                $display("  FAIL %-22s = %b (expected %b)", name, got, exp);
            end
        end
    endtask

    initial begin
        $dumpfile("tb_mips_top.vcd");
        $dumpvars(0, tb_mips_top);

        CLOCK_50 = 0;
        KEY      = 4'b1111;          // no buttons pressed
        pass = 0; fail = 0;

        // press KEY[0] (active-low) to reset, hold briefly, release
        KEY[0] = 1'b0;
        #100;
        KEY[0] = 1'b1;

        $display("");
        $display("================== BOARD VIEW (one line = one board step/second) ==================");
        $display("step | HEX5..HEX0 as seen | LEDR[9:0]  | [internal pc]");
        $display("-----+--------------------+------------+--------------");

        for (step = 0; step < 30; step = step + 1) begin
            @(posedge DUT.cpu_clk);   // one board step: waveform marker goes here
            #1;
            $display(" %2d  |  %s%s  %s%s  %s%s        | %b | %0d",
                     step,
                     seg_char(HEX5), seg_char(HEX4),   // result
                     seg_char(HEX3), seg_char(HEX2),   // operand B
                     seg_char(HEX1), seg_char(HEX0),   // operand A
                     LEDR,
                     DUT.CPU.pc);
        end

        // ---- self-check the frozen halt state (what the board settles on) ----
        // halt = beq $9,$9,-1 : displays "00 08 08", LEDR = ALUop=10,Zero,Branch
        $display("");
        chk("HEX5 (result tens=0)",  HEX5, 7'b1000000);
        chk("HEX4 (result ones=0)",  HEX4, 7'b1000000);
        chk("HEX3 (op B tens=0)",    HEX3, 7'b1000000);
        chk("HEX2 (op B ones=8)",    HEX2, 7'b0000000);
        chk("HEX1 (op A tens=0)",    HEX1, 7'b1000000);
        chk("HEX0 (op A ones=8)",    HEX0, 7'b0000000);
        chk("LEDR at halt",          LEDR, 10'b1011000000);

        $display("%0d passed, %0d failed", pass, fail);
        $display("Board settles on:  00  08  08   (result=0, B=8, A=8: the halt beq $9,$9)");
        $finish;
    end

endmodule
