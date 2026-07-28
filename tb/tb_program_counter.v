`timescale 1ns/1ps

module tb_program_counter;

    reg         clk;
    reg         reset;
    wire [31:0] pc;

    // Device under test
    program_counter DUT (
        .clk   (clk),
        .reset (reset),
        .pc    (pc)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    integer     cycle;
    reg  [31:0] prev_pc;

    initial begin
        clk   = 0;
        reset = 1;

        // Hold reset across one rising edge -> PC should land on 0
        @(posedge clk);
        #1 reset = 0;
        prev_pc = pc;
        $display("After reset : pc = %0d", pc);

        // Watch the next 5 rising edges and check the step size
        for (cycle = 0; cycle < 5; cycle = cycle + 1) begin
            @(posedge clk);
            #1;
            $display("cycle %0d    : pc = %0d   (step = +%0d)",
                     cycle, pc, pc - prev_pc);
            if (pc - prev_pc !== 32'd1)
                $display("  >> UNEXPECTED: step was %0d, expected +1", pc - prev_pc);
            prev_pc = pc;
        end

        $display("\nInterpretation:");
        $display("  step = +1  -> word-addressed memory, +1 index = next 32-bit word (correct here)");
        $display("  step = +4  -> byte-addressed memory (real MIPS), would skip 3 words here");

        $finish;
    end

endmodule
