module data_memory (
    input wire [31:0] address, 
    input wire        memRead,
    input wire        memWrite,
    input wire        clk,
    input wire [31:0] data_in,
    output reg [31:0] data_out
);

reg [1023:0] mem [31:0];

always @(clk) begin

    if(memRead) begin
        data_out <= mem[address];
    end
    else if(memWrite) begin
        mem[address] <= data_in;
    end
end
endmodule 