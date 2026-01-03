TOPLEVEL_LANG = verilog
TOPLEVEL = dff_sync_rst_n
COCOTB_TEST_MODULES = tb_dff_sync_rst_n
VERILOG_SOURCES = $(PWD)/../rtl/dff_sync_rst_n.sv
IVERILOG_ARGS += -g2012
export PYTHONPATH := $(PWD)/../tb:$(PYTHONPATH)
include $(shell cocotb-config --makefiles)/Makefile.sim