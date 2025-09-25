# Usage Guide - Multi-Tool Workshop Simulation

## 📋 Manual Command Syntax

```bash
swift tools.swift <mode> <cycles>
```

## 🤖 Automated Benchmarking

The `benchmark.sh` script provides automated testing and comprehensive reporting:

### Basic Usage
```bash
# Run all tools with default settings (5 cycles each)
./benchmark.sh

# Quick benchmark with 3 cycles per tool
./benchmark.sh --quick

# Get help and see all options
./benchmark.sh --help
```

### Advanced Options
```bash
# Custom cycle count
./benchmark.sh -c 10

# Test specific tools only
./benchmark.sh -t hammer,saw,wrench

# Custom output directory
./benchmark.sh -o /path/to/results

# Combined options
./benchmark.sh -c 15 -t tape,measure,screwdriver -o ./my_benchmarks
```

### Benchmark Features
- **🔄 Automated Execution**: Runs all selected tools sequentially
- **📊 Performance Collection**: Captures timing and efficiency metrics
- **📈 Report Generation**: Creates detailed markdown reports with analysis
- **📁 Organized Output**: Timestamped directories with individual tool results
- **🎯 System Analysis**: Tests process management and context switching efficiency
- **🔍 CSV Export**: Structured data for further analysis
- **🧹 Auto-cleanup**: Removes results older than 7 days

### Benchmark Output Structure
```
benchmark_results/
├── benchmark_report_YYYYMMDD_HHMMSS.md    # Main report
├── summary_YYYYMMDD_HHMMSS.csv            # Performance data
├── benchmark_YYYYMMDD_HHMMSS.log           # Execution log
├── tape_measure_YYYYMMDD_HHMMSS.txt        # Individual tool results
├── screwdriver_YYYYMMDD_HHMMSS.txt
├── welder_YYYYMMDD_HHMMSS.txt
├── hammer_YYYYMMDD_HHMMSS.txt
├── saw_YYYYMMDD_HHMMSS.txt
└── wrench_YYYYMMDD_HHMMSS.txt
```

## 🛠️ Tool Modes

### 📏 Tape Measure Mode
```bash
swift tools.swift tape measure 10
# or
swift tools.swift tape 10
```

**What it does:**
- Simulates extending and retracting a tape measure
- Alternates between EXTEND and RETRACT operations
- Calculates measurements using light speed physics

**Output metrics:**
- Measurements per second
- Extension speed (mm/cycle)
- Total distance measured
- Light speed calculations
- Net extension distance

---

### 🔩 Screwdriver Mode
```bash
swift tools.swift screwdriver 10
```

**What it does:**
- Simulates tightening and loosening screws
- Alternates between LEFT and RIGHT turns
- Models M8 screw specifications (8mm diameter, 1.25mm pitch)

**Output metrics:**
- Rotations per second
- Linear advance rate
- Total linear advance
- Calculated torque
- Net rotation direction

---

### ⚡ Welder Mode
```bash
swift tools.swift welder 10
```

**What it does:**
- Simulates MIG welding operations
- All cycles are FORWARD (no reverse welding)
- Models 24V, 150A welding setup with 0.8mm wire

**Output metrics:**
- Arc cycles per second
- Wire consumption per cycle
- Total wire consumed
- Heat input per cycle
- Total heat input
- Deposition rate

---

### 🔨 Hammer Mode
```bash
swift tools.swift hammer 10
```

**What it does:**
- Simulates hammer strikes
- All cycles are STRIKE operations
- Models 500g hammer with 50N strike force

**Output metrics:**
- Strikes per second
- Energy per strike
- Total energy delivered
- Impact pressure
- Strike efficiency

---

### 🪚 Saw Mode
```bash
swift tools.swift saw 10
```

**What it does:**
- Simulates saw cutting operations
- Alternates between FORWARD and BACK strokes
- Models 500mm blade with 8 TPI and 150mm stroke

**Output metrics:**
- Strokes per second
- Cutting speed
- Total distance cut
- Material removed
- Cutting efficiency

---

### 🔧 Wrench Mode
```bash
swift tools.swift wrench 10
```

**What it does:**
- Simulates wrench operations
- Alternates between TIGHTEN and LOOSEN
- Models 10mm wrench with 25 N⋅m max torque

**Output metrics:**
- Turns per second
- Applied torque
- Total work done
- Leverage ratio
- Mechanical advantage

## 📊 Understanding the Output

### Cycle Performance
- **Total Cycles**: Number of operations performed
- **Left/Right Cycles**: Directional breakdown
- **Net Direction**: Overall direction (positive = right/forward, negative = left/back)
- **Average Cycle Time**: Time per operation in seconds

