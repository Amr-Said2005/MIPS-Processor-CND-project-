// Single-cycle MIPS datapath (byte-addressed: PC+4, branch offset shifted left 2)
// Runs directly on the input clock (no divider).
module iexecute(

    input [31:0] pc_plus4,
    input [31:0] read_data_1,
    input [31:0] read_data_2,
    input [31:0] sign_ext_imm,

    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,
    input [5:0] funct,
    input [25:0] jump_index,

    input RegDst,
    input RegWrite,
    input ALUSrc,
    input [1:0] ALUop,
    input MemRead,
    input MemWrite,
    input MemtoReg,
    input Branch,
    input Jump,
    input JMN,
    input pmc,
    input swi_inc,

    output [31:0] alu_result,
    output [31:0] branch_target,
    output [31:0] jump_target,
    output [4:0] write_reg,
    output zero,
    output [31:0] store_data,
    output PCSrc
);

    wire [31:0] alu_b;
    assign jump_target ={pc_plus4[31:28], jump_index, 2'b00};
    wire [31:0] branch_offset;
    assign branch_offset = sign_ext_imm << 2;
    assign branch_target = pc_plus4 + branch_offset;
    assign PCSrc = (Branch & zero) | Jump;
    assign store_data = read_data_2;



    // 3-way destination select: rt (I-type) / rd (R-type) / rs (swi post-increment)
    wire [4:0] regdst_rt_rd;

    Mux2to1 #(5) RegDstMux (
        .A   (rt),
        .B   (rd),
        .Sel (RegDst),
        .Y   (regdst_rt_rd)
    );

    Mux2to1 #(5) SwiDstMux (
        .A   (regdst_rt_rd),
        .B   (rs),                // swi writes R[rs] <- R[rs] + imm
        .Sel (swi_inc),
        .Y   (write_reg)
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



endmodule
