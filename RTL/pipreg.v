module #(prameter N) pipreg(
input hold,
input clear,
input clk,
input  [n-1:0] in;
output reg [n-1:0] out;


always@(posedge clk) begin
if(clear)
out<={N{1'b0}};

else if(hold) 

out<=out;

else
out<=in;
end
endmodule 

