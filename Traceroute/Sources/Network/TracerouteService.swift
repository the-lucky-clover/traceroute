import Foundation
import Core

/// Service for executing traceroute commands
public actor TracerouteService {
    public init() {}
    
    /// Execute a traceroute to the specified target
    /// - Parameters:
    ///   - target: IP address or hostname to trace
    ///   - maxHops: Maximum number of hops (default 30)
    ///   - timeout: Timeout per probe in seconds
    ///   - onHopReceived: Callback for each hop received
    /// - Returns: Complete traceroute result
    public func trace(
        to target: String,
        maxHops: Int = 30,
        timeout: Int = 5,
        onHopReceived: @Sendable @escaping (TracerouteHop) -> Void = { _ in }
    ) async throws -> TracerouteResult {
        let startTime = Date()
        var hops: [TracerouteHop] = []
        
        // Determine if target is IPv6
        let isIPv6 = target.contains(":")
        
        // Build traceroute command
        // Use traceroute6 for IPv6 addresses on macOS
        let command = isIPv6 ? "traceroute6" : "traceroute"
        let args = ["-m", String(maxHops), "-w", String(timeout), target]
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/\(command)")
        process.arguments = args
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        do {
            try process.run()
        } catch {
            throw TracerouteError.commandFailed("Failed to start traceroute: \(error.localizedDescription)")
        }
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            if !errorString.isEmpty {
                throw TracerouteError.commandFailed(errorString)
            }
        }
        
        guard let output = String(data: outputData, encoding: .utf8) else {
            throw TracerouteError.parseError("Failed to decode output")
        }
        
        hops = parseTracerouteOutput(output)
        
        for hop in hops {
            onHopReceived(hop)
        }
        
        return TracerouteResult(
            target: target,
            startTime: startTime,
            endTime: Date(),
            hops: hops,
            isComplete: true
        )
    }
    
    /// Parse traceroute command output into structured hops
    private func parseTracerouteOutput(_ output: String) -> [TracerouteHop] {
        var hops: [TracerouteHop] = []
        let lines = output.components(separatedBy: .newlines)
        
        for line in lines {
            // Skip header and empty lines
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.starts(with: "traceroute") { continue }
            
            // Parse hop line format: "N  hostname (ip)  time1 ms  time2 ms  time3 ms"
            // or "N  * * *" for timeout
            if let hop = parseHopLine(trimmed) {
                hops.append(hop)
            }
        }
        
        return hops
    }
    
    /// Parse a single hop line
    private func parseHopLine(_ line: String) -> TracerouteHop? {
        let components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        guard !components.isEmpty else { return nil }
        
        guard let hopNumber = Int(components[0]) else { return nil }
        
        // Check for timeout (all asterisks)
        let restComponents = Array(components.dropFirst())
        if restComponents.allSatisfy({ $0 == "*" }) {
            return TracerouteHop(
                hopNumber: hopNumber,
                isTimeout: true
            )
        }
        
        var hostname: String?
        var address: String?
        var rtts: [Double] = []
        
        var i = 0
        while i < restComponents.count {
            let comp = restComponents[i]
            
            if comp == "*" {
                i += 1
                continue
            }
            
            // Check for IP address in parentheses
            if comp.hasPrefix("(") && comp.hasSuffix(")") {
                address = String(comp.dropFirst().dropLast())
                i += 1
                continue
            }
            
            // Check for RTT value (followed by "ms")
            if i + 1 < restComponents.count && restComponents[i + 1] == "ms" {
                if let rtt = Double(comp) {
                    rtts.append(rtt)
                }
                i += 2
                continue
            }
            
            // Must be hostname
            if hostname == nil && !comp.contains(".") || (comp.contains(".") && address == nil) {
                if IPAddress(string: comp) != nil {
                    address = comp
                } else {
                    hostname = comp
                }
            }
            
            i += 1
        }
        
        return TracerouteHop(
            hopNumber: hopNumber,
            address: address,
            hostname: hostname,
            roundTripTimes: rtts
        )
    }
}

/// Errors that can occur during traceroute operations
public enum TracerouteError: Error, LocalizedError {
    case invalidTarget(String)
    case commandFailed(String)
    case parseError(String)
    case timeout
    case networkUnavailable
    
    public var errorDescription: String? {
        switch self {
        case .invalidTarget(let target):
            return "Invalid target: \(target)"
        case .commandFailed(let message):
            return "Command failed: \(message)"
        case .parseError(let message):
            return "Parse error: \(message)"
        case .timeout:
            return "Traceroute timed out"
        case .networkUnavailable:
            return "Network is unavailable"
        }
    }
}
