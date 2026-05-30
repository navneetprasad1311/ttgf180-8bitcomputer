## How it works

This project implements a custom 8-bit microprocessor inspired by simple accumulator-based CPUs.

The processor contains:

- 8-bit Accumulator Register (A)
- 8-bit B Register
- 4-bit Program Counter (PC)
- 4-bit Memory Address Register (MAR)
- Instruction Register (IR)
- Arithmetic Logic Unit (ALU)
- Carry and Zero Flag Register
- 16-byte RAM
- Input and Output Registers

The processor executes instructions using a multi-cycle control unit.

Supported instructions include:

| Instruction | Description |
|-------------|-------------|
| NOP | No operation |
| LDA | Load accumulator from memory |
| STA | Store accumulator to memory |
| LDI | Load immediate value |
| ADD | Add memory value |
| SUB | Subtract memory value |
| ADI | Add immediate value |
| SUI | Subtract immediate value |
| XRA | Bitwise XOR |
| ANA | Bitwise AND |
| JMP | Unconditional jump |
| JC | Jump if carry flag is set |
| JZ | Jump if zero flag is set |
| INP | Read external input |
| OUT | Write accumulator to output register |
| HLT | Halt program execution |

Before execution, the RAM can be programmed externally using the address and data inputs. After loading the program, the processor fetches, decodes, and executes instructions from RAM.

The current program counter value, halt status, and input request status are available on the output pins for debugging.

## How to test

### Programming Mode

Set `prog_mode = 1` -> `ui_in[0] = 1`

1. Place the RAM address on `ui_in[7:4]`.
2. Assert `load_ram` using `ui_in[3]`.
3. Place the program byte on `uio_in[7:0]`.
4. Repeat for all memory locations required by the program.

### Run Mode

Set `prog_mode = 0` -> `ui_in[0] = 0`

1. Assert the `start` signal using `ui_in[1]`.
2. The processor begins executing instructions from address 0.
3. Monitor:
   - `uo_out[7]` : Input request signal
   - `uo_out[6]` : Halt indicator
   - `uo_out[5:2]` : Program counter display

### External Input

When `uo_out[7]` becomes high:

1. Place an 8-bit input value on `uio_in[7:0]`.
2. Assert `inp_loaded` using `ui_in[2]`.
3. Execution resumes automatically.

### Output

The OUT instruction transfers the accumulator value to the output register.

The output register value appears on `uio_out[7:0]`.

## External hardware

No external hardware is required.

For easier testing, the following may be connected:

- DIP switches or push buttons for RAM programming and control inputs
- LEDs connected to `uo_out` and `uio_out`
- Logic analyzer for observing processor execution and memory operations
