# fcounter - FPGA Counter Project

A simple but complete Verilog project for learning FPGA development with the ice40-up5k FPGA using only open-source tools.

## 🎯 What This Does

This project implements a binary counter on an FPGA that:
- Resets to zero when you press a button
- Increments on every clock cycle (12 MHz)
- Drives an LED with bit 9 of the counter (toggles every 512 clock cycles)

## 🛠️ Project Structure

```
fcounter/
├── src/                    # Verilog source files
│   └── counter.v          # Main counter module
├── sim/                    # Simulation and testbenches
│   └── counter_tb.v       # Testbench for counter
├── constraints/            # FPGA pin constraints
│   └── ice40up5k.pcf     # Pin mappings for ice40-up5k
├── build/                  # Build artifacts (generated)
├── .github/workflows/      # CI/CD automation
│   └── ci.yml            # GitHub Actions workflow
└── Makefile               # Build system
```

## 🚀 Quick Start

### Prerequisites

Install the open-source FPGA toolchain:

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y iverilog yosys nextpnr-ice40 fpga-icestorm gtkwave
```

**macOS (with Homebrew):**
```bash
brew install icarus-verilog yosys icestorm nextpnr-ice40 gtkwave
```

**Alternative - OSS CAD Suite (recommended for beginners):**
Download pre-built toolchain from: https://github.com/YosysHQ/oss-cad-suite-build/releases

```bash
# Extract and add to PATH
wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2024-12-01/oss-cad-suite-linux-x64-20241201.tgz
tar -xzf oss-cad-suite-linux-x64-20241201.tgz
export PATH="$(pwd)/oss-cad-suite/bin:$PATH"
```

### Simulation (No Hardware Required!)

Test the design without any FPGA hardware:

```bash
# Run simulation
make sim

# View waveforms
make wave
```

This will:
1. Compile the Verilog code
2. Run the testbench
3. Generate waveform files you can inspect

### Building for FPGA

```bash
# Build complete bitstream
make bitstream
```

This runs through the entire FPGA build flow:
1. **Synthesis** (`make synth`) - Converts Verilog to logic gates
2. **Place & Route** (`make pnr`) - Maps logic to FPGA resources
3. **Bitstream** - Generates programming file

### Programming the FPGA

**Important:** First, adjust the pin mappings in `constraints/ice40up5k.pcf` for your specific board!

```bash
# Program connected FPGA
make prog
```

## 📋 Makefile Targets

| Command | Description |
|---------|-------------|
| `make sim` | Run simulation with iverilog |
| `make wave` | Open waveform viewer (after simulation) |
| `make synth` | Synthesize design with yosys |
| `make pnr` | Place and route with nextpnr |
| `make bitstream` | Generate FPGA bitstream |
| `make prog` | Program FPGA (requires hardware) |
| `make timing` | Show timing analysis |
| `make stats` | Show resource utilization |
| `make clean` | Remove build artifacts |
| `make help` | Show all available targets |

## 🔧 Hardware Setup

### Supported Boards

This project targets the **Lattice ice40-up5k** FPGA. Compatible boards include:

- **iCEBreaker** - Default pin configuration
- **UPduino v3** - Uncomment alternative pins in PCF
- **iCEstick** - Uncomment alternative pins in PCF

### Pin Configuration

Edit `constraints/ice40up5k.pcf` to match your board's pinout. The file includes commented alternatives for common boards.

### Wiring

1. **Clock** - Usually built into the board (12MHz oscillator)
2. **Reset Button** - Connect to pin specified in PCF (may need pull-up/pull-down resistor)
3. **LED** - Connect to pin specified in PCF (may already be on board)

## 🧪 Testing & CI/CD

The project includes GitHub Actions CI that automatically:
- Runs simulations on every push
- Builds the complete bitstream
- Performs timing analysis
- Uploads artifacts

Check the "Actions" tab on GitHub to see results.

## 📚 Learning Resources

### Understanding the Code

1. **`src/counter.v`** - Start here! The main counter logic is simple and well-commented
2. **`sim/counter_tb.v`** - Learn how testbenches work
3. Run `make sim` and `make wave` to see the counter in action

### Verilog Basics

- `always @(posedge clk)` - Execute on rising clock edge
- `reg` - Storage element (flip-flop)
- `wire` - Combinational connection
- `assign` - Continuous assignment

### Build Flow

```
Verilog Source (.v)
      ↓
  Synthesis (yosys) - Convert to logic gates
      ↓
  P&R (nextpnr) - Map to FPGA hardware
      ↓
  Bitstream (icepack) - Generate programming file
      ↓
  Program (iceprog) - Upload to FPGA
```

### Next Steps for Learning

1. **Modify the counter**
   - Try outputting different bits to the LED
   - Add more LEDs showing different counter bits
   - Implement a countdown counter

2. **Add features**
   - Implement a pause button
   - Add a 7-segment display driver
   - Create a PWM brightness controller for the LED

3. **Learn timing**
   - Run `make timing` to see timing analysis
   - Understand setup and hold times
   - Learn about clock constraints

4. **Explore tools**
   - Open `build/counter.json` to see synthesized netlist
   - Use `make stats` to see resource usage
   - Read yosys and nextpnr documentation

## 📖 Further Reading

- [Verilog Tutorial](http://www.asic-world.com/verilog/veritut.html)
- [ice40 FPGA Documentation](https://www.latticesemi.com/Products/FPGAandCPLD/iCE40Ultra)
- [Project IceStorm](https://github.com/YosysHQ/icestorm) - Open-source ice40 tools
- [Yosys Manual](https://yosyshq.readthedocs.io/)
- [nextpnr](https://github.com/YosysHQ/nextpnr) - FPGA place and route

## 🤝 Contributing

This is a learning project! Feel free to:
- Add more example designs
- Improve documentation
- Add support for more boards
- Share your modifications

## 📄 License

See LICENSE file for details.

## 🙋 FAQ

**Q: The LED isn't blinking**
A: Bit 9 toggles at ~23kHz with a 12MHz clock - too fast to see! It will appear always on. Try bit 20+ for visible blinking.

**Q: Simulation fails**
A: Make sure iverilog is installed: `iverilog -v`

**Q: Synthesis fails**
A: Check that all tools are in PATH. Use OSS CAD Suite for easiest setup.

**Q: How do I make the LED blink visibly?**
A: Change `assign led = count[9];` to `assign led = count[23];` in `src/counter.v`. This will blink at ~1.4 Hz.

**Q: Can I use a different FPGA?**
A: The Verilog is portable, but you'll need different tools and constraints for non-ice40 FPGAs (Xilinx, Altera, etc.)

---

**Happy learning! 🎓**
