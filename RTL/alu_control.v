module alu_control (
    input      [1:0] ALUop,    // from your CU
    input      [5:0] funct,    // 4-bit — from instruction[3:0]
    output reg [5:0] alu_ctrl  // 4-bit - send to ALU
);

    // ── funct codes (your encoding) ───────────────────────
    localparam FUNCT_ADD = 6'b000000;
    localparam FUNCT_SUB = 6'b000001;
    localparam FUNCT_AND = 6'b000010;
    localparam FUNCT_OR  = 6'b000011;
    localparam FUNCT_SLT = 6'b000100;

    // ── ALU operations (4-bit) ────────────────────────────
    localparam ALU_ADD = 6'b000000;
    localparam ALU_SUB = 6'b000001;
    localparam ALU_AND = 6'b000010;
    localparam ALU_OR  = 6'b000011;
    localparam ALU_SLT = 6'b000100;

    always @(*) begin
        case (ALUop)

            2'b00: begin              // R-type → check funct
                case (funct)
                    FUNCT_ADD: alu_ctrl = ALU_ADD;
                    FUNCT_SUB: alu_ctrl = ALU_SUB;
                    FUNCT_AND: alu_ctrl = ALU_AND;
                    FUNCT_OR:  alu_ctrl = ALU_OR;
                    FUNCT_SLT: alu_ctrl = ALU_SLT;
                    default:   alu_ctrl = ALU_ADD;
                endcase
            end

            2'b01: alu_ctrl = ALU_ADD;  // LW,SW,ADDI,JMN,SWI,PMC
            2'b10: alu_ctrl = ALU_SUB;  // BEQ → subtract to compare
            2'b11: alu_ctrl = ALU_AND;  // ANDI → AND with immediate

            default: alu_ctrl = ALU_ADD;

        endcase
    end

endmodule
