module program_counter (
    input             clk,
    input             reset,        // synchronous, active-high: PC -> 0
    output reg [31:0] pc            // word address (feeds instruction_memory)
);

    // Instruction memory is word-addressed (PC counts by 1), so advancing
    // to the next word is simply pc + 1 each clock.
    always @(posedge clk) begin
        if (reset)
            pc <= 32'd0;
        else
            pc <= pc + 32'd1;
    end

endmodule
