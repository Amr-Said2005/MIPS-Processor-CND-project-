module data_memory (
    input wire  [31:0] address, 
    input wire        memRead,
    input wire        memWrite,
    input wire        clk,
    output reg [31:0] data_out
)