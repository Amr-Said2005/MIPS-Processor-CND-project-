module inst_decode (
    input         clk,
    input         reset,

    // From IF/ID pipeline register
    input  [31:0] instruction,
    input  [31:0] pc_plus4,

    // From WB stage (MEM/WB pipeline register)
    input         wb_RegWrite,
    input  [4:0]  wb_write_reg,
    input  [31:0] wb_write_data,

    // Outputs to ID/EX pipeline register
    output [31:0] read_data_1,
    output [31:0] read_data_2,
    output [31:0] sign_ext_imm,

    output [31:0] id_pc_plus4,

    output [4:0]  rs,
    output [4:0]  rt,
    output [4:0]  rd,
    output [5:0]  funct,

    // Control signals
    output        RegDst,
    output        RegWrite,
    output        ALUSrc,
    output [1:0]  ALUop,
    output        MemRead,
    output        MemWrite,
    output        MemtoReg,
    output        Branch,
    output        Jump,
    output        pmc,
    output        JMN,
    output        swi_inc,
    output [25:0] jump_index,
    output        Extd
);

    //------------------------------------------------------------
    // Instruction fields
    //------------------------------------------------------------
    assign rs    = instruction[25:21];
    assign rt    = instruction[20:16];
    assign rd    = instruction[15:11];
    wire [15:0] imm    = instruction[15:0];
    assign funct = instruction[5:0];
    wire [5:0] opcode  = instruction[31:26];
    assign jump_index = instruction[25:0];
    //------------------------------------------------------------
    // Pass PC+4 to next stage
    //------------------------------------------------------------
    assign id_pc_plus4 = pc_plus4;

    //------------------------------------------------------------
    // Control Unit
    //------------------------------------------------------------
    control_unit CU (
        .opcode   (opcode),

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
        .Extd     (Extd)
    );

    //------------------------------------------------------------
    // Register File
    //------------------------------------------------------------
    register_file RF (
        .clk         (clk),
        .reset       (reset),

        // Read ports
        .read_reg_1  (rs),
        .read_reg_2  (rt),
        .read_data_1 (read_data_1),
        .read_data_2 (read_data_2),

        // Write port (from WB stage)
        .reg_write   (wb_RegWrite),
        .write_reg   (wb_write_reg),
        .write_data  (wb_write_data)
    );

    //------------------------------------------------------------
    // Sign Extension
    //------------------------------------------------------------
    sign_extend SE (
        .in   (imm),
        .Extd (Extd),
        .out  (sign_ext_imm)
    );

endmodule