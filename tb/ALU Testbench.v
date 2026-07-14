endmodule
`timescale 1ns/1ps

module ALU_tb;

    reg  [31:0] A;
    reg  [31:0] B;
  reg  [5:0]  alu_ctrl;

    wire [31:0] Result;
    wire        Zero;
    wire        CarryOut;
    wire        Overflow;
    wire        Negative;

    localparam ALU_ADD = 6'b000000;
    localparam ALU_SUB = 6'b000001;
    localparam ALU_AND = 6'b000010;
    localparam ALU_OR  = 6'b000011;
    localparam ALU_SLT = 6'b000100;

    // Instantiate ALU
    ALU dut (
        .A(A),
        .B(B),
        .alu_ctrl(alu_ctrl),
        .Result(Result),
        .Zero(Zero),
        .CarryOut(CarryOut),
        .Overflow(Overflow),
        .Negative(Negative)
    );

    // Test task
    task check_result;
        input [31:0] expected;
        input [255:0] test_name;
        begin
            #10;

            if (Result == expected) begin
                $display("PASS: %s | A=%d B=%d Result=%d Zero=%b Carry=%b Overflow=%b",
                         test_name, A, B, Result, Zero, CarryOut, Overflow);
            end else begin
                $display("FAIL: %s | A=%d B=%d Expected=%d Got=%d",
                         test_name, A, B, expected, Result);
            end
        end
    endtask

    initial begin
        $display("Starting ALU Testbench...");

        // -------------------------
        // ADD test
        // -------------------------
        A = 32'd10;
        B = 32'd5;
        alu_ctrl = ALU_ADD;
        check_result(32'd15, "ADD 10 + 5");

        // -------------------------
        // ADDI test
        // Same ALU operation as ADD.
        // B would come from sign-extended immediate in the CPU.
        // -------------------------
        A = 32'd20;
        B = 32'd7;
        alu_ctrl = ALU_ADD;
        check_result(32'd27, "ADDI 20 + immediate 7");

        // -------------------------
        // SUB test
        // -------------------------
        A = 32'd10;
        B = 32'd5;
        alu_ctrl = ALU_SUB;
        check_result(32'd5, "SUB 10 - 5");

        // -------------------------
        // SUB zero test
        // -------------------------
        A = 32'd8;
        B = 32'd8;
        alu_ctrl = ALU_SUB;
        check_result(32'd0, "SUB 8 - 8 / BEQ comparison");

        if (Zero == 1'b1)
            $display("PASS: Zero flag works for equal values");
        else
            $display("FAIL: Zero flag should be 1");

        // -------------------------
        // AND test
        // -------------------------
        A = 32'hF0F0_F0F0;
        B = 32'h0F0F_0F0F;
        alu_ctrl = ALU_AND;
        check_result(32'h0000_0000, "AND test");

        // -------------------------
        // ANDI test
        // Same ALU operation as AND.
        // B would come from immediate in the CPU.
        // -------------------------
        A = 32'hFFFF_0000;
        B = 32'h0000_00FF;
        alu_ctrl = ALU_AND;
        check_result(32'h0000_0000, "ANDI test");

        // -------------------------
        // OR test
        // -------------------------
        A = 32'hF0F0_0000;
        B = 32'h0000_0F0F;
        alu_ctrl = ALU_OR;
        check_result(32'hF0F0_0F0F, "OR test");

        // -------------------------
        // SLT test: 3 < 9
        // -------------------------
        A = 32'd3;
        B = 32'd9;
        alu_ctrl = ALU_SLT;
        check_result(32'd1, "SLT 3 < 9");

        // -------------------------
        // SLT test: 9 < 3 is false
        // -------------------------
        A = 32'd9;
        B = 32'd3;
        alu_ctrl = ALU_SLT;
        check_result(32'd0, "SLT 9 < 3");

        // -------------------------
        // Signed SLT test: -5 < 3
        // -------------------------
        A = -32'sd5;
        B = 32'd3;
        alu_ctrl = ALU_SLT;
        check_result(32'd1, "Signed SLT -5 < 3");

        // -------------------------
        // Overflow test: large positive + large positive
        // 0x7FFFFFFF + 1 = 0x80000000, signed overflow
        // -------------------------
        A = 32'h7FFF_FFFF;
        B = 32'd1;
        alu_ctrl = ALU_ADD;
        #10;

        if (Overflow == 1'b1)
            $display("PASS: ADD overflow detected");
        else
            $display("FAIL: ADD overflow not detected");

        $display("ALU Testbench Finished.");
        $stop;
    end

endmodule
