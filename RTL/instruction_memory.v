module instruction_memory (
    input  [31:0] pc,   // byte address (PC counts by 4)
    output [31:0] instruction
);


    reg [7:0] instr_memory [0:4095]; // byte addressable memory, every address is 1 byte, 4096 bytes = 1024 words

    initial begin
        $readmemb("instruction.mem.txt", instr_memory);
    end
    
    wire [11:0] addr = pc[11:0];

    assign instruction = { instr_memory[addr], 
                           instr_memory[addr + 12'd1], 
                           instr_memory[addr + 12'd2], 
                           instr_memory[addr + 12'd3] };

endmodule