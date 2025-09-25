#!/bin/bash

# System Benchmark Script using Multi-Tool Workshop Simulation
# This script runs various tool benchmarks and collects performance metrics

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
CYCLES=5
OUTPUT_DIR="./benchmark_results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$OUTPUT_DIR/benchmark_$TIMESTAMP.log"

# Available tools
TOOLS=("tape measure" "screwdriver" "welder" "hammer" "saw" "wrench")

# Function to print colored output
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -c, --cycles NUM     Number of cycles per tool (default: 5)"
    echo "  -t, --tools TOOLS    Comma-separated list of tools to test (default: all)"
    echo "  -o, --output DIR     Output directory for results (default: ./benchmark_results)"
    echo "  -q, --quick          Quick benchmark with 3 cycles each"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Available tools: ${TOOLS[*]}"
    echo ""
    echo "Examples:"
    echo "  $0                           # Run all tools with 5 cycles each"
    echo "  $0 -c 10                     # Run all tools with 10 cycles each"
    echo "  $0 -t hammer,saw             # Run only hammer and saw tools"
    echo "  $0 --quick                   # Quick benchmark with 3 cycles"
    echo "  $0 -c 15 -o /tmp/benchmarks  # Custom cycles and output directory"
}

# Function to get system info
get_system_info() {
    print_header "SYSTEM INFORMATION"
    
    echo "Hostname: $(hostname)"
    echo "OS: $(sw_vers -productName) $(sw_vers -productVersion)"
    echo "Architecture: $(uname -m)"
    echo "CPU: $(sysctl -n machdep.cpu.brand_string)"
    echo "CPU Cores: $(sysctl -n hw.ncpu)"
    echo "Memory: $(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024 " GB"}')"
    echo "Uptime: $(uptime)"
    echo "Date: $(date)"
    echo ""
}

# Function to run a single tool benchmark
run_tool_benchmark() {
    local tool="$1"
    local cycles="$2"
    local output_file="$OUTPUT_DIR/${tool// /_}_${TIMESTAMP}.txt"
    
    print_info "Running $tool benchmark with $cycles cycles..."
    
    # Start time
    local start_time=$(date +%s.%N)
    
    # Run the tool and capture output
    if swift tools.swift "$tool" "$cycles" > "$output_file" 2>&1; then
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc)
        
        print_success "$tool completed in ${duration}s"
        
        # Extract key metrics from the output
        local avg_cycle_time=$(grep "Average Cycle Time:" "$output_file" | grep -o '[0-9]\+\.[0-9]\+' | head -1 || echo "N/A")
        local total_cycles=$(grep "Total Cycles:" "$output_file" | grep -o '[0-9]\+' | head -1 || echo "N/A")
        
        # Store results in summary
        echo "$tool,$cycles,$duration,$avg_cycle_time,$total_cycles" >> "$OUTPUT_DIR/summary_$TIMESTAMP.csv"
        
        return 0
    else
        print_error "$tool failed - check $output_file for details"
        return 1
    fi
}

