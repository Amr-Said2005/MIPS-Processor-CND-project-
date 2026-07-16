# MIPS-Processor-CND-project-

A single-cycle RISC-style processor in Verilog, targeting the **Terasic DE10-Standard**
(Cyclone V, `5CSXFC6D6F31C6`). Course project for the Center of Nanoelectronics and Devices.

---

## Status at a glance

| Phase | Scope | State |
|---|---|---|
| **1** | ALU & Register File | ✅ **Done** |
| **2** | Single-cycle CPU | 🟡 **In progress** — 10/14 instructions working |
| **3** | 5-stage pipeline | ⬜ Not started |
| **4** | Hazard detection & forwarding | ⬜ Not started |

**Verified in both Icarus Verilog and ModelSim ASE 10.5b — 0 errors, 0 warnings.**
The CPU has **not yet been run on hardware** (no Quartus project / netlist yet).

---

## Architecture

- **Single-cycle** datapath: fetch → decode → execute → mem → writeback
- **32-bit** datapath and instructions
- **Byte-addressed**: `PC + 4` per instruction; branch offsets shifted left 2
- **Big-endian**: MSB stored at the lowest address (both memories)
- **Register file**: 32 × 32-bit, 2 async read ports, 1 sync write port, `$zero` hardwired
- **Clock**: `ClockDivider` drops the 50 MHz board clock to **1 Hz** (one instruction/second)
  so the HEX displays are readable. `DIVISOR` is a parameter — simulation overrides it to 1.

> **Deviation from the spec:** the handout specifies a **20-bit** instruction format
> (`4/3/3/3/3/4`). This implementation uses a **32-bit** MIPS-style format
> (`op[31:26] rs[25:21] rt[20:16] rd[15:11] shamt[10:6] funct[5:0]`) with the course's
> custom opcodes. Revisit before final submission.

### Board I/O
| Output | Shows |
|---|---|
| `HEX1 HEX0` | ALU operand A (2-digit decimal) |
| `HEX3 HEX2` | ALU operand B |
| `HEX5 HEX4` | ALU result |
| `LEDR[9:0]` | control signals: `RegDst RegWrite ALUSrc MemRead MemWrite MemtoReg Branch Zero ALUop[1:0]` |

---

## Instruction set

**Opcodes** (`control_unit.v`): `R_type=000000` `ADDI=000001` `ANDI=000010` `LW=000011`
`SW=000100` `BEQ=000101` `J=000110` `JMN=000111` `SWI=001000` `PMC=001001`
**R-type `funct[5:0]`**: `add=000000` `sub=000001` `and=000010` `or=000011` `slt=000100`

| Instruction | Status | Notes |
|---|---|---|
| `add` `sub` `and` `or` `slt` | ✅ verified | R-type |
| `addi` | ✅ verified | sign-extended immediate |
| `andi` | ✅ verified | zero-extended (`Extd=0`) |
| `lw` `sw` | ✅ verified | byte-addressed, big-endian round-trip |
| `beq` | ✅ verified | taken **and** not-taken paths |
| `j` | 🔴 **not working** | no jump-target logic |
| `jmn imm(rs)` | 🔴 **not implemented** | `PC = Memory[R[rs]+imm]` (indirect jump) |
| `swi rt, imm(rs)` | 🔴 **not implemented** | `Memory[R[rs]+imm] = R[rt]`, then `R[rs] += imm` |
| `pmc (rt), imm(rs)` | 🔴 **not implemented** | `PC = Memory[R[rt]]` **and** `Memory[R[rs]+imm] = PC+4` |

---

## Repository layout

```
RTL/
  mips_top.v            board top-level (DE10 pins, KEY[0] -> active-high reset)
  mips_datapath.v       single-cycle datapath (parameterized DIVISOR)
  program_counter.v     PC register + "+4" adder + next-PC select
  instruction_memory.v  4096 B, byte-addressed, loads instruction.mem.txt
  instruction.mem.txt   test program, ONE BYTE PER LINE (MSB first)
  register_file.v       32x32, async read / sync write, async reset
  control_unit.v        opcode -> control signals
  ALUcontrol.v          ALUop + funct[5:0] -> 6-bit ALU op
  ALU.V                 add/sub/and/or/slt + Zero/Carry/Overflow/Negative
  data_memory.v         4096 B, byte-addressed, big-endian, combinational read
  sign_extend.v         Extd-controlled sign/zero extend
  Mux2to1.v             parameterized 2:1 mux
  display.v             value -> two decimal digits
  SevenSegDecoder.v     nibble -> 7-segment (active low)
  ClockDivider.v        50 MHz -> 1 Hz

tb/
  tb_mips_datapath.v    full-system trace: PC, mnemonic, HEX, LEDR, regs, memory
  wave.do               ModelSim wave setup
  ALU_tb.v  tb_CU.v  data_memory_tb.v  ALUcontrol.v   per-module testbenches
  tb_program_counter.v  STALE - tests the old PC interface, does not compile

de10_standard_pins.tcl  Quartus pin assignments for the DE10-Standard
```

