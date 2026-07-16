module program_counter (
    input             clk,
    input             reset,          // ASYNC, active-high: PC -> 0
    input             pc_src,         // 1 = take branch/jump target, 0 = pc + 4
    input      [31:0] branch_target,  // taken-branch / jump destination
    output reg [31:0] pc,             // byte address; instructions are 4 bytes apart
    output     [31:0] pc_plus4        // pc + 4, also feeds the branch adder
);

    // +4 adder lives here; instructions are 4 bytes apart (byte-addressed).
    assign pc_plus4 = pc + 32'd4;

    // Next-PC select: sequential by default, branch/jump target when pc_src.
    // Reset is ASYNC: the divided CPU clock is stopped while reset is held,
    // so a synchronous reset would never see an edge.
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'd0;
        else if (pc_src)
            pc <= branch_target;
        else
            pc <= pc_plus4;
    end

endmodule
