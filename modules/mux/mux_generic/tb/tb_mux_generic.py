import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly, NextTimeStep, Timer

import random
SEED = 666
random.seed(SEED)


# --- Helpers ---
def generate_channels(channels_count): # Generate distinct channel values
    return [i + 1 for i in range(channels_count)]

def get_packed_array(channels, channels_width): # Pack channels into a single signal
    packed_channels = 0
    for i, v in enumerate(channels):
        packed_channels |= (int(v) << (i * channels_width))
    return packed_channels


# --- Tests ---
@cocotb.test()
async def test_select_channel(dut): # Test selecting channels 
    channels_count = int(dut.CHANNELS_COUNT.value)
    channels_width = int(dut.CHANNELS_WIDTH.value)

    # Setup channels values
    channels = generate_channels(channels_count)
    dut.channels.value = get_packed_array(channels, channels_width)

    for i in range(channels_count):
        dut.select.value = i
        await Timer(1, "ps")
        assert int(dut.channel_out.value) == channels[i]
