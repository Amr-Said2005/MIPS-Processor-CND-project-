module ALUcontrol(
input [1:0] aluOP,
input [3:0] funct,
output reg [3:0] aluctrl);

// R-type funct codes
parameter addfn=4'b0000;
parameter subfn=4'b0001;
parameter  orfn=4'b0010;
parameter andfn=4'b0011;
parameter sltfn=4'b0100;

// ALU op codes -- must match ALU.V
localparam ALU_ADD=4'b0000;
localparam ALU_SUB=4'b0001;
localparam ALU_AND=4'b0010;
localparam ALU_OR =4'b0011;
localparam ALU_SLT=4'b0100;

reg [3:0] aluctrl_temp;

// R-type: funct -> op
always @(*)begin
case(funct)
 addfn: aluctrl_temp=ALU_ADD;
 subfn: aluctrl_temp=ALU_SUB;
  orfn: aluctrl_temp=ALU_OR;
 andfn: aluctrl_temp=ALU_AND;
 sltfn: aluctrl_temp=ALU_SLT;
 default: aluctrl_temp=ALU_ADD;
endcase
end

// aluOP: 00=R-type 01=add 10=sub 11=and
always @(*)begin
case(aluOP)
 2'b00: aluctrl=aluctrl_temp;
 2'b01: aluctrl=ALU_ADD;
 2'b10: aluctrl=ALU_SUB;
 2'b11: aluctrl=ALU_AND;
 default: aluctrl=ALU_ADD;
endcase
end

endmodule
