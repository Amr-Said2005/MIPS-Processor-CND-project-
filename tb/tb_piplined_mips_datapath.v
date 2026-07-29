`timescale 1ns / 1ps

module tb_piplined_mips_datapath();


    // Parameters
    parameter N = 50;           // Number of clock cycles to run
    parameter CLK_PERIOD = 10;  // Clock period in ns


    // Testbench Signals
    reg         clk;
    reg         reset;

    // Observation outputs from DUT
    wire [31:0] pc;
    wire [31:0] instruction;
    wire [31:0] alu_result;
    wire [31:0] write_back_data;
    
    wire [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    wire [9:0]  LEDR;

    // Device Under Test (DUT) Instantiation
    piplined_mips_datapath DUT (
        .clk            (clk),
        .reset          (reset),
        .pc             (pc),
        .instruction    (instruction),
        .alu_result     (alu_result),
        .write_back_data(write_back_data),
        .HEX0           (HEX0),
        .HEX1           (HEX1),
        .HEX2           (HEX2),
        .HEX3           (HEX3),
        .HEX4           (HEX4),
        .HEX5           (HEX5),
        .LEDR           (LEDR)
    );


    // Clock Generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Test Sequence and Self-Checking Logic
    integer i;
    integer errors;

    initial begin
        // Initialize
        errors = 0;
        reset = 1;
        
        // Hold reset for a few cycles
        #(CLK_PERIOD * 2);
        reset = 0;

        // Run the pipeline for N cycles
        for (i = 0; i < N; i = i + 1) begin
            @(posedge clk);
        end

        // Allow one extra cycle for final write-backs to settle
        @(posedge clk);

        $display("==================================================");
        $display("Simulation finished after %0d cycles.", N);
        $display("Starting self-check verifications...");
        $display("==================================================");


        // Register File Content Test
        
        // if $t0 (register 8) holds expected value 32'h0000000A
        if (DUT.ID.RF.registers[8] !== 32'h0000000A) begin // UPDATE '.registers' IF NEEDED
            $display("[FAIL] Register $t0 mismatch. Expected: %h, Got: %h", 32'h0000000A, DUT.ID.RF.registers[8]);
            errors = errors + 1;
        end else begin
            $display("[PASS] Register $t0 has correct value.");
        end

        // if $t1 (register 9) holds expected value 32'h00000014
        if (DUT.ID.RF.registers[9] !== 32'h00000014) begin // UPDATE '.registers' IF NEEDED
            $display("[FAIL] Register $t1 mismatch. Expected: %h, Got: %h", 32'h00000014, DUT.ID.RF.registers[9]);
            errors = errors + 1;
        end else begin
            $display("[PASS] Register $t1 has correct value.");
        end
		  
        // Data Memory Content Test
        
        // if memory at word address 4 holds 32'h000000FF
        if (DUT.MEM.DMEM.memory_array[4] !== 32'h000000FF) begin // UPDATE '.memory_array' IF NEEDED
            $display("[FAIL] Memory[4] mismatch. Expected: %h, Got: %h", 32'h000000FF, DUT.MEM.DMEM.memory_array[4]);
            errors = errors + 1;
        end else begin
            $display("[PASS] Memory[4] has correct value.");
        end
			
			// Final Result
		  
        if (errors == 0) begin
            $display("TEST PASSED: All %0d checks completed successfully.", N);
        end else begin
            $display("TEST FAILED: Found %0d errors in final state.", errors);
        end


        $finish;
    end

endmodule