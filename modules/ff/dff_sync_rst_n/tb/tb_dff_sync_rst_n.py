import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ReadOnly, NextTimeStep

import random
SEED = 666
random.seed(SEED)


# Helpers
# Helper to perform a synchronous reset
async def sync_reset(dut):
    dut.sync_rst_n.value = 0
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.q.value) == 0
    await NextTimeStep()
    dut.sync_rst_n.value = 1


# Tests
@cocotb.test()
async def test_store_min(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ns").start())
    value = 0

    dut.data.value = 0

    await sync_reset(dut) # Initial reset

    dut.data.value = value

    # Can't store until posedge
    prev = int(dut.q.value)
    await FallingEdge(dut.clk)
    assert int(dut.q.value) == prev

    # Store
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.q.value) == value


@cocotb.test()
async def test_store_random(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ns").start())
    value = random.randint(0, (1 << len(dut.data)) - 1)

    dut.data.value = 0

    await sync_reset(dut) # Initial reset

    dut.data.value = value

    # Can't store until posedge
    prev = int(dut.q.value)
    await FallingEdge(dut.clk)
    assert int(dut.q.value) == prev

    # Store
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.q.value) == value


@cocotb.test()
async def test_store_max(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ns").start())
    value = (1 << len(dut.data)) - 1

    dut.data.value = 0

    await sync_reset(dut) # Initial reset

    dut.data.value = value

    # Can't store until posedge
    prev = int(dut.q.value)
    await FallingEdge(dut.clk)
    assert int(dut.q.value) == prev

    # Store
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.q.value) == value


@cocotb.test()
async def test_sync_reset(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ns").start())
    value = random.randint(0, (1 << len(dut.data)) - 1)

    dut.data.value = 0

    await sync_reset(dut) # Initial reset

    dut.data.value = value

    # Should store
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.q.value) == value
    await NextTimeStep()

    dut.sync_rst_n.value = 0

    # Should not reset until next posedge
    prev = int(dut.q.value) 
    await FallingEdge(dut.clk)
    assert int(dut.q.value) == prev

    # Should reset
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.q.value) == 0


@cocotb.test()
async def rewrite(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ns").start())
    value = random.randint(0, (1 << len(dut.data)) - 1)

    dut.data.value = 0

    await sync_reset(dut) # Initial reset

    dut.data.value = value

    # Store
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.q.value) == value
    await NextTimeStep()

    dut.data.value = value + 1

    # Store
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.q.value) == value + 1


@cocotb.test()
async def store_while_rst(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ns").start())
    value = random.randint(0, (1 << len(dut.data)) - 1)

    dut.data.value = 0

    await sync_reset(dut) # Initial reset

    dut.data.value = value

    # Store
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.q.value) == value
    await NextTimeStep()

    dut.sync_rst_n.value = 0
    dut.data.value = value + 1

    # Store
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.q.value) == 0


@cocotb.test()
async def store_in_negedge(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ns").start())
    value = random.randint(0, (1 << len(dut.data)) - 1)

    dut.data.value = 0

    await sync_reset(dut) # Initial reset

    dut.data.value = value

    # Should not store
    prev = int(dut.q.value)
    await FallingEdge(dut.clk)
    assert int(dut.q.value) == prev

    # Should store
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.q.value) == value
