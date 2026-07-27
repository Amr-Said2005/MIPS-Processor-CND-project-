module  piplined_mips_datapath(
    input         clk,
    input         reset,

    // observation outputs
    output [31:0] pc,
    output [31:0] instruction,
    output [31:0] alu_result,
    output [31:0] write_back_data,

    // hex displays: operand A, operand B, ALU result (2 decimal digits each)
    output [6:0]  HEX0, HEX1,     // operand A : ones, tens
    output [6:0]  HEX2, HEX3,     // operand B : ones, tens
    output [6:0]  HEX4, HEX5,     // result    : ones, tens

    // red LEDs: live view of the control signals
    output [9:0]  LEDR
);
	//temp
    reg hold=0;
    reg clear=0;

    // control signals
	wire        RegDst, RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg;
    wire        Branch, Jump, pmc, JMN, swi_inc, Extd, PCSrc;
    wire [1:0]  ALUop;
    wire        zero;
	 //writeback
	 wire        wb_RegWrite;
	 wire [4:0]  wb_write_reg;
	 wire [31:0] wb_write_data;
 
	 
	 
	 
	 wire [31:0] sign_ext_imm;
    wire [31:0] pc_plus4;                                   // from the PC
          

    // j: word address in instruction[25:0], shifted left 2 for a byte address.
    // The top 4 bits come from PC+4, so a jump stays in the current 256 MB region.
   

    // PCSrc (from the control unit) is already (Branch & zero) | Jump | JMN | pmc,
    // so it only decides *whether* to redirect; these muxes pick *which* target:
    //   branch_target : beq            (PC+4 + offset<<2)
    //   jump_target   : j              (from the instruction)
    //   mem_data      : jmn / pmc      (indirect -- target loaded from memory)
    wire [31:0] direct_target;
    wire [31:0] taken_target;
    wire [31:0] mem_data;         // data-memory read (declared here: used below)
	 
	 wire [31:0] instruction_ifid , pc_plus4_ifid;
	
	 
	 inst_fetch if_id(.clk(clk),.reset(reset), .pc_src(PCSrc),.branch_target(taken_target ),.pc(pc),.pc_plus4( pc_plus4_ifid),.instruction(instruction_ifid));
		
		wire [63:0] if_id_in  = {instruction_ifid, pc_plus4_ifid};  
		wire [63:0] if_id_out;
		
		


	 pipreg   #(.N(64)) if_id_reg (.hold(), .clear(),.clk(clk), .in(if_id_in),.out(if_id_out));
	 
	wire [31:0] IFID_instruction;
	wire [31:0] IFID_pc_plus4;
	assign IFID_instruction =if_id_out[63:32];
	assign IFID_pc_plus4 = if_id_out[31:0];
	 

	wire [4:0]  rs, rt, rd;
	wire [5:0]  funct;
	wire [31:0] read_data_1, read_data_2, id_pc_plus4;
   wire [25:0] jump_index;
	wire [31:0] jump_target = { IFID_pc_plus4[31:28], jump_index, 2'b00 };
	
	 inst_decode ID (
    .clk         (clk),
    .reset       (reset),
    .instruction (IFID_instruction),
    .pc_plus4    (IFID_pc_plus4),
    .wb_RegWrite (wb_RegWrite),      
    .wb_write_reg(wb_write_reg),     
    .wb_write_data(wb_write_data),   
    .read_data_1 (read_data_1),     
    .read_data_2 (read_data_2),      
    .sign_ext_imm(sign_ext_imm),     
    .id_pc_plus4 (id_pc_plus4),     
    .rs          (rs),              
    .rt          (rt),               
    .rd          (rd),               
    .funct       (funct),           
    .RegDst      (RegDst),           
    .RegWrite    (RegWrite),
    .ALUSrc      (ALUSrc),
    .ALUop       (ALUop),
    .MemRead     (MemRead),
    .MemWrite    (MemWrite),
    .MemtoReg    (MemtoReg),
    .Branch      (Branch),
    .Jump        (Jump),
    .pmc         (pmc),
    .JMN         (JMN),
    .swi_inc     (swi_inc),
    .jump_index  (jump_index),       
    .Extd        (Extd)
);
   assign instruction =IFID_instruction;
	assign pc_plus4 = IFID_pc_plus4;
	
	 wire[31:0] idex_pc_plus4;
    wire [31:0] idex_read_data_1;
    wire [31:0] idex_read_data_2;
    wire [31:0] idex_sign_ext_imm;

    wire [4:0] idex_rs;
    wire [4:0] idex_rt;
    wire [4:0] idex_rd;
    wire [5:0] idex_funct;
    wire [25:0] idex_jump_index;

    wire idex_RegDst;
    wire idex_RegWrite;
    wire idex_ALUSrc;
    wire [1:0] idex_ALUop;
    wire idex_MemRead;
    wire idex_MemWrite;
    wire idex_MemtoReg;
    wire idex_Branch;
    wire idex_Jump;
    wire idex_JMN;
    wire idex_pmc;
    wire idex_swi_inc;

    
    wire [31:0] branch_target;
  	 wire [4:0] write_reg_ex;
    
    wire [31:0] store_data;
	 wire [187:0] idex_in;
	 wire [187:0] idex_out;
	 
iexecute EX (
    .pc_plus4     (idex_pc_plus4),
    .read_data_1  (idex_read_data_1),
    .read_data_2  (idex_read_data_2),
    .sign_ext_imm (idex_sign_ext_imm),
    .rs           (idex_rs),
    .rt           (idex_rt),
    .rd           (idex_rd),
    .funct        (idex_funct),
    .jump_index   (idex_jump_index),
    .RegDst       (idex_RegDst),
    .RegWrite     (idex_RegWrite),
    .ALUSrc       (idex_ALUSrc),
    .ALUop        (idex_ALUop),
    .MemRead      (idex_MemRead),
    .MemWrite     (idex_MemWrite),
    .MemtoReg     (idex_MemtoReg),
    .Branch       (idex_Branch),
    .Jump         (idex_Jump),
    .JMN          (idex_JMN),
    .pmc          (idex_pmc),
    .swi_inc      (idex_swi_inc),
    .alu_result   (alu_result),
    .branch_target(branch_target),
    .jump_target  (jump_target),
    .write_reg    (write_reg_ex),
    .zero         (zero),
    .store_data   (store_data),
    .PCSrc        (PCSrc)
);

assign idex_in = {
    id_pc_plus4,     // 32
    read_data_1,     // 32
    read_data_2,     // 32
    sign_ext_imm,    // 32
    rs,              // 5
    rt,              // 5
    rd,              // 5
    funct,           // 6
    jump_index,      // 26
    RegDst,          // 1
    RegWrite,        // 1
    ALUSrc,          // 1
    ALUop,           // 2
    MemRead,         // 1
    MemWrite,        // 1
    MemtoReg,        // 1
    Branch,          // 1
    Jump,            // 1
    JMN,             // 1
    pmc,             // 1
    swi_inc          // 1
};  
assign {
    idex_pc_plus4,
    idex_read_data_1,
    idex_read_data_2,
    idex_sign_ext_imm,
    idex_rs,
    idex_rt,
    idex_rd,
    idex_funct,
    idex_jump_index,
    idex_RegDst,
    idex_RegWrite,
    idex_ALUSrc,
    idex_ALUop,
    idex_MemRead,
    idex_MemWrite,
    idex_MemtoReg,
    idex_Branch,
    idex_Jump,
    idex_JMN,
    idex_pmc,
    idex_swi_inc
} = idex_out;
 pipreg   #(.N(188)) id_ex_reg (.hold(), .clear(),.clk(clk), .in(idex_in),.out(idex_out));
endmodule	 
	
	
	