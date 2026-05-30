# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


async def load_mem(dut, addr, data):

    # prog_mode = 1
    dut.ui_in.value = (addr << 4) | 0x01

    dut.uio_in.value = data

    # load_ram pulse
    dut.ui_in.value |= (1 << 3)

    await ClockCycles(dut.clk, 1)

    dut.ui_in.value &= ~(1 << 3)

    await ClockCycles(dut.clk, 1)

@cocotb.test()
async def test_project(dut):

    dut._log.info("Starting SAP CPU Test")

    # 100 kHz clock
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # ------------------------------------
    # Reset
    # ------------------------------------

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    dut.rst_n.value = 0

    await ClockCycles(dut.clk, 10)

    dut.rst_n.value = 1

    await ClockCycles(dut.clk, 5)

    dut._log.info("Loading Program")

    # ------------------------------------
    # Fibonacci Program
    # ------------------------------------

    await load_mem(dut, 0, 0b01010000)   # LDI 0
    await load_mem(dut, 1, 0b01001110)   # STA 14

    await load_mem(dut, 2, 0b01010001)   # LDI 1
    await load_mem(dut, 3, 0b01001101)   # STA 13

    await load_mem(dut, 4, 0b00011101)   # LDA 13
    await load_mem(dut, 5, 0b00101110)   # ADD 14
    await load_mem(dut, 6, 0b01111111)   # JC 15
    await load_mem(dut, 7, 0b11100000)   # OUT

    await load_mem(dut, 8, 0b01001101)   # STA 13
    await load_mem(dut, 9, 0b00111110)   # SUB 14
    await load_mem(dut, 10, 0b01001110)  # STA 14
    await load_mem(dut, 11, 0b01100100)  # JMP 4

    await load_mem(dut, 13, 0x00)
    await load_mem(dut, 14, 0x00)

    await load_mem(dut, 15, 0b11110000)  # HLT

    dut._log.info("Program Loaded")

    # ------------------------------------
    # Start CPU
    # ------------------------------------

    dut.ui_in.value |= (1 << 1)

    await ClockCycles(dut.clk, 2)

    dut.ui_in.value &= ~(1 << 1)

    dut._log.info("CPU Started")

    # ------------------------------------
    # Execution Loop
    # ------------------------------------

    halted = False

    for cycle in range(800):

        await ClockCycles(dut.clk, 1)

        uo = dut.uo_out.value.integer

        hlt = (uo >> 6) & 1
        inp_req = (uo >> 7) & 1

        pc = (uo >> 2) & 0xF

        if cycle % 10 == 0:
            dut._log.info(
                f"Cycle={cycle}  PC={pc:X}  HLT={hlt}  INP_REQ={inp_req}"
            )

        # Optional input support
        if inp_req:

            dut._log.info("Input requested")

            dut.uio_in.value = 0x05

            dut.ui_in.value |= (1 << 2)

            await ClockCycles(dut.clk, 1)

            dut.ui_in.value &= ~(1 << 2)

        if hlt:
            halted = True
            dut._log.info("CPU Halted")
            break

    assert halted, "CPU never reached HLT instruction"

    dut._log.info("Test Completed Successfully")