# MIPS-Processor-CND-project-

A single-cycle RISC-style processor in Verilog, targeting the **Terasic DE10-Standard**
(Cyclone V, `5CSXFC6D6F31C6`). Course project for the Center of Nanoelectronics and Devices.

---

## Status at a glance

| Phase | Scope | State |
|---|---|---|
| **1** | ALU & Register File | ✅ **Done** |
| **2** | Single-cycle CPU | 🟢 **All 14/14 instructions working** — verification/report items remain |
| **3** | 5-stage pipeline | 🟡 **In progress** — ID/EX, EX/MEM, MEM/WB pipeline registers drafted; not yet wired into `mips_datapath`; `IF/ID` register and PC-stall/flush plumbing not started |
| **4** | Hazard detection & forwarding | 🟡 **In progress** — forwarding unit designed and drafted (`forwarding_unit.v`, `Mux3to1.v`), `iexecute.v` updated to consume forwarded operands; load-use hazard-detection unit and control-hazard (branch/`jmn`/`pmc`) flush logic still **not started** |

**Simulation:** Phase 1–2 verified in both Icarus Verilog and ModelSim ASE 10.5b — 0 errors.
Phase 3–4 additions below are drafted but **not yet simulated** — `mips_datapath.v` hasn't
been updated to instantiate them yet, so nothing in the "Pipelining & Forwarding" section
has been run through a testbench.

**Hardware:** full Quartus compile succeeds on the DE10-Standard and **timing is met**
(single-cycle build only — see numbers below; re-run once pipelined).

| Metric | Value |
|---|---|
| Logic utilisation | 3,871 / 41,910 ALMs (**9 %**) |
| Registers | 2,304 |
| Pins | 57 / 499 |
| Fmax (Slow 1100mV 85C) | **80.59 MHz** |
| Setup slack @ 50 MHz | **+7.69 ns** ✅ |
| Hold slack | +0.505 ns ✅ |

The CPU runs directly on the 50 MHz board clock (`CLOCK_50`).

---

## Architecture

- **Single-cycle today, pipelining underway**: fetch → decode → execute → mem → writeback
  currently execute combinationally in one cycle inside `mips_datapath`; Phase 3 work
  (below) introduces `IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB` pipeline registers to split
  this into 5 stages.
- **32-bit** datapath and instructions
- **Byte-addressed**: `PC + 4` per instruction; branch offsets shifted left 2
- **Big-endian**: MSB stored at the lowest address (both memories)
- **Register file**: 32 × 32-bit, 2 async read ports, 1 sync write port, `$zero` hardwired
- **Clock**: `mips_datapath` is clock-agnostic (testbenches drive it at full speed).
  The board wrapper `mips_top` instantiates `ClockDivider` — `cpu_clk = CLOCK_50/(2*DIVISOR)`,
  default `25_000_000` → **1 Hz** so each instruction is visible for one second.
  `tb_mips_top` overrides `DIVISOR` small to keep simulation short.
- **Memories**: instruction ROM 128 words (512 B); data RAM 128 words / 512 bytes
  (`ADDR_W` parameter). `data_memory` is dual-address (separate combinational read
  address / clocked write address) — needed by `pmc`, which reads `Memory[R[rt]]` and
  writes `Memory[R[rs]+imm]` in the same cycle.
- **Reset**: asynchronous, active-high internally; `mips_top` inverts the active-low `KEY[0]`

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
| `j` | ✅ verified | forward + backward jumps; loops confirmed running |
| `jmn imm(rs)` | ✅ verified | `PC = Memory[R[rs]+imm]` — indirect jump via `MemTargetMux` |
| `swi rt, imm(rs)` | ✅ verified | stores `R[rt]`, then `R[rs] += imm` (3-way RegDst mux) |
| `pmc (rt), imm(rs)` | ✅ verified | `PC = Memory[R[rt]]` **and** `Memory[R[rs]+imm] = PC+4` (dual-address memory) |

---

## Pipelining & Forwarding (Phase 3/4 design)

This section documents the pipeline-register and forwarding design drafted for Phases
3–4. **Status: designed and drafted, not yet integrated into `mips_datapath.v` or
simulated** — `mips_datapath.v` itself hasn't been reviewed yet, so the wiring below
describes the target design, not verified behavior. Treat this section as a spec for
the next integration pass, not a changelog of tested work.

### New files (drafted, not yet added to `RTL/`)

