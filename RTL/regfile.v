module  regfile(readreg1,readreg2,writereg,readdata1,readdata2,writedata ,RegWrite, clk,);	

input [2:0] readreg1,readreg2,writereg;
output [31:0] readdata1, readdata2;
input [31:0]writedata ;
input RegWrite,clk;


reg [31:0] regfile [31:0];

always@(posedge clk)begin
if(RegWrite)
regfile[writereg]<=
end 
assign regfile[readreg1]=readdata1;
assign regfile[readreg2]=readdata2;
endmodule

	
	
	
	

