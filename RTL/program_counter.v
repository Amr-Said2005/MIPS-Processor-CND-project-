module program_counter (
    input             clk,
    input             reset,      // synchronous, active-high: PC -> 0
    input      [31:0] pc_next,    // from the PCSrc mux (pc+4 or branch target)
    output reg [31:0] pc          // byte address; instructions are 4 bytes apart
);

    // Plain PC register. The +4 adder and the branch mux live in the datapath,
    // matching the single-cycle MIPS diagram.
    always @(posedge clk) begin
        if (reset)
            pc <= 32'd0;
        else
            pc <= pc_next;
    end

endmodule