| File | Role |
|---|---|
| `Mux3to1.v` | Parameterized 3-to-1 mux (`Sel = 00/01/10`), used for both forwarding paths |
| `forwarding_unit.v` | Combinational hazard comparator; outputs `ForwardA`/`ForwardB` |
| `id_ex_reg.v` | ID/EX pipeline register — datapath values + control signals, with `stall`/`flush` inputs |
| `ex_mem_reg.v` | EX/MEM pipeline register — ALU result, memory addresses/data, control signals |
| `mem_wb_reg.v` | MEM/WB pipeline register — memory read data, ALU result, write-back control |

**Still needed, not yet drafted:** `if_id_reg.v` and a hazard-detection unit (load-use
stall generation + `beq`/`j`/`jmn`/`pmc` control-hazard flush logic).

### `iexecute.v` changes

`iexecute.v` was previously a pure single-cycle module (raw `read_data_1`/`read_data_2`
in, single `store_data` output). Drafted changes:

- **New inputs**: `ForwardA[1:0]`, `ForwardB[1:0]` (from `forwarding_unit`),
  `ex_mem_alu_result` (EX/MEM forward source), `mem_wb_write_data` (MEM/WB forward
  source).
- **Two new internal `Mux3to1` instances** (`ForwardAMux`, `ForwardBMux`), resolved
  *before* any existing logic consumes `read_data_1`/`read_data_2`. Their outputs,
  `fwd_read_data_1` / `fwd_read_data_2`, replace the raw register-file values
  everywhere downstream: into `ALU_UNIT.A`, into `ALUSrcMux.A` (feeding `ALU_UNIT.B`),
  and into the memory-side signals below.
- **`store_data` output split into three**, to correctly separate what used to be one
  combined signal:
  - `mem_write_addr` — always `alu_result` (`R[rs]+imm`); covers `sw`, `swi`, and
    `pmc`'s return-address store.
  - `mem_write_data` — `pc_plus4` when `pmc=1` (return address), else
    `fwd_read_data_2` (the `sw`/`swi` store value). *(This also fixes a latent bug:
    the original single `store_data = read_data_2` never actually supplied `PC+4` for
    `pmc`, even though the spec table requires it.)*
  - `mem_read_addr` — `fwd_read_data_2` when `pmc=1` (`Memory[R[rt]]` target for the PC
    load), else `alu_result` (`lw`/`jmn` address).

### Forwarding logic

Standard 2-source, 2-hazard-level comparator, EX/MEM prioritized over MEM/WB:

```
if      (EX/MEM.RegWrite && EX/MEM.write_reg != 0 && EX/MEM.write_reg == ID/EX.rs) ForwardA = 10
else if (MEM/WB.RegWrite && MEM/WB.write_reg != 0 && MEM/WB.write_reg == ID/EX.rs) ForwardA = 01
else                                                                               ForwardA = 00
(ForwardB checked the same way against ID/EX.rt)
```

### How the custom instructions interact with forwarding

The ISA's three non-MIPS instructions (`jmn`, `swi`, `pmc`) each needed checking against
the forwarding design individually:

- **`jmn imm(rs)`** — address is `R[rs]+imm`, computed by the ALU. Covered by standard
  `ForwardA`; no special case.
- **`swi rt, imm(rs)`** — writes back to `rs` (via the existing `SwiDstMux`), not `rt`.
  Forwarding *out* of this instruction works unmodified — the forwarding unit compares
  against whatever `write_reg` resolves to, regardless of which mux produced it. The
  instruction's own read of `rs` (for its address) against its own write of `rs` (the
  post-increment) is intra-instruction, not an inter-instruction hazard, so it needs no
  extra logic.
- **`pmc (rt), imm(rs)`** — the one real special case. `Memory[R[rt]]` (the new PC) is
  read directly from `R[rt]`, **never through the ALU**, so plain ALU-input forwarding
  can't fix a hazard on it. The fix: because `read_data_2` (the `rt`-sourced value) is
  already reused for store data in this datapath, routing `mem_read_addr` off
  `fwd_read_data_2` (the *forwarded* value) rather than raw `read_data_2` makes the same
  `ForwardB` mux transparently correct for the R-type second operand, the `sw`/`swi`
  store value, **and** `pmc`'s jump target — one mux, three consumers, no `pmc`-specific
  hazard path.

### Open items before this is real

