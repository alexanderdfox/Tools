import AppKit
import Foundation

// Multi-Tool Workshop Simulation
// This program simulates various workshop tools through process management
// Modes: tape measure, screwdriver, welder, hammer, saw, wrench

// Log exit time when the program terminates
atexit {
	let exitTime = Date().timeIntervalSince1970
	print("Exit: \(exitTime)")
}

// Signal handler for unexpected crashes
func signalHandler(signal: Int32) {
	let signalTime = Date().timeIntervalSince1970
	print("Signal Exit Time: \(signalTime)")
	exit(signal)
}

// Register signal handlers for termination and crashes
signal(SIGINT, signalHandler)    // Handle Ctrl+C
signal(SIGTERM, signalHandler)   // Handle termination
signal(SIGABRT, signalHandler)   // Handle abort
signal(SIGSEGV, signalHandler)   // Handle segmentation fault

/// Stop the current tool (terminate all processes with a given name)
/// - Parameter processName: The name of the process to terminate
func stopTool(named processName: String) {
	let runningApplications = NSWorkspace.shared.runningApplications

	for app in runningApplications where app.localizedName?.caseInsensitiveCompare(processName) == .orderedSame {
		app.forceTerminate()
	}
}

/// Restart the tool for another cycle
/// - Returns: The current time when the tool is restarted
func restartTool() -> TimeInterval {
	let startTime = Date().timeIntervalSince1970
	
	// Run the tool restart logic in a background thread
	DispatchQueue.global(qos: .background).async {
		let process = Process()
		process.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
		process.arguments = Array(CommandLine.arguments[1...])

		do {
			try process.run()
			print("Tool restarted for another cycle.")
		} catch {
			print("Failed to restart tool: \(error.localizedDescription)")
		}
	}
	
	return startTime
}

// Get the mode and number of cycles
guard CommandLine.arguments.count > 2 else {
	print("Usage: swift tools.swift <mode> <cycles>")
	print("Modes: tape measure, screwdriver, welder, hammer, saw, wrench")
	print("Example: swift tools.swift welder 10")
	exit(1)
}

let mode = CommandLine.arguments[1].lowercased()
guard let cycleLimit = Int(CommandLine.arguments[2]), cycleLimit > 0 else {
	print("Please provide a valid positive integer for the number of cycles.")
	exit(1)
}

// Warn for very high cycle counts
if cycleLimit > 50 {
	print("Warning: High cycle count (\(cycleLimit)) may create significant system load.")
	print("Consider using a lower number for testing. Continue? (This is just a warning)")
}

// Validate mode
let validModes = ["tape measure", "tape", "screwdriver", "welder", "hammer", "saw", "wrench"]
let normalizedMode = mode == "tape" ? "tape measure" : mode
guard validModes.contains(normalizedMode) else {
	print("Invalid mode. Available modes: \(validModes.joined(separator: ", "))")
	exit(1)
}

var cycleCount = 0
var leftCycles = 0
var rightCycles = 0
let startTime = Date().timeIntervalSince1970
var cycleTimes: [Double] = []  // Store the elapsed times for each cycle
var cycleDirections: [String] = []  // Store the direction of each cycle

print("\(normalizedMode.capitalized) Start Time: \(startTime)")
print("Mode: \(normalizedMode.capitalized)")
print("Cycles: \(cycleLimit)")
print("Starting simulation...")

// Main simulation loop based on selected mode
while cycleCount < cycleLimit {
	var direction: String
	var cycleType: String
	
	switch normalizedMode {
	case "tape measure":
		// Tape measure extends and retracts
		direction = (cycleCount % 2 == 0) ? "EXTEND" : "RETRACT"
		cycleType = "Measurement"
		
	case "screwdriver":
		// Alternate between left and right turns
		direction = (cycleCount % 2 == 0) ? "LEFT" : "RIGHT"
		cycleType = "Turn"
		
	case "welder":
		// All welding cycles are forward (no reverse welding)
		direction = "FORWARD"
		cycleType = "Arc"
		
	case "hammer":
		// Hammer strikes are all forward
		direction = "STRIKE"
		cycleType = "Blow"
		
	case "saw":
		// Saw has forward and back strokes
		direction = (cycleCount % 2 == 0) ? "FORWARD" : "BACK"
		cycleType = "Stroke"
		
	case "wrench":
		// Wrench can tighten or loosen
		direction = (cycleCount % 2 == 0) ? "TIGHTEN" : "LOOSEN"
		cycleType = "Turn"
		
	default:
		direction = "FORWARD"
		cycleType = "Cycle"
	}
	
	if direction.contains("LEFT") || direction == "BACK" || direction == "LOOSEN" || direction == "RETRACT" {
		leftCycles += 1
	} else {
		rightCycles += 1
	}
	
	print("\(cycleType): \(cycleCount) - Direction: \(direction)")
	
	let processName = ProcessInfo.processInfo.processName
	stopTool(named: processName)
	
	let cycleTime = restartTool()

	// Record the time and direction after each cycle
	let elapsedTime = cycleTime - startTime
	cycleTimes.append(elapsedTime)
	cycleDirections.append(direction)
	print("\(cycleType) \(cycleCount) (\(direction)) completed at: \(elapsedTime) seconds")
	
	cycleCount += 1
}

