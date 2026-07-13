`timescale 1ns / 1ps
module immgentb;

wire [31:0] timm_out;
reg textd;
reg [15:0]timm_in;

immgen dut  (textd,timm_in,timm_out);
initial begin 
 $monitor(" extend=%b datain=%b-> out=%b",textd, timm_in, timm_out);
 #10
 textd=0;
 timm_in= 16'b1011111101001101;
 #10
textd=1;
  timm_in= 16'b1011111101001101;
 #10
textd=1;
  timm_in= 16'b0011111101001101;
 #10
 $finish;
 end
 endmodule 
 