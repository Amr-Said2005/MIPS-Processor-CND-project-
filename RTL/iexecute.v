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

    // forwarding
    input  [1:0]  ForwardA,          // from forwarding_unit
    input  [1:0]  ForwardB,
    input  [31:0] ex_mem_alu_result, // EX/MEM.alu_result
    input  [31:0] mem_wb_write_data, // MEM/WB write-back value 

    output [31:0] alu_result,
    output [31:0] branch_target,
    output [31:0] jump_target,
    output [4:0] write_reg,
    output zero,

    
    output [31:0] mem_write_data,    // data_in for sw / swi / pmc(return addr)
    output [31:0] mem_read_addr,     // read_address for lw / jmn / pmc
    output [31:0] mem_write_addr,    // write_address for sw / swi / pmc

    output PCSrc
);

    wire [31:0] alu_b;
    assign jump_target = {pc_plus4[31:28], jump_index, 2'b00};
    wire [31:0] branch_offset;
    assign branch_offset = sign_ext_imm << 2;
    assign branch_target = pc_plus4 + branch_offset;
    assign PCSrc = (Branch & zero) | Jump;

    // ---- NEW: forwarding muxes, resolved BEFORE anything downstream uses
    //           the register-file values ----
    wire [31:0] fwd_read_data_1, fwd_read_data_2;

    Mux3to1 #(32) ForwardAMux (
        .A   (read_data_1),        // 2'b00: no hazard, use RF value
        .B   (mem_wb_write_data),  // 2'b01: forward from WB
        .C   (ex_mem_alu_result),  // 2'b10: forward from MEM (higher priority)
        .Sel (ForwardA),
        .Y   (fwd_read_data_1)
    );

    Mux3to1 #(32) ForwardBMux (
        .A   (read_data_2),
        .B   (mem_wb_write_data),
        .C   (ex_mem_alu_result),
        .Sel (ForwardB),
        .Y   (fwd_read_data_2)
    );

    // 3-way destination select: rt (I-type) / rd (R-type) / rs (swi post-inc)
    wire [4:0] regdst_rt_rd;

    Mux2to1 #(5) RegDstMux (
        .A   (rt),
        .B   (rd),
        .Sel (RegDst),
        .Y   (regdst_rt_rd)
    );

    Mux2to1 #(5) SwiDstMux (
        .A   (regdst_rt_rd),
        .B   (rs),
        .Sel (swi_inc),
        .Y   (write_reg)
    );

    // ALU B takes the FORWARDED rt value, not raw 
    Mux2to1 ALUSrcMux (
        .A   (fwd_read_data_2),
        .B   (sign_ext_imm),
        .Sel (ALUSrc),
        .Y   (alu_b)
    );

    wire [5:0] alu_ctrl;

    ALUcontrol AC (
        .aluOP   (ALUop),
        .funct   (funct),
        .aluctrl (alu_ctrl)
    );

    // ALU A takes the FORWARDED rs value
    ALU ALU_UNIT (
        .A        (fwd_read_data_1),
        .B        (alu_b),
        .alu_ctrl (alu_ctrl),
        .Result   (alu_result),
        .Zero     (zero),
        .CarryOut (),
        .Overflow (),
        .Negative ()
    );

    // memory-side address/data resolution 
    assign mem_write_addr = alu_result;

    assign mem_write_data = pmc ? pc_plus4 : fwd_read_data_2;

    assign mem_read_addr = pmc ? fwd_read_data_2 : alu_result;

endmodule