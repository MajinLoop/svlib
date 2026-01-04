import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly, NextTimeStep, Timer

import random
SEED = 666
random.seed(SEED)
ITERATIONS = 32


# --- Helpers ---
def generate_channels(channels_count): # Generate distinct channel values
    return [i + 1 for i in range(channels_count)]

def get_packed_array(channels, channels_width): # Pack channels into a single signal
    packed_channels = 0
    for i, v in enumerate(channels):
        packed_channels |= (int(v) << (i * channels_width))
    return packed_channels

async def async_reset(dut): # Helper to perform an asynchronous reset
    dut.async_rst_n.value = 0
    await RisingEdge(dut.clk)
    dut.async_rst_n.value = 1
    await RisingEdge(dut.clk)

async def clear_stage_start(dut):
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 2, unit="ns").start())

    # Get parameters
    pc_width = int(dut.PC_WIDTH.value)


    # -- Set initial input values --

    ## secuential signals
    dut.async_rst_n.value = 0

    ## Control signals
    dut.PC_source_E.value = 0b00
    dut.enable_fetch_H.value = 0b0
    dut.prediction_source_D.value = 0b0

    ## Data signals
    dut.PC_plus_4_E.value = random.randint(0, (1 << pc_width) - 1)
    dut.ALU_result_E.value = 0x2
    dut.predicted_PC_D.value = 0x3


    # Initial reset
    await async_reset(dut)
    # From here, stage is cleared and ready for testing


# --- Tests ---
@cocotb.test()
async def test_PC_counting_manually(dut):
    await clear_stage_start(dut)

    dut.enable_fetch_H.value = 0b1

    # Check PC and PC_plus_4
    assert int(dut.PC_F.value) == 0x0
    assert int(dut.PC_plus_4_F.value) == 0x4

    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.PC_F.value) == 0x4
    assert int(dut.PC_plus_4_F.value) == 0x8

    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.PC_F.value) == 0x8
    assert int(dut.PC_plus_4_F.value) == 0xC

    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.PC_F.value) == 0xC
    assert int(dut.PC_plus_4_F.value) == 0x10


@cocotb.test()
async def test_PC_counting(dut):
    await clear_stage_start(dut)

    dut.enable_fetch_H.value = 0b1

    # Check PC and PC_plus_4
    assert int(dut.PC_F.value) == 0x0
    assert int(dut.PC_plus_4_F.value) == 0x4

    pc = int(dut.PC_F.value)

    for _ in range(ITERATIONS):
        await RisingEdge(dut.clk)
        await ReadOnly()
        assert int(dut.PC_F.value) == pc + 4
        assert int(dut.PC_plus_4_F.value) == pc + 8
        pc += 4


@cocotb.test()
async def test_PC_source_E_selects_PC_plus_4_E(dut): # Verify that PC_source_E selects PC_plus_4_E correctly
    await clear_stage_start(dut)

    dut.enable_fetch_H.value = 0b1

    # Check PC and PC_plus_4
    assert int(dut.PC_F.value) == 0x0
    assert int(dut.PC_plus_4_F.value) == 0x4

    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.PC_F.value) == 0x4
    assert int(dut.PC_plus_4_F.value) == 0x8
    await NextTimeStep()

    # change PC_source_E to select PC_plus_4_E
    dut.PC_source_E.value = 0x1
    target = int(dut.PC_plus_4_E.value)

    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.PC_F.value) == target
    assert int(dut.PC_plus_4_F.value) == target + 4 

    # Keep storing from PC_plus_4_E because PC_source_E is still 0b01
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.PC_F.value) == target
    assert int(dut.PC_plus_4_F.value) == target + 4


@cocotb.test()
async def test_PC_source_E_selects_ALU_result_E(dut): # Verify that PC_source_E selects ALU_result_E correctly
    await clear_stage_start(dut)

    dut.enable_fetch_H.value = 0b1

    # Check PC and PC_plus_4
    assert int(dut.PC_F.value) == 0x0
    assert int(dut.PC_plus_4_F.value) == 0x4

    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.PC_F.value) == 0x4
    assert int(dut.PC_plus_4_F.value) == 0x8
    await NextTimeStep()

    # change PC_source_E to select PC_plus_4_E
    dut.PC_source_E.value = 0x2
    target = int(dut.ALU_result_E.value)

    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.PC_F.value) == target
    assert int(dut.PC_plus_4_F.value) == target + 4 

    # Keep storing from PC_plus_4_E because PC_source_E is still 0b01
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.PC_F.value) == target
    assert int(dut.PC_plus_4_F.value) == target + 4


@cocotb.test()
async def test_PC_source_E_selects_fixed_zero(dut): # Verify that PC_source_E selects fixed zero correctly
    await clear_stage_start(dut)

    dut.enable_fetch_H.value = 0b1

    # Check PC and PC_plus_4
    assert int(dut.PC_F.value) == 0x0
    assert int(dut.PC_plus_4_F.value) == 0x4

    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.PC_F.value) == 0x4
    assert int(dut.PC_plus_4_F.value) == 0x8
    await NextTimeStep()

    # change PC_source_E to select PC_plus_4_E
    dut.PC_source_E.value = 0x3
    target = 0

    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.PC_F.value) == target
    assert int(dut.PC_plus_4_F.value) == target + 4 

    # Keep storing from PC_plus_4_E because PC_source_E is still 0b01
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.PC_F.value) == target
    assert int(dut.PC_plus_4_F.value) == target + 4


@cocotb.test()
async def test_mux_predictor(dut): # Verify that PC_source_E selects fixed zero correctly
    await clear_stage_start(dut)

    dut.enable_fetch_H.value = 0b1

    # Check PC and PC_plus_4
    assert int(dut.PC_F.value) == 0x0
    assert int(dut.PC_plus_4_F.value) == 0x4

    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.PC_F.value) == 0x4
    assert int(dut.PC_plus_4_F.value) == 0x8
    await NextTimeStep()

    dut.prediction_source_D.value = 0x1
    dut.PC_source_E.value = 0x3 # should has no effect
    target = int(dut.predicted_PC_D.value)

    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.PC_F.value) == target
    assert int(dut.PC_plus_4_F.value) == target + 4 

    # PC_F stays still because prediction_source_D is still 0x1
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.PC_F.value) == target
    assert int(dut.PC_plus_4_F.value) == target + 4
