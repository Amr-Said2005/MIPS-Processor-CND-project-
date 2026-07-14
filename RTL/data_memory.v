module data_memory (
    input wire [31:0] address, 
    input wire        memRead,
    input wire        memWrite,
    input wire        clk,
    input wire [31:0] data_in,
    input wire        rst_a,
    input wire        rst_r,
    output reg [31:0] data_out
);
//test from yo mans shal
reg [31:0] mem [1023:0];
integer i;

    always @(posedge clk or negedge rst_a or negedge rst_r) begin
    if(!rst_a) begin //Reset 
        for(i = 0; i < 1024; i = i + 1)
            mem[i] <= 32'b0;
    end
    
    else if(!rst_r) begin //Reset 
            mem[address] <= 32'b0;
    end


    else if(memRead) begin //Read from memory
        data_out <= mem[address]; 
    end 
    else if(memWrite) begin
        mem[address] <= data_in;
    end
end

endmodule 
