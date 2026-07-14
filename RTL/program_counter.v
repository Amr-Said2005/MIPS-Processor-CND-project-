module program_counter (
    input             clk,
    input             reset,        // synchronous, active-high: PC -> 0
    output reg [11:0] pc            // word address (feeds instruction_memory)
);

    // Instruction memory is word-addressed (PC counts by 1), so advancing
    // to the next word is simply pc + 1 each clock.
    always @(posedge clk) begin
        if (reset)
            pc <= 12'd0;
        else
            pc <= pc + 12'd4;
    end

endmodule
