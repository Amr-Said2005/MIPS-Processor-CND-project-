module mem_wb_reg (
    input clk,
    input reset,

    input [31:0] mem_data_out,
    input [31:0] mem_alu_result,
    input [4:0]  mem_write_reg,
    input mem_RegWrite, mem_MemtoReg,

    output reg [31:0] wb_mem_data,
    output reg [31:0] wb_alu_result,
    output reg [4:0]  wb_write_reg,
    output reg wb_RegWrite, wb_MemtoReg
);
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            wb_mem_data   <= 32'b0;
            wb_alu_result <= 32'b0;
            wb_write_reg  <= 5'b0;
            wb_RegWrite   <= 0;
            wb_MemtoReg   <= 0;
        end else begin
            wb_mem_data   <= mem_data_out;
            wb_alu_result <= mem_alu_result;
            wb_write_reg  <= mem_write_reg;
            wb_RegWrite   <= mem_RegWrite;
            wb_MemtoReg   <= mem_MemtoReg;
        end
    end
endmodule