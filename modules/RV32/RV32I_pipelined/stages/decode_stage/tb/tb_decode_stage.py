import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly, NextTimeStep, Timer

import random
SEED = 666
random.seed(SEED)
ITERATIONS = 32

@cocotb.test()
async def test(dut): # Verify nothing
    dut._log.info(f"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
