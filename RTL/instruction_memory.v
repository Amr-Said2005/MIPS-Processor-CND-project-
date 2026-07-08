module instruction_memory (
    input  [31:0] read_address,   // word address (PC counts by 1)
    output [31:0] instruction
);

    reg [31:0] instr_memory [0:1023]; // 1024 words

    initial begin
        $readmemb("instruction.mem", instr_memory);
    end

    assign instruction = instr_memory[read_address];

endmodule