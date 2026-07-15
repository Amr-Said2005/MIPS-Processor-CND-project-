'timescale 1ns/1ps

 module ALUcontrol_tb;

// INPUT SIGNALS 

reg [1:0] aluOP;
reg [3:0] funct;

// OUTPUT SIGNALS

wire [3:0] aluctrl;

// INSTANTIATION 

ALUcontrol DUT (
  
  .aluOP(aluOP),
  .funct(funct),
  .aluctrl(aluctrl)

);

integer pass_count;
integar fail_count;

task check;

input [3:0] exp_aluctrl;
begin 
    #5

if (aluctrl !== exp_aluctrl)
 begin  
    $display ("FAIL: %s");
    $display ("aluOP= %b  funct=%b" , aluOP, funct);
    $display ("Expected aluctrl = %b (%d)", exp_aluctrl);
    $dsplay ("GOT aluctrl = %b (%d)", aluctrl);
    fail_count = fail_count + 1;
 end 
 else begin
    $display ("PASS %s")
    pass_count = pass_count + 1;
 end 

end 

endtask 

intial begin 

    pass_count = 0;
    fail_count = 0;

    $display ("ALUop=00 : R-Type");

    ALUop =2'b00 ; funct = 4'b0000; #10

    check (4'b0000); #10;

    $display ("ALUop=01 : R-Type");
    
    ALUop = 2'b01 ; funct = 4'b0001; #10;

    $display ("ALUop=10 : R-Type");

    ALUop = 2'b10; funct = 4'b0000; #10; 

   $display ("ALUop=11 : R-Type");

   ALUop = 2'b11;  funct ' 4'b0000; #10;

     if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED - check signals above");

        $finish;
    end

endmodule





    








