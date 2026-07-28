# ============================================================================
#  de10_standard_pins.tcl
#  Pin assignments for the MIPS processor on the Terasic DE10-Standard
#  (Cyclone V SoC, 5CSXFC6D6F31C6)
#
#  Top-level entity: mips_top  (RTL/mips_top.v)
#
#  HOW TO RUN
#    Quartus GUI : Tools -> Tcl Scripts... -> select this file -> Run
#    Command line: quartus_sh -t de10_standard_pins.tcl
#    Then:         Processing -> Start Compilation
#
#  VERIFY THE PIN NUMBERS against the DE10-Standard User Manual or the
#  DE10_Standard_golden_top.qsf on the Terasic System CD before programming.
#  A wrong location assignment drives the wrong physical pin.
# ============================================================================

# ---- device / top level ----------------------------------------------------
set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CSXFC6D6F31C6
set_global_assignment -name TOP_LEVEL_ENTITY mips_top

# Unused pins: leave them tri-stated so nothing on the board is driven.
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

# ---- source files ----------------------------------------------------------
set_global_assignment -name VERILOG_FILE RTL/mips_top.v
set_global_assignment -name VERILOG_FILE RTL/mips_datapath.v
set_global_assignment -name VERILOG_FILE RTL/program_counter.v
set_global_assignment -name VERILOG_FILE RTL/instruction_memory.v
set_global_assignment -name VERILOG_FILE RTL/register_file.v
set_global_assignment -name VERILOG_FILE RTL/control_unit.v
set_global_assignment -name VERILOG_FILE RTL/ALUcontrol.v
set_global_assignment -name VERILOG_FILE RTL/ALU.V
set_global_assignment -name VERILOG_FILE RTL/data_memory.v
set_global_assignment -name VERILOG_FILE RTL/sign_extend.v
set_global_assignment -name VERILOG_FILE RTL/Mux2to1.v
set_global_assignment -name VERILOG_FILE RTL/display.v
set_global_assignment -name VERILOG_FILE RTL/SevenSegDecoder.v
set_global_assignment -name VERILOG_FILE RTL/ClockDivider.v

# ---- 50 MHz clock ----------------------------------------------------------
set_location_assignment PIN_AF14 -to CLOCK_50

# ---- push buttons (ACTIVE LOW). KEY[0] = reset ----------------------------
set_location_assignment PIN_AJ4  -to KEY[0]
set_location_assignment PIN_AK4  -to KEY[1]
set_location_assignment PIN_AA14 -to KEY[2]
set_location_assignment PIN_AA15 -to KEY[3]

# ---- red LEDs (control signals) -------------------------------------------
set_location_assignment PIN_AA24 -to LEDR[0]
set_location_assignment PIN_AB23 -to LEDR[1]
set_location_assignment PIN_AC23 -to LEDR[2]
set_location_assignment PIN_AD24 -to LEDR[3]
set_location_assignment PIN_AG25 -to LEDR[4]
set_location_assignment PIN_AF25 -to LEDR[5]
set_location_assignment PIN_AE24 -to LEDR[6]
set_location_assignment PIN_AF24 -to LEDR[7]
set_location_assignment PIN_AB22 -to LEDR[8]
set_location_assignment PIN_AC22 -to LEDR[9]

# ---- HEX0 : operand A, ones digit -----------------------------------------
set_location_assignment PIN_W17  -to HEX0[0]
set_location_assignment PIN_V18  -to HEX0[1]
set_location_assignment PIN_AG17 -to HEX0[2]
set_location_assignment PIN_AG16 -to HEX0[3]
set_location_assignment PIN_AH17 -to HEX0[4]
set_location_assignment PIN_AG18 -to HEX0[5]
set_location_assignment PIN_AH18 -to HEX0[6]

# ---- HEX1 : operand A, tens digit -----------------------------------------
set_location_assignment PIN_AF16 -to HEX1[0]
set_location_assignment PIN_V16  -to HEX1[1]
set_location_assignment PIN_AE16 -to HEX1[2]
set_location_assignment PIN_AD17 -to HEX1[3]
set_location_assignment PIN_AE18 -to HEX1[4]
set_location_assignment PIN_AE17 -to HEX1[5]
set_location_assignment PIN_V17  -to HEX1[6]

# ---- HEX2 : operand B, ones digit -----------------------------------------
set_location_assignment PIN_AA21 -to HEX2[0]
set_location_assignment PIN_AB17 -to HEX2[1]
set_location_assignment PIN_AA18 -to HEX2[2]
set_location_assignment PIN_Y17  -to HEX2[3]
set_location_assignment PIN_Y18  -to HEX2[4]
set_location_assignment PIN_AF18 -to HEX2[5]
set_location_assignment PIN_W16  -to HEX2[6]

# ---- HEX3 : operand B, tens digit -----------------------------------------
set_location_assignment PIN_Y19  -to HEX3[0]
set_location_assignment PIN_W19  -to HEX3[1]
set_location_assignment PIN_AD19 -to HEX3[2]
set_location_assignment PIN_AA20 -to HEX3[3]
set_location_assignment PIN_AC20 -to HEX3[4]
set_location_assignment PIN_AA19 -to HEX3[5]
set_location_assignment PIN_AD20 -to HEX3[6]

# ---- HEX4 : result, ones digit --------------------------------------------
set_location_assignment PIN_AD21 -to HEX4[0]
set_location_assignment PIN_AG22 -to HEX4[1]
set_location_assignment PIN_AE22 -to HEX4[2]
set_location_assignment PIN_AE23 -to HEX4[3]
set_location_assignment PIN_AG23 -to HEX4[4]
set_location_assignment PIN_AF23 -to HEX4[5]
set_location_assignment PIN_AH22 -to HEX4[6]

# ---- HEX5 : result, tens digit --------------------------------------------
set_location_assignment PIN_AF21 -to HEX5[0]
set_location_assignment PIN_AG21 -to HEX5[1]
set_location_assignment PIN_AF20 -to HEX5[2]
set_location_assignment PIN_AG20 -to HEX5[3]
set_location_assignment PIN_AE19 -to HEX5[4]
set_location_assignment PIN_AF19 -to HEX5[5]
set_location_assignment PIN_AB21 -to HEX5[6]

# ---- I/O standard: all of the above are 3.3-V LVTTL ------------------------
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50
foreach i {0 1 2 3} {
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY[$i]
}
foreach i {0 1 2 3 4 5 6 7 8 9} {
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[$i]
}
foreach hex {HEX0 HEX1 HEX2 HEX3 HEX4 HEX5} {
    foreach i {0 1 2 3 4 5 6} {
        set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ${hex}[$i]
    }
}

# ---- write everything out --------------------------------------------------
export_assignments
puts "DE10-Standard pin assignments applied to top-level 'mips_top'."
