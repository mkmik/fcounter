# Makefile for fcounter FPGA project
# Targets: sim, synth, pnr, bitstream, prog, clean, wave

# Project configuration
PROJECT = counter
TOP_MODULE = counter
PCF = constraints/ice40up5k.pcf

# Source files
RTL_SRC = src/$(PROJECT).v
TB_SRC = sim/$(PROJECT)_tb.v

# Build directory
BUILD_DIR = build

# FPGA target
DEVICE = up5k
PACKAGE = sg48
FREQ = 12

# Tools
IVERILOG = iverilog
VVP = vvp
YOSYS = yosys
NEXTPNR = nextpnr-ice40
ICEPACK = icepack
ICEPROG = iceprog
ICETIME = icetime
GTKWAVE = gtkwave

# Default target
.PHONY: all
all: sim

# Help target
.PHONY: help
help:
	@echo "fcounter FPGA Project Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make sim        - Run simulation with iverilog"
	@echo "  make wave       - Open waveform viewer (after simulation)"
	@echo "  make synth      - Synthesize design with yosys"
	@echo "  make pnr        - Place and route with nextpnr"
	@echo "  make bitstream  - Generate FPGA bitstream"
	@echo "  make prog       - Program FPGA (requires hardware)"
	@echo "  make timing     - Show timing analysis"
	@echo "  make stats      - Show resource utilization"
	@echo "  make clean      - Remove build artifacts"
	@echo "  make all        - Run simulation (default)"
	@echo ""
	@echo "Common workflows:"
	@echo "  make sim && make wave  - Simulate and view waveforms"
	@echo "  make bitstream         - Build complete bitstream"
	@echo "  make prog              - Program connected FPGA"

# Simulation with iverilog
.PHONY: sim
sim: $(BUILD_DIR)/$(PROJECT)_tb.vvp
	@echo "=== Running simulation ==="
	$(VVP) $<
	@echo "=== Simulation complete - waveform saved to $(BUILD_DIR)/$(PROJECT)_tb.vcd ==="

$(BUILD_DIR)/$(PROJECT)_tb.vvp: $(RTL_SRC) $(TB_SRC) | $(BUILD_DIR)
	@echo "=== Compiling testbench ==="
	$(IVERILOG) -o $@ -s $(PROJECT)_tb $(TB_SRC) $(RTL_SRC)

# Waveform viewer
.PHONY: wave
wave:
	@if [ ! -f $(BUILD_DIR)/$(PROJECT)_tb.vcd ]; then \
		echo "=== No waveform file found, running simulation first ==="; \
		$(MAKE) sim; \
	fi
	@echo "=== Opening waveform viewer ==="
	$(GTKWAVE) $(BUILD_DIR)/$(PROJECT)_tb.vcd &

# Synthesis with yosys
.PHONY: synth
synth: $(BUILD_DIR)/$(PROJECT).json

$(BUILD_DIR)/$(PROJECT).json: $(RTL_SRC) | $(BUILD_DIR)
	@echo "=== Synthesizing design ==="
	$(YOSYS) -p "read_verilog $(RTL_SRC); synth_ice40 -top $(TOP_MODULE) -json $@"

# Place and Route with nextpnr
.PHONY: pnr
pnr: $(BUILD_DIR)/$(PROJECT).asc

$(BUILD_DIR)/$(PROJECT).asc: $(BUILD_DIR)/$(PROJECT).json $(PCF)
	@echo "=== Place and Route ==="
	$(NEXTPNR) --$(DEVICE) --package $(PACKAGE) --json $< --pcf $(PCF) --asc $@ --freq $(FREQ)

# Generate bitstream
.PHONY: bitstream
bitstream: $(BUILD_DIR)/$(PROJECT).bin

$(BUILD_DIR)/$(PROJECT).bin: $(BUILD_DIR)/$(PROJECT).asc
	@echo "=== Generating bitstream ==="
	$(ICEPACK) $< $@
	@echo "=== Bitstream ready: $@ ==="

# Timing analysis
.PHONY: timing
timing: $(BUILD_DIR)/$(PROJECT).asc
	@echo "=== Timing Analysis ==="
	$(ICETIME) -d $(DEVICE) -mtr $(BUILD_DIR)/timing.rpt $<
	@cat $(BUILD_DIR)/timing.rpt

# Resource utilization stats
.PHONY: stats
stats: $(BUILD_DIR)/$(PROJECT).json
	@echo "=== Resource Utilization ==="
	$(YOSYS) -p "read_json $<; stat"

# Program FPGA
.PHONY: prog
prog: $(BUILD_DIR)/$(PROJECT).bin
	@echo "=== Programming FPGA ==="
	$(ICEPROG) $<

# Clean build artifacts
.PHONY: clean
clean:
	@echo "=== Cleaning build artifacts ==="
	rm -rf $(BUILD_DIR)

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Phony targets for CI/CD
.PHONY: test
test: sim
