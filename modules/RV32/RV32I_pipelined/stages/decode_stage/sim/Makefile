TOPLEVEL_LANG = verilog
TOPLEVEL = decode_stage
COCOTB_TEST_MODULES = tb_decode_stage

VERILOG_SOURCES = \
$(PWD)/../../../utils/rv32i_types_pkg.sv \
$(PWD)/../rtl/decode_stage.sv \
$(PWD)/../../../regfile/rtl/regfile.sv

IVERILOG_ARGS += -g2012
export PYTHONPATH := $(PWD)/../tb:$(PYTHONPATH)
include $(shell cocotb-config --makefiles)/Makefile.sim