// Calculate the differences between successive cycle times
let cycleTimeDifferences = (1..<cycleTimes.count).map { i in
	cycleTimes[i] - cycleTimes[i - 1]
}

// Calculate the average cycle time
let avgCycleTime = cycleTimeDifferences.isEmpty ? 0.0 : cycleTimeDifferences.reduce(0, +) / Double(cycleTimeDifferences.count)

// Constants for calculations
let lightSpeed = 299792458.0 // Speed of light in m/s

// Mode-specific specifications and calculations
var specifications: [String: Any] = [:]
var calculations: [String: Double] = [:]

switch normalizedMode {
case "tape measure":
	specifications = [
		"Length": "25 feet (7.62m)",
		"Width": "1 inch (25.4mm)",
		"Graduations": "1/16 inch",
		"Material": "Steel"
	]
	calculations = [
		"Measurements/Second": avgCycleTime > 0 ? 1.0 / avgCycleTime : 0.0,
		"Extension Speed": avgCycleTime > 0 ? (25.0 * 12.0 * 25.4) / avgCycleTime : 0.0, // mm per cycle
		"Total Distance Measured": Double(cycleCount) * (25.0 * 12.0 * 25.4),
		"Precision": 1.0 / 16.0 // inches
	]
	
case "screwdriver":
	specifications = [
		"Diameter": "8.0 mm",
		"Thread Pitch": "1.25 mm/turn",
		"Length": "20.0 mm"
	]
	calculations = [
		"Rotations/Second": avgCycleTime > 0 ? 1.0 / avgCycleTime : 0.0,
		"Linear Advance/Second": avgCycleTime > 0 ? (1.0 / avgCycleTime) * 1.25 : 0.0,
		"Total Linear Advance": Double(cycleCount) * 1.25,
		"Torque": 10.0 + (avgCycleTime * 5.0)
	]
	
case "welder":
	specifications = [
		"Voltage": "24.0 volts",
		"Amperage": "150.0 amps", 
		"Wire Speed": "4.5 m/min",
		"Electrode Diameter": "0.8 mm"
	]
	calculations = [
		"Arc Cycles/Second": avgCycleTime > 0 ? 1.0 / avgCycleTime : 0.0,
		"Wire Consumption/Cycle": (4.5 / 60.0) * avgCycleTime,
		"Total Wire Consumed": Double(cycleCount) * (4.5 / 60.0) * avgCycleTime,
		"Heat Input/Cycle": (24.0 * 150.0 * avgCycleTime) / 1000.0,
		"Total Heat Input": Double(cycleCount) * (24.0 * 150.0 * avgCycleTime) / 1000.0
	]
	
case "hammer":
	specifications = [
		"Weight": "500g",
		"Head Diameter": "25mm",
		"Handle Length": "350mm",
		"Strike Force": "50N"
	]
	calculations = [
		"Strikes/Second": avgCycleTime > 0 ? 1.0 / avgCycleTime : 0.0,
		"Energy/Strike": 50.0 * 0.025, // Force × distance
		"Total Energy": Double(cycleCount) * 50.0 * 0.025,
		"Impact Pressure": 50.0 / (3.14159 * 0.0125 * 0.0125)
	]
	
case "saw":
	specifications = [
		"Blade Length": "500mm",
		"Teeth Per Inch": "8 TPI",
		"Kerf Width": "2.5mm",
		"Stroke Length": "150mm"
	]
	calculations = [
		"Strokes/Second": avgCycleTime > 0 ? 1.0 / avgCycleTime : 0.0,
		"Cutting Speed": avgCycleTime > 0 ? (150.0 / 1000.0) / avgCycleTime : 0.0,
		"Total Distance Cut": Double(cycleCount) * 150.0,
		"Material Removed": Double(cycleCount) * 150.0 * 2.5 * 10.0 // mm³
	]
	
case "wrench":
	specifications = [
		"Size": "10mm",
		"Handle Length": "200mm",
		"Max Torque": "25 N⋅m",
		"Ratchet Teeth": "72 teeth"
	]
	calculations = [
		"Turns/Second": avgCycleTime > 0 ? 1.0 / avgCycleTime : 0.0,
		"Applied Torque": 25.0 * (avgCycleTime / 2.0), // Varies with timing
		"Total Work": Double(cycleCount) * 25.0 * 6.28, // Torque × 2π
		"Leverage Ratio": 200.0 / 10.0
	]
	
default:
	break
}