### Calculated Metrics
Each tool provides relevant physics-based calculations:
- **Speed metrics**: Operations per second
- **Force/Energy metrics**: Applied forces, energy, torque
- **Efficiency metrics**: Work rate, material removal, precision

### Mode-Specific Information
Additional tool-specific calculations:
- **Tape Measure**: Light speed and distance calculations
- **Screwdriver**: Linear advance measurements
- **Welder**: Deposition rate calculations
- **Hammer**: Impact pressure analysis
- **Saw**: Cutting efficiency metrics
- **Wrench**: Mechanical advantage ratios

## ⚙️ Advanced Usage

### Automated Benchmarking (Recommended)
```bash
# Comprehensive system analysis
./benchmark.sh -c 20

# Stress testing with high cycle counts
./benchmark.sh -c 100 -t hammer

# Compare specific tools
./benchmark.sh -t tape,measure,welder -c 25

# Performance regression testing
./benchmark.sh --quick  # Baseline test
# ... make system changes ...
./benchmark.sh --quick  # Compare results
```

### Manual Testing System Performance
```bash
# Test with high cycle counts for stress testing
swift tools.swift hammer 100

# Compare different tools for system analysis
swift tools.swift tape measure 50
swift tools.swift welder 50
```

### Educational Use
```bash
# Start with simple modes to understand the concept
swift tools.swift screwdriver 5
swift tools.swift wrench 5

# Progress to more complex modes
swift tools.swift saw 10
swift tools.swift welder 10

# Use automated benchmarking for comprehensive learning
./benchmark.sh --quick  # See all tools in action
```

### Performance Analysis
```bash
# Automated consistency testing
./benchmark.sh -c 10
./benchmark.sh -c 10  # Run multiple times to compare

# Manual multiple runs for detailed analysis
for i in {1..5}; do
  echo "Run $i:"
  swift tools.swift tape measure 10
  echo "---"
done
```

### Benchmark Report Analysis
After running benchmarks, analyze the generated reports:
```bash
# View the latest benchmark report
open benchmark_results/benchmark_report_*.md

# Compare CSV data
cat benchmark_results/summary_*.csv

# Check detailed tool outputs
ls benchmark_results/*_*.txt
```

## 🔍 Troubleshooting

### Common Issues

#### Manual Tool Execution
- **"Please provide an integer argument"**: Make sure you provide both mode and cycle count
- **"Invalid mode"**: Check spelling of tool mode
- **Process termination errors**: Normal behavior - the program restarts itself

#### Benchmark Script
- **"Swift is not installed"**: Install Xcode command line tools or Swift
- **"Permission denied"**: Make the script executable with `chmod +x benchmark.sh`
- **"bc calculator not found"**: Install bc with `brew install bc` (optional, for calculations)
- **"No such file or directory"**: Ensure you're in the correct directory with tools.swift

### Performance Tips
- Start with small cycle counts (5-10) to test
- Monitor system performance during execution
- Use appropriate cycle counts for your system capacity
- Use `--quick` flag for faster initial testing
- Check benchmark logs for detailed error information

## 📈 Interpreting Results

### Manual Tool Output Analysis
- **Lower cycle times** = faster system performance
- **Consistent timing** = stable system behavior
- **High variance** = system load or resource contention

### Directional Analysis
- **Net Direction = 0**: Balanced operations (screwdriver, saw, wrench)
- **Net Direction > 0**: Forward progress (welder, hammer)
- **Directional timing differences**: System bias in process handling

### Tool-Specific Metrics
- Compare metrics across different tools
- Analyze efficiency ratios
- Monitor system resource usage patterns

### Benchmark Report Analysis
The automated benchmark generates comprehensive reports with:

#### Performance Summary Table
- **Tool**: Which tool was tested
- **Cycles**: Number of operations performed
- **Duration**: Total execution time
- **Avg Cycle Time**: Average time per operation
- **Performance**: Operations per second (higher is better)

#### System Information
- Hardware specifications
- OS version and architecture
- CPU and memory details
- Benchmark execution timestamp

#### Analysis Sections
- **Process Management Efficiency**: Context switching performance
- **Tool-Specific Metrics**: Physics-based calculations
- **Performance Indicators**: What the metrics mean
- **Recommendations**: How to use the results

#### Detailed Logs
- Individual tool outputs for troubleshooting
- CSV data for further analysis
- Execution logs for debugging

### Best Practices for Analysis
1. **Baseline Testing**: Run benchmarks before system changes
2. **Consistent Conditions**: Test under similar system load
3. **Multiple Runs**: Compare results across several executions
4. **Trend Analysis**: Monitor performance over time
5. **Cross-Platform**: Compare results across different systems

---

*Happy benchmarking! 🔧⚡📏*
