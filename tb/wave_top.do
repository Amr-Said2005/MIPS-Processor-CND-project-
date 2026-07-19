# ModelSim wave setup for tb_mips_top (board-level cross-reference bench)
# Usage (from RTL/):  vsim -onfinish stop -do ../tb/wave_top.do tb_mips_top

quietly WaveActivateNextPane {} 0

add wave -divider "BOARD INPUTS"
add wave -label CLOCK_50           sim:/tb_mips_top/CLOCK_50
add wave -label KEY  -radix binary sim:/tb_mips_top/KEY

add wave -divider "CPU CLOCK (one edge = one board step)"
add wave -label cpu_clk            sim:/tb_mips_top/DUT/cpu_clk

add wave -divider "BOARD OUTPUTS: HEX (7-seg patterns, active-low)"
add wave -label {HEX5 res.tens} -radix binary sim:/tb_mips_top/HEX5
add wave -label {HEX4 res.ones} -radix binary sim:/tb_mips_top/HEX4
add wave -label {HEX3 B.tens}   -radix binary sim:/tb_mips_top/HEX3
add wave -label {HEX2 B.ones}   -radix binary sim:/tb_mips_top/HEX2
add wave -label {HEX1 A.tens}   -radix binary sim:/tb_mips_top/HEX1
add wave -label {HEX0 A.ones}   -radix binary sim:/tb_mips_top/HEX0

add wave -divider "BOARD OUTPUTS: LEDR (control signals)"
add wave -label LEDR -radix binary sim:/tb_mips_top/LEDR

add wave -divider "INTERNAL (for correlating steps)"
add wave -label pc          -radix unsigned    sim:/tb_mips_top/DUT/CPU/pc
add wave -label instruction -radix hexadecimal sim:/tb_mips_top/DUT/CPU/instruction
add wave -label alu_result  -radix signed      sim:/tb_mips_top/DUT/CPU/alu_result

run -all
wave zoom full
