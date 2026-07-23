//============================================================
// MEM Stage
// Performs data memory access.
// Inputs come from the EX/MEM pipeline register.
//============================================================

module mem (

    input         clk,
    input         reset,

    // From EX/MEM pipeline register
    input  [31:0] alu_result,
    input  [31:0] store_data,

    // Control signals
    input         MemRead,
    input         MemWrite,

    // Data memory output
    output [31:0] mem_data,

    // Pass-through for MEM/WB register
    output [31:0] alu_result_out
);

    //--------------------------------------------------------
    // Data Memory
    //--------------------------------------------------------

    data_memory DMEM (
        .read_address  (alu_result),
        .write_address (alu_result),

        .memRead       (MemRead),
        .memWrite      (MemWrite),

        .clk           (clk),

        .data_in       (store_data),

        // Preserve your original reset connections
        .rst_a         (~reset),
        .rst_r         (1'b1),

        .data_out      (mem_data)
    );

    //--------------------------------------------------------
    // Forward ALU result to MEM/WB register
    //--------------------------------------------------------

    assign alu_result_out = alu_result;

endmodule