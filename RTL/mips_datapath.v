// Done by Ibrahim Marzouk and Ziad El-Rayes
module mips_datapath (
    input wire clk,
    input wire reset,

    // --- Write-back controls (not yet generated: no ALU/control unit yet) ---
    // For now these are driven from outside so the wiring can be tested.
    // Later they come from the control unit, ALU, and RegDst/MemToReg muxes.
    input wire reg_write,      // RegWrite control signal
    input wire [4:0]  write_reg,      // destination register (RegDst mux output)
    input wire [31:0] write_data,     // data to write back (MemToReg mux output)
    input wire [5:0]  alu_ctrl,
    input wire RegDst,     // Controls Write Register MUX
    input wire RegWrite,   // Enables writing to Register File
    input wire ALUSrc,     // Controls ALU B-operand MUX
    input wire [1:0] ALUOp,// Goes to ALU Control
    input wire MemWrite,   // Enables writing to Data Memory
    input wire MemRead,    // Enables reading from Data Memory
    input wire MemtoReg,   // Controls Write Data MUX
    input wire PCSrc,      // Controls Next PC MUX
    input  wire [5:0] opcode,
    input  wire [5:0] funct,    // 4-bit — from instruction[3:0]
    output reg [31:0] data_out,

    // --- Observation outputs (handy for the testbench) ---
    output wire [31:0] pc,             // current program counter (word address)
    output wire [31:0] instruction,    // fetched instruction
    output wire [31:0] read_data_1,    // rs operand
    output wire [31:0] read_data_2,     // rt operand
    output wire Zero,
    output reg  CarryOut,   // Carry output for add/sub
    output reg  Overflow,   // Signed overflow flag
    output wire Negative,   // MSB of Result
    output reg  Branch,
    output reg  Jump,
    output reg  pmc,
    output reg  JMN,
    output reg  swi_inc,
    output reg  Extd
);
    control_unit CU(
        .opcode(opcode),
        .zero(Zero),
        .RegDst(RegDst),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .ALUop(ALUOp),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .Branch(Branch),
        .JMN(JMN),
        .Jump(Jump),
        .pmc(pmc),
        .swi_inc(swi_inc),
        .Extd(Extd),
        .PCSrc(PCSrc)  
    );

    // ---------------------------------------------------------------
    // Program counter: advances to the next word each clock
    // ---------------------------------------------------------------
    program_counter PC (
        .clk   (clk),
        .reset (reset),
        .pc    (pc)
    );
    alu_control ACU(
        .ALUop(ALUOp)
        .funct(funct)
        .alu_ctrl(alu_ctrl)
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
    ALU ALU_one (
        .A(read_data_1),
        .B(read_data_2),
        .alu_ctrl(alu_ctrl),
        .Result(write_data),
        .Zero(zero),
        .CarryOut(CarryOut),
        .Overflow(Overflow),
        .Negative(Negative)
    );
    
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
    data_memory DM (
        .address(write_data), 
        .memRead(MemRead),
        .memWrite(MemWrite),
        .clk(clk),
        .data_in(read_data_2),
        .rst_a(~reset),
        .rst_r(1'b1),
        .data_out(data_out)
    );
    wire [2:0] rs1;
    wire [1:0] rs2;
    wire [3:0] rt1;
    wire [1:0] rt2;
    wire [3:0] rd1;
    wire [1:0] rd2;
    assign rs1 = rs[2:0];
    assign rs2 = rs[4:3];
    assign rt1 = rt[2:0];
    assign rt2 = rt[4:3];
    assign rd1 = rd[2:0];
    assign rd2 = rd[4:3];
    SevenSegDecoder hex0 (.bin(rs1),           .seg(HEX0)); 
    SevenSegDecoder hex1 (.bin(rs2),           .seg(HEX1)); 
    SevenSegDecoder hex2 (.bin(rt1),           .seg(HEX2)); 
    SevenSegDecoder hex3 (.bin(rt2),           .seg(HEX3)); 
    SevenSegDecoder hex4 (.bin(rd1),           .seg(HEX4)); 
    SevenSegDecoder hex5 (.bin(rd2),           .seg(HEX5)); 

endmodule
