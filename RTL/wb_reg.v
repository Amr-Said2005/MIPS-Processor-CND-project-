module write_back(

    input [31:0] alu_result,
    input [31:0] mem_data,
    input MemtoReg,

    output [31:0] write_back_data

);

Mux2to1 #(32) MemToRegMux(

    .A(alu_result),
    .B(mem_data),
    .Sel(MemtoReg),
    .Y(write_back_data)

);

endmodule