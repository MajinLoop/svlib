TOPLEVEL_LANG = verilog
TOPLEVEL = fetch_stage
COCOTB_TEST_MODULES = tb_fetch_stage

VERILOG_SOURCES = \
$(PWD)/../rtl/fetch_stage.sv \
$(PWD)/../../../../../mux/mux_generic/rtl/mux_generic.sv \
$(PWD)/../../../../../ff/dff_async_rst_n_en/rtl/dff_async_rst_n_en.sv

IVERILOG_ARGS += -g2012
export PYTHONPATH := $(PWD)/../tb:$(PYTHONPATH)
include $(shell cocotb-config --makefiles)/Makefile.sim