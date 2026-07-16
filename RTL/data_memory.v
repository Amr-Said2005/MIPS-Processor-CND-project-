module data_memory (
    input  wire [31:0] address,
    input  wire        memRead,
    input  wire        memWrite,
    input  wire        clk,
    input  wire [31:0] data_in,
    input  wire        rst_a,     // active-low: clear whole memory
    input  wire        rst_r,     // active-low: clear addressed word
    output wire [31:0] data_out
);

    reg [7:0] mem [0:4095];       // byte addressable, 4096 bytes
    integer   i;

    wire [11:0] byte_addr = address[11:0];

    always @(posedge clk or negedge rst_a or negedge rst_r) begin
        if (!rst_a) begin                       // full memory reset
            for (i = 0; i < 4096; i = i + 1)
                mem[i] <= 8'b0;
        end
        else if (!rst_r) begin                  // reset addressed word
            mem[byte_addr]     <= 8'b0;
            mem[byte_addr + 1] <= 8'b0;
            mem[byte_addr + 2] <= 8'b0;
            mem[byte_addr + 3] <= 8'b0;
        end
        else if (memWrite) begin                // store (big-endian: MSB at lowest addr)
            mem[byte_addr]     <= data_in[31:24];
            mem[byte_addr + 1] <= data_in[23:16];
            mem[byte_addr + 2] <= data_in[15:8];
            mem[byte_addr + 3] <= data_in[7:0];
        end
    end

    // combinational read, big-endian; single-cycle needs the data this cycle
    assign data_out = memRead ? { mem[byte_addr],     mem[byte_addr + 1],
                                  mem[byte_addr + 2], mem[byte_addr + 3] }
                              : 32'd0;

endmodule
