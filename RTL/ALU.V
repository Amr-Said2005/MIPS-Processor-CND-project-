module ALU (
    input  wire [31:0] A,          // First ALU operand
    input  wire [31:0] B,          // Second ALU operand
    input  wire [5:0]  alu_ctrl, // Selects ALU operation

    output reg  [31:0] Result,     // ALU result
    output wire        Zero,       // 1 when Result == 0, useful for beq
    output reg         CarryOut,   // Carry output for add/sub
    output reg         Overflow,   // Signed overflow flag
    output wire        Negative    // MSB of Result
);

    // ALU operation codes
    localparam ALU_ADD = 6'b000000;
    localparam ALU_SUB = 6'b000001;
    localparam ALU_AND = 6'b000010;
    localparam ALU_OR  = 6'b000011;
    localparam ALU_SLT = 6'b000100;

    // Internal 33-bit value to capture carry
    reg [32:0] temp;

    always @(*) begin
        // Default values to avoid latches
        Result   = 32'b0;
        CarryOut = 1'b0;
        Overflow = 1'b0;
        temp     = 33'b0;

        case (alu_ctrl)

            // ADD: Result = A + B
            ALU_ADD: begin
                temp     = {1'b0, A} + {1'b0, B};
                Result   = temp[31:0];
                CarryOut = temp[32];

                // Signed overflow happens when A and B have same sign,
                // but result has different sign.
                Overflow = (~A[31] & ~B[31] & Result[31]) |
                           ( A[31] &  B[31] & ~Result[31]);
            end

            // SUB: Result = A - B
            ALU_SUB: begin
                temp     = {1'b0, A} + {1'b0, ~B} + 33'b1;
                Result   = temp[31:0];
                CarryOut = temp[32]; // In subtraction, 1 means no borrow

                // Signed overflow happens when A and B have different signs,
                // and result sign is different from A.
                Overflow = (~A[31] & B[31] & Result[31]) |
                           ( A[31] & ~B[31] & ~Result[31]);
            end

            // AND: Result = A & B
            ALU_AND: begin
                Result = A & B;
            end

            // OR: Result = A | B
            ALU_OR: begin
                Result = A | B;
            end

            // SLT: signed set-less-than
            // If A < B, result = 1, else result = 0
            ALU_SLT: begin
                Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            end

            // Default operation
            default: begin
                Result   = 32'b0;
                CarryOut = 1'b0;
                Overflow = 1'b0;
            end

        endcase
    end

    // Flags
    assign Zero     = (Result == 32'b0);
    assign Negative = Result[31];

endmodule
