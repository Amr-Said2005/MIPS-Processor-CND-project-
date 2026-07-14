'timescale 1ns/1ps

module tb_CU; 

//-------- -------------INPUTS

reg [5:0] opcode;
reg         zero; 

//------- --------------OUTPUTS

wire     RegDst;
wire     RegWrite;
wire     ALUSrc;
wire     ALUop;
wire     MemRead;
wire     MemWrite;
wire     MemtoReg;
wire     Branch;
wire     Jump;
wire     pmc;
wire     JMN;
wire     swi_inc;
wire     Extd;
wire     PCSrc;

//------------- CU Instantiation 

CU DUT (

    .opcode(opcode),
    .zero (zero),
    .RegDst(RegDst),
    .RegWrite(RegWrite),
    .ALUSrc(ALUSrc),
    .ALUop(ALUop),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .MemtoReg(MemtoReg),
    .Branch(Branch),
    .Jump(Jump),
    .pmc(pmc),
    .JMN(JMN),
    .swi_inc(swi_inc),
    .Extd(Extd),
    .PCSrc(PCSrc)

);

task display_signal;

        input [63:0] test_name; 
        begin
            $display("--------------------------------------------------");
            $display("Instruction : %s", test_name);
            $display("opcode      : %b  | zero    : %b", opcode, zero);
            $display("RegDst      : %b  | RegWrite: %b", RegDst, RegWrite);
            $display("ALUSrc      : %b  | ALUop   : %b", ALUSrc, ALUop);
            $display("MemRead     : %b  | MemWrite: %b", MemRead, MemWrite);
            $display("MemtoReg    : %b  | Branch  : %b", MemtoReg, Branch);
            $display("Jump        : %b  | PCSrc   : %b", Jump, PCSrc);
            $display("JMN         : %b  | swi_inc : %b", JMN, swi_inc);
            $display("pmc         : %b  | Extd    : %b", pmc, Extd);
            $display("");
        end
endtask

integer pass_count;
integer fail_count;

task check; 

input [8*20:1] name;
        input exp_RegDst, exp_RegWrite, exp_ALUSrc;
        input [1:0] exp_ALUop;
        input exp_MemRead, exp_MemWrite, exp_MemtoReg;
        input exp_Branch, exp_Jump, exp_JMN, exp_swi_inc, exp_pmc;
        input exp_PCSrc;
        begin
            #5;

            if (RegDst !== exp_RegDst ||
                RegWrite !== exp_RegWrite ||
                ALUSrc   !== exp_ALUSrc   ||
                ALUop    !== exp_ALUop    ||
                MemRead  !== exp_MemRead  ||
                MemWrite !== exp_MemWrite ||
                MemtoReg !== exp_MemtoReg ||
                Branch   !== exp_Branch  ||
                Jump     !== exp_Jump    ||
                JMN      !== exp_JMN     ||
                swi_inc  !== exp_swi_inc ||
                pmc      !== exp_pmc     ||
                PCSrc    !== exp_PCSrc)

                begin 

                    $display("FAIL: %s", name);
                $display("  Expected: RegDst=%b RegWrite=%b ALUSrc=%b ALUop=%b MemRead=%b MemWrite=%b MemtoReg=%b Branch=%b Jump=%b JMN=%b swi_inc=%b pmc=%b PCSrc=%b",
                    exp_RegDst, exp_RegWrite, exp_ALUSrc, exp_ALUop,
                    exp_MemRead, exp_MemWrite, exp_MemtoReg,
                    exp_Branch, exp_Jump, exp_JMN, exp_swi_inc, exp_pmc, exp_PCSrc);
                $display("  Got:      RegDst=%b RegWrite=%b ALUSrc=%b ALUop=%b MemRead=%b MemWrite=%b MemtoReg=%b Branch=%b Jump=%b JMN=%b swi_inc=%b pmc=%b PCSrc=%b",
                    RegDst, RegWrite, ALUSrc, ALUop,
                    MemRead, MemWrite, MemtoReg,
                    Branch, Jump, JMN, swi_inc, pmc, PCSrc);
                fail_count = fail_count + 1;

                end else begin
                $display("PASS: %s", name);
                pass_count = pass_count + 1;
            end
        end
    endtask

    intial begin 

        pass_count = 0;
        fail_count = 0;
        zero = 0;

        $display("==================================================");
        $display("       Control Unit Testbench Starting            ");
        $display("==================================================");

 // ──────────────────────────────────────────────────────
        // TEST 1: R-type
        // Expected: RegDst=1 RegWrite=1 ALUSrc=0 ALUop=00
        //           MemRead=0 MemWrite=0 MemtoReg=0
        //           Branch=0 Jump=0 JMN=0 swi_inc=0 pmc=0 PCSrc=0
        // ──────────────────────────────────────────────────────
        opcode = 6'b000000; zero = 0; #10;
        check("R_type",
            1, 1, 0, 2'b00,   // RegDst RegWrite ALUSrc ALUop
            0, 0, 0,           // MemRead MemWrite MemtoReg
            0, 0, 0, 0, 0,    // Branch Jump JMN swi_inc pmc
            0);                // PCSrc

            // ──────────────────────────────────────────────────────
        // TEST 2: ADDI
        // Expected: RegDst=0 RegWrite=1 ALUSrc=1 ALUop=01
        //           MemRead=0 MemWrite=0 MemtoReg=0
        //           Branch=0 Jump=0 JMN=0 swi_inc=0 pmc=0 PCSrc=0
        // ──────────────────────────────────────────────────────
        opcode = 6'b000001; zero = 0; #10;
        check("ADDI",
            0, 1, 1, 2'b01,
            0, 0, 0,
            0, 0, 0, 0, 0,
            0);

            // ──────────────────────────────────────────────────────
        // TEST 3: ANDI
        // Expected: RegDst=0 RegWrite=1 ALUSrc=1 ALUop=11
        //           MemRead=0 MemWrite=0 MemtoReg=0
        //           Branch=0 Jump=0 JMN=0 swi_inc=0 pmc=0 PCSrc=0
        // ──────────────────────────────────────────────────────
        opcode = 6'b000010; zero = 0; #10;
        check("ANDI",
            0, 1, 1, 2'b11,
            0, 0, 0,
            0, 0, 0, 0, 0,
            0);

            // ──────────────────────────────────────────────────────
        // TEST 4: LW
        // Expected: RegDst=0 RegWrite=1 ALUSrc=1 ALUop=01
        //           MemRead=1 MemWrite=0 MemtoReg=1
        //           Branch=0 Jump=0 JMN=0 swi_inc=0 pmc=0 PCSrc=0
        // ──────────────────────────────────────────────────────
        opcode = 6'b000011; zero = 0; #10;
        check("LW",
            0, 1, 1, 2'b01,
            1, 0, 1,
            0, 0, 0, 0, 0,
            0);

             opcode = 6'b000100; zero = 0; #10;
        $display("SW: RegWrite=%b ALUSrc=%b ALUop=%b MemWrite=%b PCSrc=%b",
                  RegWrite, ALUSrc, ALUop, MemWrite, PCSrc);
        // Manual check for don't-care signals
        if (RegWrite == 0 && ALUSrc == 1 && ALUop == 2'b01 &&
            MemRead  == 0 && MemWrite == 1 && Branch == 0 &&
            Jump == 0 && PCSrc == 0) begin
            $display("PASS: SW");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: SW");
            fail_count = fail_count + 1;
        end

         opcode = 6'b000101; zero = 0; #10;
        check("BEQ (zero=0 no branch)",
            0, 0, 0, 2'b10,
            0, 0, 0,
            1, 0, 0, 0, 0,
            0);   // PCSrc=0 because zero=0

        // ──────────────────────────────────────────────────────
        // TEST 7: BEQ — zero=1 → branch taken
        // Expected: Branch=1 AND zero=1 → PCSrc=1
        // ──────────────────────────────────────────────────────
        opcode = 6'b000101; zero = 1; #10;
        check("BEQ (zero=1 branch taken)",
            0, 0, 0, 2'b10,
            0, 0, 0,
            1, 0, 0, 0, 0,
            1);   // PCSrc=1 because Branch&zero=1
        zero = 0; // reset zero

        
