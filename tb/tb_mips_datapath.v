`timescale 1ns/1ps
//
// Testbench for the single-cycle MIPS datapath.
// Runs whatever program is loaded in RTL/instruction.mem.txt, prints a
// per-cycle trace, then dumps the register file and data memory.
//
// NOTE: instruction_memory does $readmemb("instruction.mem.txt") relative to
// the SIMULATOR's working directory, so run this from the RTL/ folder:
//   cd RTL
//   iverilog -s tb_mips_datapath -o cpu.vvp ../tb/tb_mips_datapath.v *.v *.V
//   vvp cpu.vvp
//
module tb_mips_datapath;

    reg         clk;
    reg         reset;
    wire [31:0] pc, instruction, alu_result, write_back_data;
    wire [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    wire [9:0]  LEDR;

    integer     cycle;
    integer     k;

    // DIVISOR=1 bypasses the slow board clock so the CPU runs at clk_in speed.
    // (Hardware uses the default 25_000_000 -> 1 Hz.)
    mips_datapath #(.DIVISOR(1)) DUT (
        .clk_in          (clk),
        .reset           (reset),
        .pc              (pc),
        .instruction     (instruction),
        .alu_result      (alu_result),
        .write_back_data (write_back_data),
        .HEX0 (HEX0), .HEX1 (HEX1),
        .HEX2 (HEX2), .HEX3 (HEX3),
        .HEX4 (HEX4), .HEX5 (HEX5),
        .LEDR (LEDR)
    );

    // list which control LEDs are lit, by name
    function [199:0] led_names;
        input [9:0] L;
        begin
            led_names = "";
            if (L[0]) led_names = {led_names, "RegDst "};
            if (L[1]) led_names = {led_names, "RegWrite "};
            if (L[2]) led_names = {led_names, "ALUSrc "};
            if (L[3]) led_names = {led_names, "MemRead "};
            if (L[4]) led_names = {led_names, "MemWrite "};
            if (L[5]) led_names = {led_names, "MemtoReg "};
            if (L[6]) led_names = {led_names, "Branch "};
            if (L[7]) led_names = {led_names, "Zero "};
        end
    endfunction

    // reverse-lookup: 7-seg pattern -> the character it displays
    function [7:0] seg_char;
        input [6:0] s;
        begin
            case (s)
                7'b1000000: seg_char = "0";  7'b1111001: seg_char = "1";
                7'b0100100: seg_char = "2";  7'b0110000: seg_char = "3";
                7'b0011001: seg_char = "4";  7'b0010010: seg_char = "5";
                7'b0000010: seg_char = "6";  7'b1111000: seg_char = "7";
                7'b0000000: seg_char = "8";  7'b0010000: seg_char = "9";
                default:    seg_char = "?";
            endcase
        end
    endfunction

    // 10 ns clock
    always #5 clk = ~clk;

    // ---- decode opcode/funct into a readable mnemonic -------------------
    function [39:0] mnemonic;
        input [5:0] op;
        input [5:0] fn;
        begin
            case (op)
                6'b000000: case (fn)                 // R-type
                    6'b000000: mnemonic = "add  ";
                    6'b000001: mnemonic = "sub  ";
                    6'b000010: mnemonic = "and  ";
                    6'b000011: mnemonic = "or   ";
                    6'b000100: mnemonic = "slt  ";
                    default:   mnemonic = "R-?  ";
                endcase
                6'b000001: mnemonic = "addi ";
                6'b000010: mnemonic = "andi ";
                6'b000011: mnemonic = "lw   ";
                6'b000100: mnemonic = "sw   ";
                6'b000101: mnemonic = "beq  ";
                6'b000110: mnemonic = "j    ";
                6'b000111: mnemonic = "jmn  ";
                6'b001000: mnemonic = "swi  ";
                6'b001001: mnemonic = "pmc  ";
                default:   mnemonic = "?????";
            endcase
        end
    endfunction

    // read a 32-bit word out of the byte-addressed data memory (big-endian)
    function [31:0] dmem_word;
        input integer a;
        begin
            dmem_word = { DUT.DMEM.mem[a],   DUT.DMEM.mem[a+1],
                          DUT.DMEM.mem[a+2], DUT.DMEM.mem[a+3] };
        end
    endfunction

    initial begin
        $dumpfile("tb_mips_datapath.vcd");
        $dumpvars(0, tb_mips_datapath);

        clk   = 0;
        reset = 1;
        @(posedge clk);          // hold reset across one edge
        #1 reset = 0;

        $display("");
        $display("=========================== EXECUTION TRACE ===========================");
        $display("cyc | PC | asm   | HEX displays   | LEDR[9:0]  | control decode");
        $display("----+----+-------+----------------+------------+-------------------------");

        cycle = 0;
        // run until we fetch uninitialised memory (end of program) or hit a cap
        begin : trace_loop
            while (cycle < 40) begin
                #1;                                  // let combinational logic settle
                if (^instruction === 1'bx)
                    disable trace_loop;              // no more instructions
                $display(" %2d | %2d | %s | %s%s %s %s%s = %s%s | %b | %s",
                         cycle, pc,
                         mnemonic(DUT.opcode, DUT.funct),
                         seg_char(HEX1), seg_char(HEX0),        // operand A
                         mnemonic(DUT.opcode, DUT.funct),       // operation
                         seg_char(HEX3), seg_char(HEX2),        // operand B
                         seg_char(HEX5), seg_char(HEX4),        // result
                         LEDR,
                         led_names(LEDR));
                @(posedge DUT.clk);      // CPU clock (divided), not clk_in
                cycle = cycle + 1;
            end
        end

        #1;
        $display("");
        $display("=========================== REGISTER FILE ============================");
        for (k = 0; k < 10; k = k + 1)
            $display("  $%0d = %0d", k, DUT.RF.registers[k]);

        $display("");
        $display("=========================== DATA MEMORY ==============================");
        for (k = 0; k < 16; k = k + 4)
            $display("  mem[%0d] = %0d", k, dmem_word(k));

        $display("");
        $display("Program finished after %0d instructions.", cycle);
        $finish;
    end

endmodule
