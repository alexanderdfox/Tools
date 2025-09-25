# Usage Guide - Multi-Tool Workshop Simulation

## 📋 Command Syntax

```bash
swift tools.swift <mode> <cycles>
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

### Testing System Performance
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
```

### Performance Analysis
```bash
# Run multiple times to analyze consistency
for i in {1..5}; do
  echo "Run $i:"
  swift tools.swift tape measure 10
  echo "---"
done
```

## 🔍 Troubleshooting

### Common Issues
- **"Please provide an integer argument"**: Make sure you provide both mode and cycle count
- **"Invalid mode"**: Check spelling of tool mode
- **Process termination errors**: Normal behavior - the program restarts itself

### Performance Tips
- Start with small cycle counts (5-10) to test
- Monitor system performance during execution
- Use appropriate cycle counts for your system capacity

## 📈 Interpreting Results

### Timing Analysis
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

---

*Happy benchmarking! 🔧⚡📏*
