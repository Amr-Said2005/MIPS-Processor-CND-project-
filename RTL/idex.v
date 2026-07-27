`timescale 1ns/1ps

module tb_pipeline_if_id;

    reg clk;
    reg reset;

    wire [31:0] pc;
    wire [31:0] instruction;
    wire [31:0] alu_result;
    wire [31:0] write_back_data;

    wire [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;
    wire [9:0] LEDR;

    piplined_mips_datapath DUT(
        .clk(clk),
        .reset(reset),

        .pc(pc),
        .instruction(instruction),
        .alu_result(alu_result),
        .write_back_data(write_back_data),

        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5),

        .LEDR(LEDR)
    );

    //----------------------------------------------------
    // Clock
    //----------------------------------------------------

    initial begin
        clk = 0;
        forever #50 clk = ~clk;
    end

    //----------------------------------------------------
    // Reset
    //----------------------------------------------------

    initial begin
        reset = 1;
        #120;
        reset = 0;
    end

    //----------------------------------------------------
    // Waveform
    //----------------------------------------------------

    initial begin
        $dumpfile("pipeline_if_id.vcd");
        $dumpvars(0, tb_pipeline_if_id);
    end

    //----------------------------------------------------
    // Monitor every cycle
    //----------------------------------------------------

    always @(posedge clk) begin

        $display("------------------------------------------");
        $display("Time        = %0t",$time);
        $display("PC          = %h",pc);
        $display("Instruction = %h",instruction);

        $display("Opcode      = %h",instruction[31:26]);
        $display("rs          = %0d",instruction[25:21]);
        $display("rt          = %0d",instruction[20:16]);
        $display("rd          = %0d",instruction[15:11]);
        $display("imm         = %h",instruction[15:0]);

        $display("ReadData1   = %h",write_back_data);
        $display("SignExtImm  = %h",alu_result);

        $display("RegDst      = %b",LEDR[0]);
        $display("RegWrite    = %b",LEDR[1]);
        $display("ALUSrc      = %b",LEDR[2]);
        $display("MemRead     = %b",LEDR[3]);
        $display("MemWrite    = %b",LEDR[4]);
        $display("MemtoReg    = %b",LEDR[5]);
        $display("Branch      = %b",LEDR[6]);
        $display("Jump        = %b",LEDR[7]);
        $display("ALUOp       = %b",LEDR[9:8]);

    end

    //----------------------------------------------------
    // Finish
    //----------------------------------------------------

    initial begin
        #1500;
        $finish;
    end

endmodule