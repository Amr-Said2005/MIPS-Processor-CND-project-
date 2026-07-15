// Single-cycle MIPS datapath (byte-addressed: PC+4, branch offset shifted left 2)
module mips_datapath (
    input         clk,
    input         reset,

    // observation outputs
    output [31:0] pc,
    output [31:0] instruction,
    output [31:0] alu_result,
    output [31:0] write_back_data
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

    // ---- next-PC: Add(pc,4), branch adder, PCSrc mux, PC register ----
    wire [31:0] sign_ext_imm;
    wire [31:0] pc_plus4      = pc + 32'd4;
    wire [31:0] branch_offset = sign_ext_imm << 2;          // shift left 2
    wire [31:0] branch_target = pc_plus4 + branch_offset;
    wire [31:0] pc_next;

    Mux2to1 PCSrcMux (
        .A   (pc_plus4),
        .B   (branch_target),
        .Sel (PCSrc),
        .Y   (pc_next)
    );

    program_counter PC (
        .clk     (clk),
        .reset   (reset),
        .pc_next (pc_next),
        .pc      (pc)
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
        .in  (imm),
        .out (sign_ext_imm)
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

endmodule
