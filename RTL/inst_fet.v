module inst_fet(

    input clk,
    input reset,

    // Feedback from later pipeline stages
    input        PCSrc,
    input [31:0] next_pc,

    output [31:0] pc,
    output [31:0] pc_plus4,
    output [31:0] instruction

);

program_counter PC(

    .clk(clk),
    .reset(reset),
    .pc_src(PCSrc),
    .branch_target(next_pc),
    .pc(pc),
    .pc_plus4(pc_plus4)

);

instruction_memory IMEM(

    .pc(pc),
    .instruction(instruction)

);

endmodule