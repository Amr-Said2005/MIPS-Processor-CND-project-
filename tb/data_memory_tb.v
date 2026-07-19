module data_memory_tb();

    reg clk, rst_a, rst_r, memRead, memWrite;
    reg [31:0] address, data_in;
    wire [31:0] data_out;
    integer i;
    // data_memory now has separate read/write addresses (needed by pmc);
    // this tb only ever accesses one location at a time, so drive both.
    data_memory dut(
        .clk(clk),
        .rst_a(rst_a),
        .rst_r(rst_r),
        .memRead(memRead),
        .memWrite(memWrite),
        .read_address(address),
        .write_address(address),
        .data_in(data_in),
        .data_out(data_out)
    );

        initial begin
        clk = 0;
        forever #50 clk = ~clk;
        end

    initial begin

        // Reset all and Reset Register active
        rst_a = 0;
        rst_r = 0;
        memRead = 0;
        memWrite = 0;
        address = 0;
        data_in = 0;
        #100;
        // Release both resets and start initializating values
        rst_a = 1;
        rst_r = 1;
        memRead = 0;
        memWrite = 1;
        for (i = 0; i < 1024; i = i + 1) begin
            address = i;
            data_in = $random;
            #100;
        end

        // Read from memory
        rst_a = 1;
        rst_r = 1;
        memRead = 1;
        memWrite = 0;
        data_in = 0;
        for (i = 0; i < 1024; i = i + 1) begin
            address = i;
            #100;
        end

        // Reset Register active
        rst_a = 1;
        rst_r = 0;
        memRead = 0;
        memWrite = 0;
        address = 102;
        data_in = 0;
        #100;
        
        // Reset all active
        rst_a = 0;
        rst_r = 0;
        memRead = 0;
        memWrite = 0;
        address = 102;
        data_in = 0;
        #100;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

endmodule
