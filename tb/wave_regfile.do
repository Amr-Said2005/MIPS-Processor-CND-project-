# ModelSim wave setup for tb_register_file
# Usage (from RTL/):  vsim -onfinish stop -do ../tb/wave_regfile.do tb_register_file
# NOTE: paths containing [] must be brace-quoted or Tcl treats them as commands.

quietly WaveActivateNextPane {} 0

add wave -divider "CLOCK / RESET"
add wave -label clk           sim:/tb_register_file/clk
add wave -label reset         sim:/tb_register_file/reset

add wave -divider "WRITE PORT (sync)"
add wave -label reg_write                      sim:/tb_register_file/reg_write
add wave -label write_reg  -radix unsigned     sim:/tb_register_file/write_reg
add wave -label write_data -radix hexadecimal  sim:/tb_register_file/write_data

add wave -divider "READ PORTS (async)"
add wave -label read_reg_1  -radix unsigned    sim:/tb_register_file/read_reg_1
add wave -label read_data_1 -radix hexadecimal sim:/tb_register_file/read_data_1
add wave -label read_reg_2  -radix unsigned    sim:/tb_register_file/read_reg_2
add wave -label read_data_2 -radix hexadecimal sim:/tb_register_file/read_data_2

add wave -divider "STORAGE (registers under test)"
add wave -label {reg0}  -radix hexadecimal {sim:/tb_register_file/uut/registers[0]}
add wave -label {reg5}  -radix hexadecimal {sim:/tb_register_file/uut/registers[5]}
add wave -label {reg10} -radix hexadecimal {sim:/tb_register_file/uut/registers[10]}
add wave -label {reg31} -radix hexadecimal {sim:/tb_register_file/uut/registers[31]}

add wave -divider "SCOREBOARD"
add wave -label error_count -radix unsigned sim:/tb_register_file/error_count

run -all
wave zoom full
