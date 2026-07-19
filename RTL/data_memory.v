// Byte-addressable data RAM, big-endian, with SEPARATE read and write addresses.
//
// Dual-address because pmc reads Memory[R[rt]] and writes Memory[R[rs]+imm] in
// the SAME cycle. The read is combinational and the write is clocked, so they
// were already independent paths -- splitting the address costs nothing.
// For lw/sw/swi the datapath drives both addresses with the same ALU result.
//
// SIZE is deliberately small. A combinational (single-cycle) read of a byte
// array needs four SIZE-to-1 multiplexers to assemble a word, and the async
// mass-reset keeps it out of block RAM, so every byte costs 8 flip-flops.
// At 4096 bytes that was ~32,768 registers and ~91% of the device; 256 bytes
// costs ~2,048 and fits comfortably. Widen SIZE only if a test program needs it.
module data_memory #(
    parameter ADDR_W = 9,                 // 9 -> 512 bytes (128 words)
    parameter SIZE   = (1 << ADDR_W)
)(
    input  wire [31:0] read_address,      // load  (lw / jmn / pmc target fetch)
    input  wire [31:0] write_address,     // store (sw / swi / pmc return addr)
    input  wire        memRead,
    input  wire        memWrite,
    input  wire        clk,
    input  wire [31:0] data_in,
    input  wire        rst_a,             // active-low: clear whole memory
    input  wire        rst_r,             // active-low: clear addressed word
    output wire [31:0] data_out
);

    reg [7:0] mem [0:SIZE-1];
    integer   i;

    wire [ADDR_W-1:0] r_addr = read_address[ADDR_W-1:0];
    wire [ADDR_W-1:0] w_addr = write_address[ADDR_W-1:0];

    always @(posedge clk or negedge rst_a or negedge rst_r) begin
        if (!rst_a) begin                       // full memory reset
            for (i = 0; i < SIZE; i = i + 1)
                mem[i] <= 8'b0;
        end
        else if (!rst_r) begin                  // reset addressed word
            mem[w_addr]     <= 8'b0;
            mem[w_addr + 1] <= 8'b0;
            mem[w_addr + 2] <= 8'b0;
            mem[w_addr + 3] <= 8'b0;
        end
        else if (memWrite) begin                // store (big-endian: MSB at lowest addr)
            mem[w_addr]     <= data_in[31:24];
            mem[w_addr + 1] <= data_in[23:16];
            mem[w_addr + 2] <= data_in[15:8];
            mem[w_addr + 3] <= data_in[7:0];
        end
    end

    // combinational read, big-endian; single-cycle needs the data this cycle
    assign data_out = memRead ? { mem[r_addr],     mem[r_addr + 1],
                                  mem[r_addr + 2], mem[r_addr + 3] }
                              : 32'd0;

endmodule