opcode = 6'b000110; zero = 0; #10;
        check("J",
            0, 0, 0, 2'b00,
            0, 0, 0,
            0, 1, 0, 0, 0,
            1);   // PCSrc=1 because Jump=1

        // ──────────────────────────────────────────────────────
        // TEST 9: JMN
        // Expected: JMN=1 ALUSrc=1 MemRead=1 → PCSrc=1
        // ──────────────────────────────────────────────────────
        opcode = 6'b000111; zero = 0; #10;
        check("JMN",
            0, 0, 1, 2'b00,   // ALUop=xx treated as 00 default
            1, 0, 0,
            0, 0, 1, 0, 0,
            1);   // PCSrc=1 because JMN=1

            opcode = 6'b001000; zero = 0; #10;
        $display("SWI: RegWrite=%b ALUSrc=%b MemWrite=%b swi_inc=%b PCSrc=%b",
                  RegWrite, ALUSrc, MemWrite, swi_inc, PCSrc);
        if (RegWrite == 1 && ALUSrc == 1 &&
            MemWrite == 1 && swi_inc == 1 &&
            Branch == 0 && Jump == 0 && PCSrc == 0) begin
            $display("PASS: SWI");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: SWI");
            fail_count = fail_count + 1;
        end

        // ──────────────────────────────────────────────────────
        // TEST 11: PMC
        // Expected: MemRead=1 MemWrite=1 pmc=1 → PCSrc=1
        // ──────────────────────────────────────────────────────
        opcode = 6'b001001; zero = 0; #10;
        check("PMC",
            0, 0, 1, 2'b00,
            1, 1, 0,
            0, 0, 0, 0, 1,
            1);   // PCSrc=1 because pmc=1

        // ──────────────────────────────────────────────────────
        // TEST 12: Unknown opcode → all zeros (NOP behavior)
        // ──────────────────────────────────────────────────────
        opcode = 6'b111111; zero = 0; #10;
        check("UNKNOWN_NOP",
            0, 0, 0, 2'b00,
            0, 0, 0,
            0, 0, 0, 0, 0,
            0);

            // ──────────────────────────────────────────────────────
        // RESULTS
        // ──────────────────────────────────────────────────────
        $display("==================================================");
        $display("  RESULTS: %0d PASSED  |  %0d FAILED", pass_count, fail_count);
        $display("==================================================");

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule





