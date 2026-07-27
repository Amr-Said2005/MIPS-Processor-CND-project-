module id_ex_reg (
    input clk,
    input reset,
    input stall,   // hold current contents
    input flush,   // control hazard

    // From ID stage
    input [31:0] id_read_data_1,
    input [31:0] id_read_data_2,
    input [31:0] id_sign_ext_imm,
    input [31:0] id_pc_plus4,
    input [4:0]  id_rs,
    input [4:0]  id_rt,
    input [4:0]  id_rd,
    input [5:0]  id_funct,
    input [25:0] id_jump_index,

    input id_RegDst, id_RegWrite, id_ALUSrc,
    input [1:0] id_ALUop,
    input id_MemRead, id_MemWrite, id_MemtoReg,
    input id_Branch, id_Jump, id_JMN, id_pmc, id_swi_inc,

    // To EX stage
    output reg [31:0] ex_read_data_1,
    output reg [31:0] ex_read_data_2,
    output reg [31:0] ex_sign_ext_imm,
    output reg [31:0] ex_pc_plus4,
    output reg [4:0]  ex_rs,
    output reg [4:0]  ex_rt,
    output reg [4:0]  ex_rd,
    output reg [5:0]  ex_funct,
    output reg [25:0] ex_jump_index,

    output reg ex_RegDst, ex_RegWrite, ex_ALUSrc,
    output reg [1:0] ex_ALUop,
    output reg ex_MemRead, ex_MemWrite, ex_MemtoReg,
    output reg ex_Branch, ex_Jump, ex_JMN, ex_pmc, ex_swi_inc
);
    always @(posedge clk or negedge reset) begin
        if (!reset || flush) begin
            ex_read_data_1  <= 32'b0;
            ex_read_data_2  <= 32'b0;
            ex_sign_ext_imm <= 32'b0;
            ex_pc_plus4     <= 32'b0;
            ex_rs           <= 5'b0;
            ex_rt           <= 5'b0;
            ex_rd           <= 5'b0;
            ex_funct        <= 6'b0;
            ex_jump_index   <= 26'b0;

            
            ex_RegDst   <= 0; ex_RegWrite <= 0; ex_ALUSrc <= 0;
            ex_ALUop    <= 2'b00;
            ex_MemRead  <= 0; ex_MemWrite <= 0; ex_MemtoReg <= 0;
            ex_Branch   <= 0; ex_Jump <= 0; ex_JMN <= 0;
            ex_pmc      <= 0; ex_swi_inc <= 0;
        end
        else if (!stall) begin
            ex_read_data_1  <= id_read_data_1;
            ex_read_data_2  <= id_read_data_2;
            ex_sign_ext_imm <= id_sign_ext_imm;
            ex_pc_plus4     <= id_pc_plus4;
            ex_rs           <= id_rs;
            ex_rt           <= id_rt;
            ex_rd           <= id_rd;
            ex_funct        <= id_funct;
            ex_jump_index   <= id_jump_index;

            ex_RegDst   <= id_RegDst;
            ex_RegWrite <= id_RegWrite;
            ex_ALUSrc   <= id_ALUSrc;
            ex_ALUop    <= id_ALUop;
            ex_MemRead  <= id_MemRead;
            ex_MemWrite <= id_MemWrite;
            ex_MemtoReg <= id_MemtoReg;
            ex_Branch   <= id_Branch;
            ex_Jump     <= id_Jump;
            ex_JMN      <= id_JMN;
            ex_pmc      <= id_pmc;
            ex_swi_inc  <= id_swi_inc;
        end
        
    end
endmodule