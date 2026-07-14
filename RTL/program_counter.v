module program_counter (
    input             clk,
    input             reset,        // synchronous, active-high: PC -> 0
    output reg [11:0] pc            // The instruction_memory is byte-addressable, so the PC is 12 bits wide to address 4096 bytes (1024 words)
);

    // Instruction memory is word-addressed (PC counts by 4), so advancing to the next word is simply pc + 4 each clock.
    //Each instruction is 4 bytes (32 bits) wide, so the instruction memory takes the address of the first byte of the instruction.
    //After this the instruction memory will read the next 3 bytes to form the complete instruction and the PC will be incremented by 4 to point to the first address of the next instruction.
    always @(posedge clk) begin
        if (reset)
            pc <= 12'd0;
        else
            pc <= pc + 12'd4;
    end

endmodule
