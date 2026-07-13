module data_memory (
    input wire [31:0] address, 
    input wire        memRead,
    input wire        memWrite,
    input wire        clk,
    input wire [31:0] data_in,
    input wire        rst_n,
    output reg [31:0] data_out
);

reg [31:0] mem [1023:0];
integer i;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin //Reset 
        for(i = 0; i < 1023; i = i + 1)
            mem[i] = 32'b0;
    end


    else if(memRead) begin //Read from memory
        data_out <= mem[address]; 
    end 
    else if(memWrite) begin
        mem[address] <= data_in;
    end
end

endmodule 
