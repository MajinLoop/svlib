import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer

import random
SEED = 666
random.seed(SEED)


@cocotb.test()
async def store_min(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ns").start())
    dut.async_rst_n.value = 0
    dut.data.value = 0
    await Timer(1, "ns")

    value = 0

    dut.async_rst_n.value = 1
    await RisingEdge(dut.clk)
        
    dut.data.value = value

    # Store
    await RisingEdge(dut.clk)
    await Timer(1, "ps")
    assert int(dut.q.value) == value


@cocotb.test()
async def store_random(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ns").start())
    dut.async_rst_n.value = 0
    dut.data.value = 0
    await Timer(1, "ns")

    value = random.randint(0, (1 << len(dut.data)) - 1)

    dut.async_rst_n.value = 1
    await RisingEdge(dut.clk)
        
    dut.data.value = value

    # Store
    await RisingEdge(dut.clk)
    await Timer(1, "ps")
    assert int(dut.q.value) == value


@cocotb.test()
async def store_max(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ns").start())
    dut.async_rst_n.value = 0
    dut.data.value = 0
    await Timer(1, "ns")

    value = (1 << len(dut.data)) - 1

    dut.async_rst_n.value = 1
    await RisingEdge(dut.clk)
        
    dut.data.value = value

    # Store
    await RisingEdge(dut.clk)
    await Timer(1, "ps")
    assert int(dut.q.value) == value


@cocotb.test()
async def fall_reset(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ns").start())
    dut.async_rst_n.value = 0
    dut.data.value = 0
    await Timer(1, "ns")

    value = 1

    dut.async_rst_n.value = 1
    await RisingEdge(dut.clk)
        
    dut.data.value = value

    await RisingEdge(dut.clk)
    await Timer(1, "ps")

    dut.async_rst_n.value = 0

    await FallingEdge(dut.clk)
    await Timer(1, "ps")


    assert int(dut.q.value) == 0


@cocotb.test()
async def rise_reset(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ns").start())
    dut.async_rst_n.value = 0
    dut.data.value = 0
    await Timer(1, "ns")

    value = 1

    dut.async_rst_n.value = 1
    await RisingEdge(dut.clk)
        
    dut.data.value = value

    await RisingEdge(dut.clk)
    await Timer(1, "ps")

    await FallingEdge(dut.clk)
    await Timer(1, "ps")

    dut.async_rst_n.value = 0

    await RisingEdge(dut.clk)
    await Timer(1, "ps")
    assert int(dut.q.value) == 0


@cocotb.test()
async def rewrite(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ns").start())
    dut.async_rst_n.value = 0
    dut.data.value = 0
    await Timer(1, "ns")

    value = random.randint(0, (1 << len(dut.data)) - 1)
    dut.async_rst_n.value = 1

    await RisingEdge(dut.clk)
        
    dut.data.value = value

    await RisingEdge(dut.clk)
    await Timer(1, "ps")
    assert int(dut.q.value) == value

    dut.data.value = value + 1

    await RisingEdge(dut.clk)
    await Timer(1, "ps")
    assert int(dut.q.value) == value + 1


@cocotb.test()
async def store_while_rst(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ns").start())
    dut.async_rst_n.value = 0
    dut.data.value = 0
    await Timer(1, "ns")

    value = random.randint(0, (1 << len(dut.data)) - 1)
    dut.async_rst_n.value = 0

    await RisingEdge(dut.clk)
        
    dut.data.value = value

    # Store should not happen
    await RisingEdge(dut.clk)
    await Timer(1, "ps")
    assert int(dut.q.value) == 0

    dut.data.value = value + 1

    # Store should not happen
    await RisingEdge(dut.clk)
    await Timer(1, "ps")
    assert int(dut.q.value) == 0


@cocotb.test()
async def store_in_negedge(dut):
    cocotb.start_soon(Clock(dut.clk, 2, unit="ns").start())
    dut.async_rst_n.value = 0
    dut.data.value = 0
    await Timer(1, "ns")

    value = random.randint(0, (1 << len(dut.data)) - 1)

    dut.async_rst_n.value = 1
    await RisingEdge(dut.clk)

    dut.data.value = value

    await FallingEdge(dut.clk)
    await Timer(1, "ps")
    assert int(dut.q.value) == 0

