module forwarding_unit (
    input  [4:0] id_ex_rs,
    input  [4:0] id_ex_rt,

    input  [4:0] ex_mem_write_reg,
    input        ex_mem_RegWrite,

    input  [4:0] mem_wb_write_reg,
    input        mem_wb_RegWrite,

    output reg [1:0] ForwardA,   // selects read_data_1 source
    output reg [1:0] ForwardB    // selects read_data_2 source
);
    // 2'b00 = from register file, 2'b10 = from EX/MEM, 2'b01 = from MEM/WB
    always @(*) begin
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        // EX hazard (highest priority)
        if (ex_mem_RegWrite && (ex_mem_write_reg != 0) && (ex_mem_write_reg == id_ex_rs))
            ForwardA = 2'b10;
        else if (mem_wb_RegWrite && (mem_wb_write_reg != 0) && (mem_wb_write_reg == id_ex_rs))
            ForwardA = 2'b01;

        if (ex_mem_RegWrite && (ex_mem_write_reg != 0) && (ex_mem_write_reg == id_ex_rt))
            ForwardB = 2'b10;
        else if (mem_wb_RegWrite && (mem_wb_write_reg != 0) && (mem_wb_write_reg == id_ex_rt))
            ForwardB = 2'b01;
    end
endmodule