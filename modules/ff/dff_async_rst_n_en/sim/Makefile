TOPLEVEL_LANG = verilog
TOPLEVEL = dff_async_rst_n_en
COCOTB_TEST_MODULES = tb_dff_async_rst_n_en
VERILOG_SOURCES = $(PWD)/../rtl/dff_async_rst_n_en.sv
IVERILOG_ARGS += -g2012
export PYTHONPATH := $(PWD)/../tb:$(PYTHONPATH)
include $(shell cocotb-config --makefiles)/Makefile.sim