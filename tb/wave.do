# ModelSim wave setup for tb_mips_datapath
# Usage (from the RTL/ folder):
#   vsim -onfinish stop -do ../tb/wave.do tb_mips_datapath

quietly WaveActivateNextPane {} 0

add wave -divider "CLOCK / RESET"
add wave -label clk            sim:/tb_mips_datapath/clk
add wave -label reset          sim:/tb_mips_datapath/reset

add wave -divider "FETCH"
add wave -label PC     -radix unsigned    sim:/tb_mips_datapath/pc
add wave -label instr  -radix hexadecimal sim:/tb_mips_datapath/instruction

add wave -divider "DECODE"
add wave -label opcode -radix binary   sim:/tb_mips_datapath/DUT/opcode
add wave -label funct  -radix binary   sim:/tb_mips_datapath/DUT/funct
add wave -label rs     -radix unsigned sim:/tb_mips_datapath/DUT/rs
add wave -label rt     -radix unsigned sim:/tb_mips_datapath/DUT/rt
add wave -label rd     -radix unsigned sim:/tb_mips_datapath/DUT/rd

add wave -divider "CONTROL"
add wave -label RegDst    sim:/tb_mips_datapath/DUT/RegDst
add wave -label RegWrite  sim:/tb_mips_datapath/DUT/RegWrite
add wave -label ALUSrc    sim:/tb_mips_datapath/DUT/ALUSrc
add wave -label ALUop  -radix binary sim:/tb_mips_datapath/DUT/ALUop
add wave -label MemRead   sim:/tb_mips_datapath/DUT/MemRead
add wave -label MemWrite  sim:/tb_mips_datapath/DUT/MemWrite
add wave -label MemtoReg  sim:/tb_mips_datapath/DUT/MemtoReg
add wave -label PCSrc     sim:/tb_mips_datapath/DUT/PCSrc

add wave -divider "REGISTERS / ALU"
add wave -label read_data_1 -radix signed sim:/tb_mips_datapath/DUT/read_data_1
add wave -label read_data_2 -radix signed sim:/tb_mips_datapath/DUT/read_data_2
add wave -label alu_ctrl -radix binary    sim:/tb_mips_datapath/DUT/alu_ctrl
add wave -label alu_B    -radix signed    sim:/tb_mips_datapath/DUT/alu_b
add wave -label ALU_result -radix signed  sim:/tb_mips_datapath/alu_result
add wave -label Zero                      sim:/tb_mips_datapath/DUT/zero

add wave -divider "WRITE BACK"
add wave -label write_reg  -radix unsigned sim:/tb_mips_datapath/DUT/write_reg
add wave -label write_data -radix signed   sim:/tb_mips_datapath/write_back_data

add wave -divider "REGISTER FILE"
add wave -label {$1} -radix signed sim:/tb_mips_datapath/DUT/RF/registers[1]
add wave -label {$2} -radix signed sim:/tb_mips_datapath/DUT/RF/registers[2]
add wave -label {$3} -radix signed sim:/tb_mips_datapath/DUT/RF/registers[3]
add wave -label {$4} -radix signed sim:/tb_mips_datapath/DUT/RF/registers[4]
add wave -label {$8} -radix signed sim:/tb_mips_datapath/DUT/RF/registers[8]

run -all
wave zoom full