# Function to generate benchmark report
generate_report() {
    local report_file="$OUTPUT_DIR/benchmark_report_$TIMESTAMP.md"
    
    print_header "GENERATING BENCHMARK REPORT"
    
    cat > "$report_file" << EOF
# System Benchmark Report

**Generated:** $(date)  
**System:** $(hostname) - $(sw_vers -productName) $(sw_vers -productVersion)  
**CPU:** $(sysctl -n machdep.cpu.brand_string)  
**Memory:** $(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024 " GB"}')  

## Benchmark Results

| Tool | Cycles | Duration (s) | Avg Cycle Time (s) | Total Cycles | Performance |
|------|--------|--------------|-------------------|--------------|-------------|
EOF

    # Add results from CSV
    if [[ -f "$OUTPUT_DIR/summary_$TIMESTAMP.csv" ]]; then
        while IFS=',' read -r tool cycles duration avg_time total; do
            # Calculate performance score (higher is better - more cycles per second)
            if [[ "$avg_time" != "N/A" && "$avg_time" != "0" ]]; then
                performance=$(echo "scale=2; 1/$avg_time" | bc 2>/dev/null || echo "N/A")
            else
                performance="N/A"
            fi
            
            echo "| $tool | $cycles | $duration | $avg_time | $total | $performance |" >> "$report_file"
        done < "$OUTPUT_DIR/summary_$TIMESTAMP.csv"
    fi
    
    cat >> "$report_file" << EOF

## Detailed Logs

Each tool's detailed output is available in:
EOF

    # List all output files
    for file in "$OUTPUT_DIR"/*_$TIMESTAMP.txt; do
        if [[ -f "$file" ]]; then
            filename=$(basename "$file")
            echo "- \`$filename\`" >> "$report_file"
        fi
    done
    
    cat >> "$report_file" << EOF

## System Performance Analysis

### Process Management Efficiency
This benchmark tests the efficiency of process termination and restart cycles, which is crucial for:
- System responsiveness
- Process management overhead
- Context switching performance

### Tool-Specific Metrics
Each tool simulates different types of operations:
- **Tape Measure**: Extension/retraction timing
- **Screwdriver**: Rotation and linear advance
- **Welder**: Arc cycles and wire consumption
- **Hammer**: Strike frequency and energy
- **Saw**: Cutting strokes and efficiency
- **Wrench**: Mechanical advantage and torque

### Performance Indicators
- **Lower cycle times** indicate better process management efficiency
- **Consistent timing** across cycles shows system stability
- **Higher performance scores** (cycles/second) indicate better overall performance

## Recommendations

Based on these results:
1. Monitor system load during benchmarks
2. Compare results across different system configurations
3. Use for baseline performance measurements
4. Consider system optimization if cycle times are unusually high

## Documentation

For more information about this benchmark system, see:
- [README](../docs/README.md) - Project overview and usage
- [Purpose](../docs/purpose.md) - Project purpose and goals
- [Usage](../docs/usage.md) - Detailed usage instructions

---
*Generated by Multi-Tool Workshop Simulation Benchmark Script*
EOF

    print_success "Report generated: $report_file"
}

# Function to cleanup old results
cleanup_old_results() {
    if [[ -d "$OUTPUT_DIR" ]]; then
        print_info "Cleaning up results older than 7 days..."
        find "$OUTPUT_DIR" -name "*.txt" -o -name "*.csv" -o -name "*.md" -o -name "*.log" | \
        xargs -I {} find {} -mtime +7 -delete 2>/dev/null || true
    fi
}

# Parse command line arguments
TOOLS_TO_RUN=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--cycles)
            CYCLES="$2"
            shift 2
            ;;
        -t|--tools)
            IFS=',' read -ra TOOLS_TO_RUN <<< "$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -q|--quick)
            CYCLES=3
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate cycles
if ! [[ "$CYCLES" =~ ^[0-9]+$ ]] || [[ "$CYCLES" -lt 1 ]]; then
    print_error "Cycles must be a positive integer"
    exit 1
fi

# Set default tools if none specified
if [[ ${#TOOLS_TO_RUN[@]} -eq 0 ]]; then
    TOOLS_TO_RUN=("${TOOLS[@]}")
fi

# Validate tools
for tool in "${TOOLS_TO_RUN[@]}"; do
    if [[ ! " ${TOOLS[*]} " =~ " $tool " ]]; then
        print_error "Invalid tool: $tool"
        print_info "Available tools: ${TOOLS[*]}"
        exit 1
    fi
done

# Check if swift is available
if ! command -v swift &> /dev/null; then
    print_error "Swift is not installed or not in PATH"
    exit 1
fi

# Check if bc is available for calculations
if ! command -v bc &> /dev/null; then
    print_warning "bc calculator not found - some calculations may be limited"
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Initialize summary CSV
echo "Tool,Cycles,Duration,AvgCycleTime,TotalCycles" > "$OUTPUT_DIR/summary_$TIMESTAMP.csv"

# Start logging
exec > >(tee -a "$LOG_FILE") 2>&1

print_header "MULTI-TOOL WORKSHOP SIMULATION BENCHMARK"
print_info "Output directory: $OUTPUT_DIR"
print_info "Log file: $LOG_FILE"
print_info "Tools to test: ${TOOLS_TO_RUN[*]}"
print_info "Cycles per tool: $CYCLES"
echo ""

# Get system information
get_system_info

# Cleanup old results
cleanup_old_results

# Run benchmarks
print_header "RUNNING BENCHMARKS"
failed_tools=()
successful_tools=()

for tool in "${TOOLS_TO_RUN[@]}"; do
    if run_tool_benchmark "$tool" "$CYCLES"; then
        successful_tools+=("$tool")
    else
        failed_tools+=("$tool")
    fi
    echo ""
done

# Generate report
generate_report

# Final summary
print_header "BENCHMARK SUMMARY"
print_success "Completed tools: ${successful_tools[*]}"

if [[ ${#failed_tools[@]} -gt 0 ]]; then
    print_error "Failed tools: ${failed_tools[*]}"
fi

print_info "Results saved to: $OUTPUT_DIR"
print_info "Report: $OUTPUT_DIR/benchmark_report_$TIMESTAMP.md"
print_info "Log: $LOG_FILE"

echo ""
print_header "BENCHMARK COMPLETE"

# Exit with error code if any tools failed
if [[ ${#failed_tools[@]} -gt 0 ]]; then
    exit 1
fi
