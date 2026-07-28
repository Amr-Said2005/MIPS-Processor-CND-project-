`timescale 1ns / 1ps

module mips_tb;

    reg clk;
    reg reset;

    // Instantiate your top-level MIPS module
    mips_top uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation (100MHz / 10ns period)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;

        // Load binary instructions directly into Instruction Memory array
        // uut.<imem_instance_name>.<array_name>[index]
        uut.imem.mem[0]  = 32'b001001_00000_01000_0000000000000101;
        uut.imem.mem[1]  = 32'b001001_00000_01001_0000000000000101;
        uut.imem.mem[2]  = 32'b000001_01000_01111_0000000000000011;
        uut.imem.mem[3]  = 32'b000101_01000_01001_0000000000000001;
        uut.imem.mem[4]  = 32'b001001_00000_01010_0000000001101111;
        uut.imem.mem[5]  = 32'b001001_00000_01011_1111111111111111;
        uut.imem.mem[6]  = 32'b000111_01011_00000_0000000000000001;
        uut.imem.mem[7]  = 32'b001001_00000_01100_0000000011011110;
        uut.imem.mem[8]  = 32'b001000_00000_00000_0000000000000001;
        uut.imem.mem[9]  = 32'b000110_00000000000000000000001011;
        uut.imem.mem[10] = 32'b001001_00000_01101_0000000101001101;
        uut.imem.mem[11] = 32'b000110_00000000000000000000001011;

        // Release reset to start CPU execution
        #20 reset = 0;

        // Run simulation for enough cycles
        #300;

        $stop;
    end

endmodule