---

## How to simulate

`instruction_memory` loads `instruction.mem.txt` relative to the **simulator's working
directory**, so run from `RTL/`.

**Icarus Verilog**
```bash
cd RTL
iverilog -s tb_mips_datapath -o cpu.vvp ../tb/tb_mips_datapath.v *.v *.V
vvp cpu.vvp
```

**ModelSim** (batch)
```bash
cd RTL
vlib work
vlog ../tb/tb_mips_datapath.v *.v *.V
vsim -c tb_mips_datapath -do "run -all; quit -f"
```

**ModelSim** (GUI with waves)
```bash
cd RTL
vsim -onfinish stop -do ../tb/wave.do tb_mips_datapath
```

**Quartus pin assignments**
```bash
quartus_sh -t de10_standard_pins.tcl     # top-level entity: mips_top
```

---

## What still needs to be implemented

### Phase 2 (current milestone)

1. **`j`** — add a jump-target path (`{(PC+4)[31:28], addr, 2'b00}` or the course's format).
2. **`jmn`** — `PC = Memory[R[rs]+imm]`. Needs the PC to be loadable from `mem_data`.
3. **`swi`** — writes back to **`rs`**; the RegDst mux only selects `rt`/`rd` today.
4. **`pmc`** — **hardest item.** Reads `Memory[R[rt]]` *and* writes `Memory[R[rs]+imm]`
   in the same cycle: two different addresses. `data_memory` has a single address port,
   so this needs a dual-port memory or a multi-cycle `pmc`.

   Datapath changes these imply:
   - PC mux **2-way -> 4-way**: `pc+4` / `branch_target` / `jump_target` / `mem_data`
   - RegDst mux **2-way -> 3-way** (add `rs`)
   - Data-memory write-data mux: `read_data_2` **or** `PC+4` (for `pmc`)
   - Second data-memory port (for `pmc`)

5. **Control-unit bug:** `jmn`, `swi`, `pmc` all compute `R[rs] + imm`, so they need
   `ALUop = 01` (add). `control_unit.v` currently sets `ALUop = 00` for them, which means
   *R-type funct decode* — the ALU would act on junk funct bits.

6. **Self-checking testbenches** — the spec explicitly requires testbenches that *compare*
   expected register/memory state. The current bench prints a trace but does not assert.

7. **Synthesis** — produce the flattened gate netlist, timing reports, and RTL schematic.
   None of this is done; there is no `.qpf`/`.qsf` project yet.

### Phases 3-4
5-stage pipeline (IF/ID/EX/MEM/WB) with pipeline registers, then the hazard-detection and
forwarding units with load-use stalls.

---

## Known issues / technical debt

- **Slow Quartus compile (~30 min).** `data_memory` is a 4096-byte array with a
  *combinational read* and an *async reset that clears all 4096 bytes*. It cannot map to
  M10K block RAM, so it synthesizes to ~32K flip-flops plus a huge multiplexer.
  Shrinking it (64-256 B) and dropping the mass reset should fix this.
- **Derived clock.** The CPU is clocked by a flip-flop output (`ClockDivider`), not a
  global clock buffer. Quartus will likely warn. The idiomatic fix is a *clock enable* on
  the 50 MHz domain instead of a divided clock.
- **Mixed reset polarity.** `program_counter` / `register_file` / `ClockDivider` are
  active-high; `data_memory` (`rst_a`, `rst_r`) is active-low, forcing a `~reset` in
  `mips_datapath`. Pick one convention internally.
- **`tb/tb_program_counter.v` is stale** — written against the old PC interface (no
  `pc_next`), does not compile.
- **`tb/ALUcontrol.v`** — uses `'timescale` (apostrophe) instead of `` `timescale ``, so it
  does not compile; it also assumes the old 4-bit `funct`/`aluctrl` (now 6-bit).
- **Pin numbers in `de10_standard_pins.tcl` are unverified** against the DE10-Standard
  User Manual / Terasic golden-top `.qsf`. Check before programming the board.
- **20-bit vs 32-bit** instruction format (see Architecture note above).
- **`pmc` spec ambiguity** — "store the *new* value of PC" vs the formula `PC + 4`.
  Implemented intent should be the *return address* (old `PC+4`); confirm with the
  instructor.

---

## Current test program

`RTL/instruction.mem.txt` exercises the working instructions:

| Addr | Instruction | Result |
|---|---|---|
| 0 | `addi $1,$0,5` | `$1 = 5` |
| 4 | `addi $2,$0,3` | `$2 = 3` |
| 8 | `add $3,$1,$2` | `$3 = 8` |
| 12 | `sub $4,$1,$2` | `$4 = 2` |
| 16 | `and $5,$1,$2` | `$5 = 1` |
| 20 | `or $6,$1,$2` | `$6 = 7` |
| 24 | `slt $7,$1,$2` | `$7 = 0` |
| 28 | `sw $3,0($0)` | `mem[0] = 8` |
| 32 | `lw $8,0($0)` | `$8 = 8` |
