module alu_control (
    input      [1:0] alu_op,     // ALUOp from the main control unit
    input      [5:0] funct,      // instruction[5:0], used for R-type
    output reg [3:0] alu_ctrl    // ALU operation select
);

    // ---------------------------------------------------------------
    // R-type funct codes (standard MIPS)
    // ---------------------------------------------------------------
    localparam FUNCT_ADD = 6'b100000;
    localparam FUNCT_SUB = 6'b100010;
    localparam FUNCT_AND = 6'b100100;
    localparam FUNCT_OR  = 6'b100101;
    localparam FUNCT_SLT = 6'b101010;

    // ---------------------------------------------------------------
    // ALU control lines (what the ALU decodes)
    // ---------------------------------------------------------------
    localparam ALU_AND = 4'b0000;
    localparam ALU_OR  = 4'b0001;
    localparam ALU_ADD = 4'b0010;
    localparam ALU_SUB = 4'b0110;
    localparam ALU_SLT = 4'b0111;

    // ---------------------------------------------------------------
    // Combinational decode: ALUOp selects the class of operation,
    // and for R-type (ALUOp = 10) the funct field picks the exact one.
    // ---------------------------------------------------------------
    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = ALU_ADD;          // lw / sw  -> address add
            2'b01: alu_ctrl = ALU_SUB;          // beq      -> subtract to compare
            2'b10: begin                        // R-type   -> decode funct
                case (funct)
                    FUNCT_ADD: alu_ctrl = ALU_ADD;
                    FUNCT_SUB: alu_ctrl = ALU_SUB;
                    FUNCT_AND: alu_ctrl = ALU_AND;
                    FUNCT_OR:  alu_ctrl = ALU_OR;
                    FUNCT_SLT: alu_ctrl = ALU_SLT;
                    default:   alu_ctrl = ALU_ADD;
                endcase
            end
            default: alu_ctrl = ALU_ADD;
        endcase
    end

endmodule
