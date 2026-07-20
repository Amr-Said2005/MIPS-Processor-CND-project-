`timescale 1ns / 1ps

module mips_tb;

    reg clk;
    reg reset;

    // Instantiate your top-level MIPS module
    // Replace 'mips_top' with your top-level module name
    mips_top uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation (100MHz / 10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;

        // Load binary instructions directly into Instruction Memory array
        // Replace 'imem' and 'mem' with your module instance and array names
        uut.imem.mem[0] = 32'b00100100_00001110_00000000_00000000;
        uut.imem.mem[1] = 32'b00100100_00001000_00000000_00001010;
        uut.imem.mem[2] = 32'b00100100_00001001_00000000_00010100;
        uut.imem.mem[3] = 32'b00000001_00001001_01010000_00100000;
        uut.imem.mem[4] = 32'b00000101_01001111_00000000_00000101;
        uut.imem.mem[5] = 32'b00001001_01001011_00000000_00001111;
        uut.imem.mem[6] = 32'b00010001_11001010_00000000_00000000;
        uut.imem.mem[7] = 32'b00001101_11001100_00000000_00000000;

        // Hold reset for 20ns, then start processor execution
        #20 reset = 0;

        // Run simulation long enough for instructions to execute
        #200;

        // Stop simulation
        $stop;
    end

endmodule