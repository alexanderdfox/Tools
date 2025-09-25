# Multi-Tool Workshop Simulation

A unique Swift program that simulates various workshop tools through process management and timing analysis. This tool measures system performance by repeatedly terminating and restarting itself, translating timing measurements into tool-specific metrics.

## 🛠️ Available Tools

- **📏 Tape Measure** - Extend/retract measurements with light speed calculations
- **🔩 Screwdriver** - Left/right turns with linear advance and torque
- **⚡ Welder** - Arc cycles with wire consumption and heat input
- **🔨 Hammer** - Strike blows with impact pressure and energy
- **🪚 Saw** - Forward/back strokes with cutting efficiency
- **🔧 Wrench** - Tighten/loosen with mechanical advantage

## 🚀 Quick Start

### Manual Tool Execution
```bash
swift tools.swift <mode> <cycles>
```

**Examples:**
```bash
swift tools.swift tape measure 10
swift tools.swift screwdriver 5
swift tools.swift welder 8
swift tools.swift hammer 15
swift tools.swift saw 12
swift tools.swift wrench 6
```

### Automated Benchmarking
For comprehensive system testing, use the included benchmark script:

```bash
# Run all tools with default settings (5 cycles each)
./benchmark.sh

# Quick benchmark with 3 cycles per tool
./benchmark.sh --quick

# Custom configuration
./benchmark.sh -c 10 -t hammer,saw,wrench

# Get help
./benchmark.sh --help
```

**Benchmark Features:**
- 🔄 **Automated Testing**: Runs all tools sequentially
- 📊 **Performance Metrics**: Collects timing and efficiency data
- 📈 **Report Generation**: Creates detailed markdown reports
- 🎯 **System Analysis**: Tests process management efficiency
- 📁 **Organized Results**: Saves outputs in timestamped directories

## 📊 What It Does

Each tool mode simulates different workshop operations by:
1. **Terminating** the current process (like stopping the tool)
2. **Restarting** a new process (like starting the next operation)
3. **Measuring** timing between operations
4. **Calculating** tool-specific metrics and physics

## 🎯 Purpose

This program serves multiple purposes:
- **System Benchmarking**: Test process management performance
- **Educational Tool**: Learn about process lifecycle management
- **Creative Performance Art**: Metaphorical approach to system analysis
- **Load Testing**: Validate system stability under rapid process cycling
- **Automated Testing**: Comprehensive benchmark suite with reporting

## 🔧 Technical Details

- **Platform**: macOS (uses NSWorkspace and AppKit)
- **Language**: Swift + Bash scripting
- **Process Management**: Self-terminating and restarting
- **Timing Precision**: Microsecond-level measurements
- **Physics Integration**: Real tool specifications and calculations
- **Benchmarking**: Automated testing with comprehensive reporting

## 📈 Output Metrics

Each tool provides relevant metrics:
- **Tape Measure**: Light speed calculations, extension measurements
- **Screwdriver**: Rotation speed, linear advance, torque
- **Welder**: Arc cycles, wire consumption, heat input
- **Hammer**: Strikes/second, energy, impact pressure
- **Saw**: Cutting speed, material removal, efficiency
- **Wrench**: Mechanical advantage, applied torque, work done

## ⚠️ Important Notes

- This program creates system load during execution
- Each cycle terminates and restarts the process
- Use responsibly for testing purposes
- Monitor system performance during execution

## 🤝 Contributing

This is a unique and creative approach to system benchmarking. Feel free to:
- Add new tool modes
- Improve calculations
- Enhance output formatting
- Suggest new metaphors

## 📝 License

Open source - feel free to use and modify for educational and testing purposes.

---

*"Measuring system performance one tool at a time"* 🔧⚡📏
