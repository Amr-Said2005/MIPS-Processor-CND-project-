module ALUcontrol(
input [1:0] alucOP,
input [3:0]funct,
output [3:0]aluctrl);
 

 


parameter addfn=000;
parameter subfn=001;
parameter  orfn=010;	
parameter andfn=011;
parameter sltfn=100;
 //Rtype 
 reg [3:0] aluctrl_temp;
always @(funct)begin 
case(funct)
 
 addfn: aluctrl_temp<=4'b0010;
 subfn: aluctrl_temp<=4'b0110;
  orfn: aluctrl_temp<=4'b0000;
 andfn: aluctrl_temp<=4'b0001;
 sltfn: aluctrl_temp<=4'b0111;
 endcase 



 always @(aluOP)begin 
case(aluOP)
 2'b00:aluctrl <=4'b0010;
 2'b01:aluctrl <= 4'b0110;
 2'b10:aluctrl <=aluctrl_temp;
 2'b11:aluctrl <=4'b0010;

 endcase 

