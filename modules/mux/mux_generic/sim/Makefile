TOPLEVEL_LANG = verilog
TOPLEVEL = mux_generic
COCOTB_TEST_MODULES = tb_mux_generic
VERILOG_SOURCES = $(PWD)/../rtl/mux_generic.sv
IVERILOG_ARGS += -g2012
export PYTHONPATH := $(PWD)/../tb:$(PYTHONPATH)
include $(shell cocotb-config --makefiles)/Makefile.sim