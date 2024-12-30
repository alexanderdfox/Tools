import AppKit
import Foundation

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

/// Kill all running processes with a given name
/// - Parameter processName: The name of the process to terminate
func killAllProcesses(named processName: String) {
    let runningApplications = NSWorkspace.shared.runningApplications

    for app in runningApplications where app.localizedName?.caseInsensitiveCompare(processName) == .orderedSame {
        app.forceTerminate()
    }
}

/// Reopen the current program
/// - Returns: The current time when the program is reopened
func reopenProgram() -> TimeInterval {
    let startTime = Date().timeIntervalSince1970
    
    // Run the program reopening logic in a background thread
    DispatchQueue.global(qos: .background).async {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
        process.arguments = [CommandLine.arguments[1]]

        do {
            try process.run()
            print("A new instance of the program has been started.")
        } catch {
            print("Failed to reopen the program: \(error.localizedDescription)")
        }
    }
    
    return startTime
}

// Get the argument for the loop limit
guard CommandLine.arguments.count > 1, let loopLimit = Int(CommandLine.arguments[1]) else {
    print("Please provide an integer argument for the loop limit.")
    exit(1)
}

var i = 0
let startTime = Date().timeIntervalSince1970
var times: [Double] = []  // Store the elapsed times

print("Start Time: \(startTime)")

// Main loop to kill and reopen the program a specified number of times
while i < loopLimit {
    print(i)
    
    let processName = ProcessInfo.processInfo.processName
    killAllProcesses(named: processName)
    
    let reopenTime = reopenProgram()

    // Record the time after reopening the program
    let elapsedTime = reopenTime - startTime
    times.append(elapsedTime)
    print(elapsedTime)
    
    i += 1
}

// Calculate the differences between successive times
let timeDifferences = (1..<times.count).map { i in
    times[i] - times[i - 1]
}

// Calculate the average of the time differences
let avgTimeDifference = timeDifferences.reduce(0, +) / Double(timeDifferences.count)

// Constants
let lightSpeed = 299792458.0 // Speed of light in m/s

// Calculate average speed and length based on the average time difference
let avgSpeed = avgTimeDifference * lightSpeed
let avgLength = (avgSpeed * avgTimeDifference) / 2

// Output results
print("Average Difference: \(avgTimeDifference) seconds")
print("Average Speed: \(avgSpeed) m/s")
print("Average Length: \(avgLength) meters")
