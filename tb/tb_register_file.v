

module tb_register_file();

    // -----------------------------------------------------------------
    // Signals matching the UUT (Unit Under Test)
    // -----------------------------------------------------------------
    reg         clk;
    reg         reset;
    reg         reg_write;
    reg  [4:0]  read_reg_1;
    reg  [4:0]  read_reg_2;
    reg  [4:0]  write_reg;
    reg  [31:0] write_data;

    wire [31:0] read_data_1;
    wire [31:0] read_data_2;

    // Error tracking
    integer error_count;

    // -----------------------------------------------------------------
    // Instantiate the Register File
    // -----------------------------------------------------------------
    register_file uut (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .read_reg_1(read_reg_1),
        .read_reg_2(read_reg_2),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );

    // -----------------------------------------------------------------
    // Clock Generation (10ns period -> 100MHz)
    // -----------------------------------------------------------------
    always #5 clk = ~clk;

    // -----------------------------------------------------------------
    // Self-Checking Tasks
    // -----------------------------------------------------------------
    
    // Task to write data to a register
    task write_register(input [4:0] addr, input [31:0] data);
        begin
            @(negedge clk); 
            reg_write  = 1;
            write_reg  = addr;
            write_data = data;
            @(negedge clk); // Wait for the positive edge to process the write
            reg_write  = 0;
        end
    endtask

    // Task to check read data against expected data
    task check_register(input [4:0] addr, input [31:0] expected_data);
        begin
            read_reg_1 = addr;
            #1; // Small delay to allow combinational read logic to settle
            
            if (read_data_1 !== expected_data) begin
                $display("[ERROR] Time: %0t | Reg[%0d] = 0x%h | Expected = 0x%h", 
                         $time, addr, read_data_1, expected_data);
                error_count = error_count + 1;
            end
        end
    endtask

    // -----------------------------------------------------------------
    // Main Test
    // -----------------------------------------------------------------
    initial begin
        // Initialize signals
        clk         = 0;
        reset       = 0;
        reg_write   = 0;
        read_reg_1  = 0;
        read_reg_2  = 0;
        write_reg   = 0;
        write_data  = 0;
        error_count = 0;

        $display("==================================================");
        $display("Starting Register File Self-Checking Testbench...");
        $display("==================================================");

        reset = 1;
        #15; 
        reset = 0;
        
        // Check a few registers to ensure they are cleared to 0
        check_register(5'd1, 32'd0);
        check_register(5'd15, 32'd0);
        check_register(5'd31, 32'd0);

        // -------------------------------------------------------------
        // TEST 1: Normal Write and Read operations
        // -------------------------------------------------------------
        $display("-> Test 1: Standard Write and Read");
        write_register(5'd5,  32'hDEADBEEF);
        write_register(5'd10, 32'hCAFEBABE);
        write_register(5'd31, 32'h12345678);

        check_register(5'd5,  32'hDEADBEEF);
        check_register(5'd10, 32'hCAFEBABE);
        check_register(5'd31, 32'h12345678);


        $display("-> Test 2: Write to Register 0 ");
        write_register(5'd0, 32'hFFFFFFFF);
        check_register(5'd0, 32'd0); // Should still read as 0

        // -------------------------------------------------------------
        // TEST 4: Write Enable (reg_write) functionality
        // -------------------------------------------------------------
        $display("-> Test 3: Write Enable ");
        @(negedge clk);
        reg_write  = 0;         // Disable writes
        write_reg  = 5'd5;      // Attempt to overwrite Reg 5
        write_data = 32'h99999999;
        @(negedge clk);
        
        // Check that Reg 5 did NOT change from earlier
        check_register(5'd5, 32'hDEADBEEF); 

        // -------------------------------------------------------------
        // TEST 4: Dual Asynchronous Read
        // -------------------------------------------------------------
        $display("-> Test 4: Dual Simultaneous Reads");
        read_reg_1 = 5'd10;
        read_reg_2 = 5'd31;
        #1;
        if (read_data_1 !== 32'hCAFEBABE || read_data_2 !== 32'h12345678) begin
            $display("[ERROR] Time: %0t | Dual Read Failed! Data1=0x%h, Data2=0x%h", 
                     $time, read_data_1, read_data_2);
            error_count = error_count + 1;
        end

        // -------------------------------------------------------------
        // Final Summary
        // -------------------------------------------------------------
        $display("==================================================");
        if (error_count == 0) begin
            $display(" SUCCESS: All tests passed with 0 errors!");
        end else begin
            $display(" FAILURE: Testbench finished with %0d errors.", error_count);
        end
        $display("==================================================");

        $finish;
    end

endmodule



