// Single-cycle MIPS datapath (byte-addressed: PC+4, branch offset shifted left 2)
//
// DIVISOR sets the CPU clock: cpu_clk = clk_in / (2 * DIVISOR).
//   hardware   : 25_000_000 -> 50 MHz / 50e6 = 1 Hz (readable on the HEX displays)
//   simulation : override to 1 so the CPU runs at clk_in speed
//                e.g. mips_datapath #(.DIVISOR(1)) DUT (...);
module mips_datapath #(
    parameter DIVISOR = 25000000
)(
    input         clk_in,
    input         reset,

    // observation outputs
    output [31:0] pc,
    output [31:0] instruction,
    output [31:0] alu_result,
    output [31:0] write_back_data,

    // hex displays: operand A, operand B, ALU result (2 decimal digits each)
    output [6:0]  HEX0, HEX1,     // operand A : ones, tens
    output [6:0]  HEX2, HEX3,     // operand B : ones, tens
    output [6:0]  HEX4, HEX5,     // result    : ones, tens

    // red LEDs: live view of the control signals
    output [9:0]  LEDR
);

    // instruction fields
    wire [5:0]  opcode = instruction[31:26];
    wire [4:0]  rs     = instruction[25:21];
    wire [4:0]  rt     = instruction[20:16];
    wire [4:0]  rd     = instruction[15:11];
    wire [15:0] imm    = instruction[15:0];
    wire [5:0]  funct  = instruction[5:0];

    // control signals
    wire        RegDst, RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg;
    wire        Branch, Jump, pmc, JMN, swi_inc, Extd, PCSrc;
    wire [1:0]  ALUop;
    wire        zero;

    control_unit CU (
        .opcode   (opcode),
        .zero     (zero),
        .RegDst   (RegDst),
        .RegWrite (RegWrite),
        .ALUSrc   (ALUSrc),
        .ALUop    (ALUop),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .MemtoReg (MemtoReg),
        .Branch   (Branch),
        .Jump     (Jump),
        .pmc      (pmc),
        .JMN      (JMN),
        .swi_inc  (swi_inc),
        .Extd     (Extd),
        .PCSrc    (PCSrc)
    );

    // ---- next-PC: the +4 adder and the PCSrc select live inside the PC ----
    wire [31:0] sign_ext_imm;
    wire [31:0] pc_plus4;                                   // from the PC
    wire [31:0] branch_offset = sign_ext_imm << 2;          // shift left 2
    wire [31:0] branch_target = pc_plus4 + branch_offset;
    wire clk;

    // Clock Divider to see the outputs on the FPGA (override DIVISOR in sim)
    ClockDivider #(.DIVISOR(DIVISOR)) ClockDivider(
        .clk_in(clk_in),
        .clk_out(clk),
        .rst(reset)
    );

    program_counter PC (
        .clk           (clk),
        .reset         (reset),
        .pc_src        (PCSrc),
        .branch_target (branch_target),
        .pc            (pc),
        .pc_plus4      (pc_plus4)
    );

    instruction_memory IMEM (
        .pc          (pc),
        .instruction (instruction)
    );

    // ---- registers + RegDst mux ----
    wire [31:0] read_data_1, read_data_2;
    wire [4:0]  write_reg;

    Mux2to1 #(5) RegDstMux (
        .A   (rt),
        .B   (rd),
        .Sel (RegDst),
        .Y   (write_reg)
    );

    register_file RF (
        .clk         (clk),
        .reset       (reset),
        .reg_write   (RegWrite),
        .read_reg_1  (rs),
        .read_reg_2  (rt),
        .write_reg   (write_reg),
        .write_data  (write_back_data),
        .read_data_1 (read_data_1),
        .read_data_2 (read_data_2)
    );

    // ---- sign extend + ALUSrc mux ----
    wire [31:0] alu_b;

    sign_extend SE (
        .in   (imm),
        .Extd (Extd),          // 1 = sign-extend, 0 = zero-extend (andi)
        .out  (sign_ext_imm)
    );

    Mux2to1 ALUSrcMux (
        .A   (read_data_2),
        .B   (sign_ext_imm),
        .Sel (ALUSrc),
        .Y   (alu_b)
    );

    // ---- ALU control + ALU ----
    wire [5:0] alu_ctrl;

    ALUcontrol AC (
        .aluOP   (ALUop),
        .funct   (funct),
        .aluctrl (alu_ctrl)
    );

    ALU ALU_UNIT (
        .A        (read_data_1),
        .B        (alu_b),
        .alu_ctrl (alu_ctrl),
        .Result   (alu_result),
        .Zero     (zero),
        .CarryOut (),
        .Overflow (),
        .Negative ()
    );

    // ---- data memory + MemtoReg mux ----
    wire [31:0] mem_data;

    data_memory DMEM (
        .address  (alu_result),
        .memRead  (MemRead),
        .memWrite (MemWrite),
        .clk      (clk),
        .data_in  (read_data_2),
        .rst_a    (~reset),      // active-low: clears memory while reset is high
        .rst_r    (1'b1),        // per-word reset unused
        .data_out (mem_data)
    );

    Mux2to1 MemToRegMux (
        .A   (alu_result),
        .B   (mem_data),
        .Sel (MemtoReg),
        .Y   (write_back_data)
    );

    // ---- hex displays: show "A  op  B  =  result" for the current instruction ----
    // Low 8 bits are enough: the displays only render two decimal digits (0..99).
    display #(.WIDTH(8)) dispA (
        .data_in  (read_data_1[7:0]),
        .Hex_Ones (HEX0),
        .Hex_Tens (HEX1)
    );

    display #(.WIDTH(8)) dispB (
        .data_in  (alu_b[7:0]),
        .Hex_Ones (HEX2),
        .Hex_Tens (HEX3)
    );

    display #(.WIDTH(8)) dispR (
        .data_in  (alu_result[7:0]),
        .Hex_Ones (HEX4),
        .Hex_Tens (HEX5)
    );

    // ---- red LEDs: live control-signal view ----------------------------
    //  9  8 | 7    | 6      | 5        | 4        | 3       | 2      | 1        | 0
    // ALUop | Zero | Branch | MemtoReg | MemWrite | MemRead | ALUSrc | RegWrite | RegDst
    assign LEDR[0] = RegDst;
    assign LEDR[1] = RegWrite;
    assign LEDR[2] = ALUSrc;
    assign LEDR[3] = MemRead;
    assign LEDR[4] = MemWrite;
    assign LEDR[5] = MemtoReg;
    assign LEDR[6] = Branch;
    assign LEDR[7] = zero;
    assign LEDR[9:8] = ALUop;

endmodule