// Calculate directional statistics
let netCycles = rightCycles - leftCycles
let totalCyclesLeft = Double(leftCycles)
let totalCyclesRight = Double(rightCycles)

// Calculate average times for each direction
let leftCycleTimes = cycleTimes.enumerated().compactMap { (index, time) in
	cycleDirections[index].contains("LEFT") || cycleDirections[index] == "BACK" || cycleDirections[index] == "LOOSEN" || cycleDirections[index] == "RETRACT" ? time : nil
}
let rightCycleTimes = cycleTimes.enumerated().compactMap { (index, time) in
	!(cycleDirections[index].contains("LEFT") || cycleDirections[index] == "BACK" || cycleDirections[index] == "LOOSEN" || cycleDirections[index] == "RETRACT") ? time : nil
}

let avgLeftCycleTime = leftCycleTimes.isEmpty ? 0 : leftCycleTimes.reduce(0, +) / Double(leftCycleTimes.count)
let avgRightCycleTime = rightCycleTimes.isEmpty ? 0 : rightCycleTimes.reduce(0, +) / Double(rightCycleTimes.count)

// Output mode-specific results with directional analysis
print("\n=== \(normalizedMode.uppercased()) ANALYSIS ===")

// Print specifications
print("\(normalizedMode.capitalized) Specifications:")
for (key, value) in specifications {
	print("  \(key): \(value)")
}

// Print cycle performance
print("\nCycle Performance:")
print("  Total Cycles: \(cycleCount)")
print("  Left Cycles: \(leftCycles)")
print("  Right Cycles: \(rightCycles)")
print("  Net Direction: \(netCycles) (\(netCycles > 0 ? "right" : netCycles < 0 ? "left" : "neutral"))")
	if avgCycleTime > 0 {
		print("  Average Cycle Time: \(String(format: "%.3f", avgCycleTime)) seconds")
	} else {
		print("  Average Cycle Time: N/A (insufficient data)")
	}
if avgLeftCycleTime > 0 {
	print("  Average Left Cycle Time: \(String(format: "%.3f", avgLeftCycleTime)) seconds")
}
if avgRightCycleTime > 0 {
	print("  Average Right Cycle Time: \(String(format: "%.3f", avgRightCycleTime)) seconds")
}

// Print calculations
print("\nCalculated Metrics:")
for (key, value) in calculations {
	print("  \(key): \(String(format: "%.3f", value))")
}

// Mode-specific additional info
switch normalizedMode {
case "tape measure":
	print("  Net Extension: \(String(format: "%.3f", Double(cycleCount) * (25.0 * 12.0 * 25.4))) mm")
	if avgCycleTime > 0 {
		print("  Average Speed: \(String(format: "%.3f", avgCycleTime * lightSpeed)) m/s")
		print("  Calculated Length: \(String(format: "%.3f", (avgCycleTime * lightSpeed * avgCycleTime) / 2)) meters")
	} else {
		print("  Average Speed: N/A (insufficient data)")
		print("  Calculated Length: N/A (insufficient data)")
	}
case "screwdriver":
	print("  Net Linear Advance: \(String(format: "%.3f", Double(cycleCount) * 1.25)) mm")
case "welder":
	print("  Deposition Rate: \(String(format: "%.3f", (4.5 / 60.0) * avgCycleTime * 0.785 * 0.8 * 0.8)) cm³/cycle")
case "hammer":
	print("  Impact Pressure: \(String(format: "%.1f", 50.0 / (3.14159 * 0.0125 * 0.0125))) Pa")
case "saw":
	if avgCycleTime > 0 && cycleCount > 0 {
		print("  Cutting Efficiency: \(String(format: "%.1f", (Double(cycleCount) * 150.0) / (avgCycleTime * Double(cycleCount)))) mm/s")
	} else {
		print("  Cutting Efficiency: N/A (insufficient data)")
	}
case "wrench":
	print("  Mechanical Advantage: \(String(format: "%.1f", 200.0 / 10.0)):1")
default:
	break
}