module register_file (
    input             clk,
    input             reset,          // synchronous, active-high: clears all registers
    input             reg_write,      // write enable (RegWrite control signal)
    input      [4:0]  read_reg_1,     // rs address
    input      [4:0]  read_reg_2,     // rt address
    input      [4:0]  write_reg,      // rd/rt destination address
    input      [31:0] write_data,     // data to write
    output     [31:0] read_data_1,    // rs data
    output     [31:0] read_data_2     // rt data
);

    // -----------------------------------------------------------------
    // Internal declarations
    // -----------------------------------------------------------------
    reg  [31:0] registers [0:31];     // storage: 32 registers, 32 bits each
    integer     i;                    // loop index for the reset clear

    // Note: read_data_1 / read_data_2 are the module outputs. They are
    // implicit wires here, driven combinationally by the assigns below.

    // -----------------------------------------------------------------
    // Asynchronous reads. Register 0 ($zero) always reads as 0.
    // -----------------------------------------------------------------
    assign read_data_1 = (read_reg_1 == 5'd0) ? 32'd0 : registers[read_reg_1];
    assign read_data_2 = (read_reg_2 == 5'd0) ? 32'd0 : registers[read_reg_2];

    // Synchronous write. Writes to register 0 are ignored ($zero is constant).
    // Reset is ASYNC: the divided CPU clock is stopped while reset is held.
    always @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            for (i = 0; i < 32; i = i + 1)
            registers[i] <= 32'd0;
        end
        else if (reg_write && (write_reg != 5'd0)) 
        begin
            registers[write_reg] <= write_data;
        end
    end

endmodule
