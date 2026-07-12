// ============================================================
//  control_unit.v  -  Control Unit  (combinational decoder)
//  RISC-Style 20-bit Processor - CND Internship
// ============================================================
module control_unit (
	input  wire [5:0] opcode,
    input  wire       zero,
    output reg        RegDst,    
    output reg        RegWrite,  
    output reg        ALUSrc,
    output reg  [1:0] ALUop,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        MemtoReg,
    output reg        Branch,
    output reg        Jump,
    output reg        pmc,
    output reg        JMN,
    output reg        swi_inc,
    output reg        Extd,
    output wire       PCSrc      
);

    
    parameter R_type = 6'b000000;  
    parameter ADDI   = 6'b000001;
    parameter ANDI   = 6'b000010;
    parameter LW     = 6'b000011;
    parameter SW     = 6'b000100;
    parameter BEQ    = 6'b000101;
    parameter J      = 6'b000110;
    parameter JMN_OP = 6'b000111;  
    parameter SWI    = 6'b001000;
    parameter PMC    = 6'b001001;

	 
    assign PCSrc = (Branch & zero) | Jump | JMN | pmc;

    
    always @(*) begin

        
        RegDst   = 1'b0;
        RegWrite = 1'b0;
        ALUSrc   = 1'b0;
        ALUop    = 2'b00;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemtoReg = 1'b0;
        Branch   = 1'b0;
        Jump     = 1'b0;
        JMN      = 1'b0;
        swi_inc  = 1'b0;
        pmc      = 1'b0;
        Extd     = 1'b0;

        case (opcode)

            R_type: begin               
                RegDst   = 1'b1;
                RegWrite = 1'b1;
                ALUSrc   = 1'b0;
                ALUop    = 2'b00;      
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                Branch   = 1'b0;
                Jump     = 1'b0;
                Extd     = 1'b0;
            end

            ADDI: begin                 
                RegDst   = 1'b0;
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUop    = 2'b01;       
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                Branch   = 1'b0;
                Jump     = 1'b0;
                Extd     = 1'b1;
            end

            ANDI: begin                 // ✅ colon added
                RegDst   = 1'b0;
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;        // ✅ use immediate
                ALUop    = 2'b11;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                Branch   = 1'b0;
                Jump     = 1'b0;
                Extd     = 1'b0;       
            end

            LW: begin                   
                RegDst   = 1'b0;
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUop    = 2'b01;
                MemRead  = 1'b1;
                MemWrite = 1'b0;
                MemtoReg = 1'b1;
                Branch   = 1'b0;
                Jump     = 1'b0;
                Extd     = 1'b1;
            end

            SW: begin                   
                RegDst   = 1'b0;
                RegWrite = 1'b0;
                ALUSrc   = 1'b1;
                ALUop    = 2'b01;
                MemRead  = 1'b0;
                MemWrite = 1'b1;
                MemtoReg = 1'b0;
                Branch   = 1'b0;
                Jump     = 1'b0;
                Extd     = 1'b1;
            end

            BEQ: begin                  
                RegDst   = 1'b0;
                RegWrite = 1'b0;
                ALUSrc   = 1'b0;
                ALUop    = 2'b10;       
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                Branch   = 1'b1;        
                Jump     = 1'b0;
                Extd     = 1'b1;
            end

            J: begin                    
                RegDst   = 1'b0;
                RegWrite = 1'b0;
                ALUSrc   = 1'b0;
                ALUop    = 2'b00;       
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                Branch   = 1'b0;
                Jump     = 1'b1;
                Extd     = 1'b0;
            end

            JMN_OP: begin               
                RegDst   = 1'b0;
                RegWrite = 1'b0;
                ALUSrc   = 1'b1;        
                ALUop    = 2'b01;      
                MemRead  = 1'b1;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;        
                Branch   = 1'b0;
                Jump     = 1'b0;
                JMN      = 1'b1;
                Extd     = 1'b1;
            end

            SWI: begin                  
                RegDst   = 1'b0;
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUop    = 2'b01;       
                MemRead  = 1'b0;
                MemWrite = 1'b1;
                MemtoReg = 1'b0;
                Branch   = 1'b0;
                Jump     = 1'b0;        
                swi_inc  = 1'b1;
                Extd     = 1'b1;
            end

            PMC: begin                 
                RegDst   = 1'b0;
                RegWrite = 1'b0;
                ALUSrc   = 1'b1;
                ALUop    = 2'b01;
                MemRead  = 1'b1;
                MemWrite = 1'b1;
                MemtoReg = 1'b0;
                Branch   = 1'b0;
                Jump     = 1'b0;
                pmc      = 1'b1;
                Extd     = 1'b1;
            end

            default: begin
                
            end

        endcase
    end                                 

endmodule
