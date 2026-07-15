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

reg [7:0] mem [4096:0]; //memory array
integer i;
byte_addr = address[11:0];


    always @(posedge clk or negedge rst_a or negedge rst_r) begin
    if(!rst_a) begin //Full Memory Reset
        for(i = 0; i < 4096; i = i + 1)
            mem[i] <= 8'b0;
    end
    
    else if(!rst_r) begin //Reset specific address
            mem[byte_addr] <= 8'b0;
    end


    else if(memRead) begin //Read from memory
        data_out <= {mem[byte_addr + 3],
                    mem[byte_addr +2],
                    mem[byte_addr +1];
                    mem[byte_addr]}; 
    end 
    else if(memWrite) begin //Write to memory 
        mem[byte_addr] <= data_in[7:0];
        mem[byte_addr +1 ] <= data_in[15:8];
        mem[byte_addr + 2] <= data_in[23:16];
        mem[byte_addr + 3] <= data_in[31:24];
    end
end

endmodule 