1. `mips_datapath.v` needs review — not yet uploaded/seen, so it's unknown whether it's
   still a flat single-cycle chain (matching `iexecute.v`'s old header comment) or has
   partial pipeline structure already.
2. `if_id_reg.v` hasn't been drafted.
3. Load-use hazard detection (stall when `ID/EX.MemRead` and the stalled instruction
   needs that register) is not implemented — forwarding alone cannot fix this case.
4. Control-hazard handling for `beq` (resolved in EX per `iexecute.v`'s `PCSrc`), and
   for `jmn`/`pmc` (resolved even later, in MEM, since their target comes from
   `data_memory`) is not implemented — these need flush logic beyond what
   `id_ex_reg.v`'s `flush` input currently stubs out.
5. None of the five new files have testbenches yet. Per the Phase 4 deliverables,
   `forwarding_unit.v` and `Mux3to1.v` are both good candidates for standalone
   self-checking testbenches (drive specific `rs`/`rt`/`write_reg` combinations,
   assert `ForwardA`/`ForwardB`) before wiring into the full datapath.

---

## Repository layout

```
RTL/
  mips_top.v            board top-level (DE10 pins, KEY[0] -> active-high reset)
  mips_datapath.v       single-cycle datapath (parameterized DIVISOR) -- pipeline
                         integration (below) not yet applied
  program_counter.v     PC register + "+4" adder + next-PC select
  instruction_memory.v  word ROM, 128 instrs, loads instruction.mem.txt
  instruction.mem.txt   test program, ONE BYTE PER LINE (MSB first)
  register_file.v       32x32, async read / sync write, async reset
  control_unit.v        opcode -> control signals
  ALUcontrol.v          ALUop + funct[5:0] -> 6-bit ALU op
  ALU.V                 add/sub/and/or/slt + Zero/Carry/Overflow/Negative
  data_memory.v         512 B, dual-address, byte-addressed, big-endian, combinational read
  sign_extend.v         Extd-controlled sign/zero extend
  Mux2to1.v             parameterized 2:1 mux
  display.v             value -> two decimal digits
  SevenSegDecoder.v     nibble -> 7-segment (active low)
  ClockDivider.v        50 MHz -> 1 Hz

  -- drafted, Phase 3/4, not yet added --
  Mux3to1.v              parameterized 3:1 mux (forwarding select)
  forwarding_unit.v      EX/MEM & MEM/WB hazard comparator -> ForwardA/ForwardB
  id_ex_reg.v            ID/EX pipeline register (stall/flush inputs)
  ex_mem_reg.v           EX/MEM pipeline register
  mem_wb_reg.v           MEM/WB pipeline register
  if_id_reg.v            NOT YET DRAFTED
  hazard_detection_unit.v NOT YET DRAFTED (load-use stall + control-hazard flush)

tb/
  tb_mips_datapath.v    full-system trace: PC, mnemonic, HEX, LEDR, regs, memory
  wave.do               ModelSim wave setup
  ALU_tb.v  tb_CU.v  data_memory_tb.v  ALUcontrol.v   per-module testbenches
  tb_program_counter.v  STALE - tests the old PC interface, does not compile

de10_standard_pins.tcl  Quartus pin assignments for the DE10-Standard
```

---

## Testbenches

The spec requires **self-checking** testbenches that *compare* expected register/memory
state — not just dump waveforms. Status:

| Testbench | Covers | Compiles | Self-checking | State |
|---|---|---|---|---|
| `ALU_tb.v` | `ALU` | ✅ | ✅ prints PASS/FAIL | ✅ **Done** — 11 cases incl. signed SLT, carry, overflow |
| `tb_mips_top.v` | **board top** (`mips_top`) | ✅ | ✅ 7 checks | ✅ **Done** — drives only `CLOCK_50`/`KEY`, observes only `HEX`/`LEDR`; prints a per-step "board view" table for cross-referencing waveforms with the physical FPGA; verifies the frozen halt state |
| `tb_register_file.v` | `register_file` | ✅ | ✅ error counter | ✅ **Done** — reset-clear, write/read, `$zero` immutability, write-enable gating, dual async reads; passes in Icarus **and** ModelSim |
| `tb_mips_datapath.v` | **full system** | ✅ | ❌ trace only | 🟡 runs the whole program + dumps regs/memory, but **asserts nothing** |
| `data_memory_tb.v` | `data_memory` | ✅ | ❌ waveform only | 🟡 no checks; also predates the **big-endian** switch — re-verify |
| `tb_CU.v` | `control_unit` | ❌ | ✅ (47 checks) | 🔴 **broken**: line 1 uses `'timescale` (apostrophe) instead of `` `timescale `` |
| `ALUcontrol.v` | `ALUcontrol` | ❌ | ✅ (17 checks) | 🔴 **broken**: same apostrophe bug **+** assumes old 4-bit `funct`/`aluctrl` (now 6-bit) |
| `tb_program_counter.v` | `program_counter` | ⚠️ | ❌ | 🔴 **stale**: only wires `.clk/.reset/.pc`; misses `pc_src`/`branch_target`/`pc_plus4`, so the PC is driven by floating inputs |

### Testbenches still needed

**Fix the broken ones (quick wins — the logic is already written):**
1. `tb_CU.v` — change `'timescale` → `` `timescale ``
2. `ALUcontrol.v` — same fix **+** widen `funct`/`aluctrl` to `[5:0]`; rename to `ALUcontrol_tb.v`
3. `tb_program_counter.v` — rewrite against the current PC interface

**Make existing ones self-checking (required by the spec):**
4. `tb_mips_datapath.v` — add expected-vs-actual assertions with a PASS/FAIL summary
5. `data_memory_tb.v` — add checks, including **big-endian byte order**

**Modules with no testbench at all:**
6. `sign_extend` — `Extd` sign vs zero extend
7. `instruction_memory` — word ROM indexing / init contents
8. `ClockDivider` — division ratio, reset behaviour
9. `Mux2to1`, `display`, `SevenSegDecoder` — small, low priority
10. `Mux3to1`, `forwarding_unit` — new, Phase 4 (see above)

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

**Quartus (hardware)**
```bash
quartus_sh -t de10_standard_pins.tcl     # pin assignments; top-level = mips_top
```
The Quartus project lives outside this repo at
`FPGA_WORKSPACE/quartus_projects/MIPS_processor/`. It needs `mips_timing.sdc`
(50 MHz constraint) — **without an `.sdc`, Quartus assumes a 1 GHz clock and every
timing report fails.** Program the board with `output_files/*.sof` via the
Programmer (hardware: `DE-SoC`).

### Writing a test program
`RTL/instruction.mem.txt` holds **one 32-bit binary word per line**; line *N* is the
instruction at byte address *N*×4.

> **`j` takes a WORD address, not a byte address.** To jump to byte 16, encode `4`.
> Getting this wrong fails silently — the PC just lands somewhere unexpected.

A loop looks like:
```asm
     addi $1,$0,0     # 0  (w0)  counter = 0
     addi $1,$1,1     # 4  (w1)  counter++      <-- loop top
     j    1           # 8  (w2)  jump to word 1 = byte 4
```

---

## What still needs to be implemented

### Phase 2

All 14 instructions are implemented. What remains is verification and report work:

1. **Self-checking testbenches** — the spec explicitly requires testbenches that *compare*
   expected register/memory state. The full-system bench still only prints a trace
   (the `jmn`/`swi`/`pmc` bring-up test was written self-checking — fold that style back
   into `tb_mips_datapath.v`).
2. **Netlist + RTL schematic** — synthesis and timing are done; the flattened gate netlist
   and schematic capture for the report are not.
3. **Re-run the Quartus compile** — the datapath changed (dual-address memory, two new
   muxes); resource/timing numbers in this README are from the 11-instruction build.

### Phase 3 (current milestone)

1. Review `mips_datapath.v` and decide how much of the existing single-cycle chain
   carries over vs. needs restructuring.
2. Draft `if_id_reg.v` (not yet started).
3. Wire `id_ex_reg.v`, `ex_mem_reg.v`, `mem_wb_reg.v` into `mips_datapath.v`, replacing
   the direct stage-to-stage connections.
4. Decide where branches resolve (currently EX, per `iexecute.v`'s `PCSrc`) and document it.
5. Re-run Quartus once the pipeline is wired — expect the resource/timing numbers above
   to change materially.

### Phase 4

1. `forwarding_unit.v` and the `iexecute.v` forwarding muxes are drafted (see
   "Pipelining & Forwarding" above) — **integrate into `mips_datapath.v` and simulate.**
2. Draft and implement the hazard-detection unit (load-use stall).
3. Draft control-hazard flush logic for `beq`/`j`/`jmn`/`pmc`, especially the
   later-than-usual resolution point for `jmn`/`pmc` (MEM stage, not EX).
4. Test programs specifically exercising forwarding and load-use stalls (spec examples:
   `add`→`sub` EX-forwarding chain; `lw`→`add` load-use stall).
5. Waveforms showing `ForwardA`/`ForwardB` mux selection and inserted bubbles.

---

## Known issues / technical debt

- **Board demo shows only the final state.** At 50 MHz the program finishes in ~560 ns;
  the halt loop then freezes the displays at `08 beq 08 = 00`. You cannot *watch*
  execution — for that, add single-stepping from a `KEY` (edge-detected clock enable).
- **The divided CPU clock is a data-routed clock.** `mips_top` clocks the CPU from the
  `ClockDivider` flip-flop output, which won't ride the global clock network — expect a
  Quartus warning. Harmless at 1 Hz; the textbook fix is a clock *enable* on `CLOCK_50`.
- **The `.sdc` lives outside the repo** (`quartus_projects/MIPS_processor/mips_timing.sdc`).
  Without it Quartus defaults every clock to 1 GHz and *all* timing reports show red.
  Worth copying into the repo so the constraints are version-controlled with the RTL.
- **Mixed reset polarity.** `program_counter` / `register_file` are active-high;
  `data_memory` (`rst_a`, `rst_r`) is active-low, forcing a `~reset` in `mips_datapath`.
  Pick one convention internally.
- **`RTL/mips_top.v.bak`** — stray backup file, should be deleted.
- **`display` infers 9 `lpm_divide` blocks** (the `/10` and `%10`, three instances). Works
  and fits, but a lookup table would be cheaper if area ever matters.
- **Two testbenches don't compile** — `tb_CU.v` and `ALUcontrol.v` both start with
  `'timescale` (apostrophe) instead of `` `timescale ``. Their *contents* are good
  (47 and 17 checks respectively); it's a one-character fix each. `ALUcontrol.v`
  additionally assumes the old 4-bit `funct`/`aluctrl`.
- **`tb/tb_program_counter.v` is stale** — only connects `.clk/.reset/.pc`, so the PC's
  `pc_src`/`branch_target` inputs float.
- **Only 1 of 6 testbenches is self-checking** (`ALU_tb.v`). See the Testbenches section.
- **Pin numbers in `de10_standard_pins.tcl` are unverified** against the DE10-Standard
  User Manual / Terasic golden-top `.qsf`. Check before programming the board.
- **20-bit vs 32-bit** instruction format (see Architecture note above).
- **`pmc` spec ambiguity** — the handout says "store the *new* value of PC" but writes
  the formula `Memory[R[rs]+imm] = PC + 4`. Implemented as the **return address**
  (address of the pmc instruction + 4), which is what makes a call/return usable.
  Confirm with the instructor.
- **`mips_datapath.v` not yet reviewed against the Phase 3/4 design above** — the
  pipeline register / forwarding wiring described in "Pipelining & Forwarding" is a
  target design, drafted in isolation, and needs to be reconciled with whatever
  `mips_datapath.v` currently contains before it can be trusted.

---

## Current test program

`RTL/instruction.mem.txt` exercises **all 14 instructions** (28 words), ending in a
halt loop (`beq $9,$9,-1` — also proves a **backward** branch offset) so the HEX
displays freeze showing `08 beq 08 = 00` instead of running off into zeroed ROM.
"trap" instructions (`addi $10,$0,99`) sit in the shadow of every jump/branch —
if `$10` ever reads 99, a control-flow transfer failed to skip it.

| Bytes | Section | Proves |
|---|---|---|
| 0–28 | `addi addi add sub and or slt andi` | all arithmetic/logic |
| 32–36 | `sw $3,0($0)` / `lw $9,0($0)` | memory round-trip (`$9=8`) |
| 40–48 | `beq` ×2 + trap | not-taken **and** taken paths |
| 52–56 | `j 15` + trap | direct jump |
| 60–72 | `sw` target, `jmn 4($0)` + trap | indirect jump via memory |
| 76–80 | `swi $6,8($12)` | store + post-increment (`mem[28]=7`, `$12=28`) |
| 84–100 | setup, `pmc ($14),16($0)` + trap | call via memory + return addr saved |
| 104 | `addi $15,$0,1` | pmc landed |
| 108 | `beq $9,$9,-1` | halt loop + backward branch |

Expected final state (all verified, 21/21 checks):
```
$1=5 $2=3 $3=8 $4=2 $5=1 $6=7 $7=0 $8=4 $9=8 $10=0
$11=76 $12=28 $13=104 $14=12 $15=1
mem[0]=8 mem[4]=76 mem[12]=104 mem[16]=100 mem[28]=7   PC halted at 108
```
