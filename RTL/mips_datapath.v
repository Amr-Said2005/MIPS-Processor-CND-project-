// Done by Ibrahim Marzouk and Ziad El-Rayes
module mips_datapath (
    input         clk,
    input         reset,

    // --- Write-back controls (not yet generated: no ALU/control unit yet) ---
    // For now these are driven from outside so the wiring can be tested.
    // Later they come from the control unit, ALU, and RegDst/MemToReg muxes.
    input         reg_write,      // RegWrite control signal
    input  [4:0]  write_reg,      // destination register (RegDst mux output)
    input  [31:0] write_data,     // data to write back (MemToReg mux output)

    // --- Observation outputs (handy for the testbench) ---
    output [31:0] pc,             // current program counter (word address)
    output [31:0] instruction,    // fetched instruction
    output [31:0] read_data_1,    // rs operand
    output [31:0] read_data_2     // rt operand
);

    // ---------------------------------------------------------------
    // Program counter: advances to the next word each clock
    // ---------------------------------------------------------------
    program_counter PC (
        .clk   (clk),
        .reset (reset),
        .pc    (pc)
    );

    // ---------------------------------------------------------------
    // Instruction memory: word-addressed by the PC
    // ---------------------------------------------------------------
    instruction_memory IMEM (
        .read_address (pc),
        .instruction  (instruction)
    );

    // ---------------------------------------------------------------
    // Instruction field decode (R-type / I-type layout)
    //   [31:26] opcode   [25:21] rs   [20:16] rt   [15:11] rd
    // ---------------------------------------------------------------
    wire [4:0] rs = instruction[25:21];
    wire [4:0] rt = instruction[20:16];
    wire [4:0] rd = instruction[16:12];

    // ---------------------------------------------------------------
    // Register file: reads rs/rt, writes back under external control
    // ---------------------------------------------------------------
    register_file RF (
        .clk         (clk),
        .reset       (reset),
        .reg_write   (reg_write),
        .read_reg_1  (rs),
        .read_reg_2  (rt),
        .write_reg   (write_reg),
        .write_data  (write_data),
        .read_data_1 (read_data_1),
        .read_data_2 (read_data_2)
    );
    SevenSegDecoder hex0 (.bin(pc),           .seg(HEX0)); 
    SevenSegDecoder hex1 (.bin(rs),           .seg(HEX1)); 
    SevenSegDecoder hex2 (.bin(rt),           .seg(HEX2)); 
    SevenSegDecoder hex3 (.bin(rd),           .seg(HEX3); 

endmodule
