// ============================================================
//  control_unit.v  -  Control Unit  (combinational decoder)
//  RISC-Style 20-bit Processor - CND Internship
// ============================================================
module control_unit (
    input  wire [3:0] opcode,
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

    
    parameter R_type = 4'b0000;  
    parameter ADDI   = 4'b0001;
    parameter ANDI   = 4'b0010;
    parameter LW     = 4'b0011;
    parameter SW     = 4'b0100;
    parameter BEQ    = 4'b0101;
    parameter J      = 4'b0110;
    parameter JMN_OP = 4'b0111;  
    parameter SWI    = 4'b1000;
    parameter PMC    = 4'b1001;

	 
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
