module immgen ( 
input extd,
input [15:0]imm_in,
output [31:0] imm_out);


assign imm_out= extd? {16*{imm_in[15]}}:{16'b0 ,imm_in};

endmodule