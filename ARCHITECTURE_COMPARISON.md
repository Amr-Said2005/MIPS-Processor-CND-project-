# Datapath Architecture — Local vs Remote (branch `First_iteration`)

**TL;DR:** Our two copies of `First_iteration` have diverged into **two different architectures**, not
incremental versions of the same one. A plain `git merge` would be messy and mostly meaningless. We need to
pick ONE approach before merging. This doc lists the differences and the decisions to make.

Compared: local working copy vs a fresh clone of `origin/First_iteration` (HEAD `ca2cdad`).

---

## 1. The core difference: where does the control/glue live?

| | **Local** | **Remote** |
|---|---|---|
| `mips_datapath` | **Self-contained CPU** — instantiates control unit, muxes, sign-extend, displays; generates all control signals internally | **Datapath only** — control signals (`RegDst`, `RegWrite`, `ALUSrc`, `ALUOp`, `alu_ctrl`, …) are exposed as **top-level input ports**, wired up in a higher-level module elsewhere |
| Muxes | Separate `Mux2to1` module (parameterized), instantiated 3× | Not present as a module (inline / external) |
| Sign extend | Separate `sign_extend` module | Not present |
| Status | Elaborates + simulates correctly end-to-end | `mips_datapath.v` currently has **syntax errors** (see §4) |

This is the main decision: **one integrated CPU module**, or **a datapath with control driven from a parent module**.

## 2. ALU encoding: 4-bit vs 6-bit

| | Local | Remote |
|---|---|---|
| ALU control width | **4-bit** (`ALUControl[3:0]`) | **6-bit** (`alu_ctrl[5:0]`) |
| Op codes | `ADD=0000 SUB=0001 AND=0010 OR=0011 SLT=0100` | `ADD=000000 … SLT=000100` |
| Port naming | `ALUcontrol`, `aluOP`, `ALUControl` | `alu_control`, `ALUop`, `alu_ctrl` (snake_case) |

Good news: **the decode logic is identical** — both use `ALUop` = `00`=R-type, `01`=add, `10`=sub, `11`=and.
Only the **bit width and names** differ. Easy to unify once we agree on width (4-bit is enough for 5 ops; 6-bit
leaves room to grow).

## 3. File set

| File | Local | Remote | Notes |
|---|---|---|---|
| `control_unit.v` | ✔ | ✔ | **identical** |
| `SevenSegDecoder.v` | ✔ | ✔ | **identical** |
| ALU control | `ALUcontrol.v` | `alu_control.v` | renamed + rewritten |
| `Mux2to1.v` | ✔ | — | local only |
| `sign_extend.v` | ✔ | — | local only |
| `display.v` | ✔ | — | local only (decimal HEX display) |
| `ALU.V` | 4-bit | 6-bit | differs |
| `mips_datapath.v` | integrated | ports-exposed | ~fully different |
| `register_file.v`, `data_memory.v`, `program_counter.v`, `instruction_memory.v`, `instruction.mem.txt` | — | — | all differ in details |

## 4. Issues to fix on the REMOTE regardless of which architecture we pick

- `mips_datapath.v`: missing commas in the `alu_control` instantiation (`.ALUop(ALUOp)` / `.funct(funct)`
  with no comma) → will not compile.
- Check `control_unit` port name: remote instantiates `.RegDest(...)` — must match the actual port spelling.

## 5. Decisions we need to make together

1. **Integrated CPU vs datapath-with-external-control?** (biggest one)
2. **ALU control width: 4-bit or 6-bit?**
3. **Naming convention:** `snake_case` (`alu_control`, `alu_ctrl`) vs mixed. Recommend snake_case everywhere.
4. **Keep the local-only modules?** `Mux2to1`, `sign_extend`, `display` are working and reusable.
5. **Whose `register_file` / `data_memory` / `program_counter` do we keep** (they all differ)?

## 6. Suggested path

- Agree on **one** `mips_datapath` structure (recommend the self-contained one — it's verified running:
  it executes R-type, `addi`, `sw`/`lw` and writes the correct register/memory values).
- Standardize the ALU pair on one width + snake_case names.
- Fix the remote compile errors in §4.
- Then have ONE person integrate into a single branch, rather than auto-merging.

_Reference: full remote clone is at `../MIPS-Processor-CND-project--REMOTE/` for side-by-side viewing._
