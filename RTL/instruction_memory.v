// Instruction ROM, 64 words (256 bytes).
//
// The PC is a BYTE address and counts by 4; instructions are always word
// aligned, so the low 2 bits are dropped and the ROM is indexed by pc[7:2].
//
// Words (not a byte array) on purpose: a byte array needs 4 concurrent reads
// (addr, addr+1, addr+2, addr+3) to assemble an instruction. Quartus cannot
// infer that as a ROM, so it degrades to plain registers -- and $readmemb is
// not synthesisable on plain registers, leaving the memory all zeros on the
// board. A single-port word ROM infers cleanly and keeps its init contents.
module instruction_memory (
    input  [31:0] pc,            // byte address (PC counts by 4)
    output [31:0] instruction
);

    reg [31:0] rom [0:127];       // 128 instructions

    initial begin
        $readmemb("instruction.mem.txt", rom);
    end

    // 128 words need a 7-bit index: pc[8:2] (pc[7:2] would wrap at word 64)
    assign instruction = rom[pc[8:2]];   // drop the 2 byte-offset bits

endmodule
