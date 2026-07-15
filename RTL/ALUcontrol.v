module ALUcontrol (
    input      [1:0] aluOP,     // from control_unit
    input      [5:0] funct,     // instruction[5:0]
    output reg [5:0] aluctrl    // to ALU (6-bit, matches ALU.V)
);

    // R-type funct codes
    localparam FUNCT_ADD = 6'b000000;
    localparam FUNCT_SUB = 6'b000001;
    localparam FUNCT_AND = 6'b000010;
    localparam FUNCT_OR  = 6'b000011;
    localparam FUNCT_SLT = 6'b000100;

    // ALU op codes -- must match ALU.V
    localparam ALU_ADD = 6'b000000;
    localparam ALU_SUB = 6'b000001;
    localparam ALU_AND = 6'b000010;
    localparam ALU_OR  = 6'b000011;
    localparam ALU_SLT = 6'b000100;

    // aluOP: 00=R-type 01=add(addi/lw/sw) 10=sub(beq) 11=and(andi)
    always @(*) begin
        case (aluOP)
            2'b00: begin
                case (funct)
                    FUNCT_ADD: aluctrl = ALU_ADD;
                    FUNCT_SUB: aluctrl = ALU_SUB;
                    FUNCT_AND: aluctrl = ALU_AND;
                    FUNCT_OR:  aluctrl = ALU_OR;
                    FUNCT_SLT: aluctrl = ALU_SLT;
                    default:   aluctrl = ALU_ADD;
                endcase
            end
            2'b01:   aluctrl = ALU_ADD;
            2'b10:   aluctrl = ALU_SUB;
            2'b11:   aluctrl = ALU_AND;
            default: aluctrl = ALU_ADD;
        endcase
    end

endmodule
