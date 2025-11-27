import Foundation
import Core

/// Parser for Little Snitch connection messages
public struct ConnectionMessageParser {
    public init() {}
    
    /// Parse a Little Snitch connection message
    /// Example: "tried to establish an incoming connection to Brave Browser via Brave Browser Helper on UDP port 5353 (mdns)."
    public func parse(_ message: String) -> ConnectionInfo? {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Determine direction
        let direction: ConnectionDirection
        if trimmed.contains("incoming connection") {
            direction = .incoming
        } else if trimmed.contains("outgoing connection") || trimmed.contains("connect to") {
            direction = .outgoing
        } else {
            direction = .outgoing // default assumption
        }
        
        // Extract application name
        let application = extractApplication(from: trimmed) ?? "Unknown Application"
        
        // Extract process name
        let process = extractProcess(from: trimmed)
        
        // Extract protocol
        let protocolType = extractProtocol(from: trimmed)
        
        // Extract port
        let (port, serviceName) = extractPort(from: trimmed)
        
        // Determine service
        let service: KnownService?
        if let name = serviceName {
            service = KnownService.from(name: name)
        } else if let p = port {
            service = KnownService.from(port: p)
        } else {
            service = nil
        }
        
        // Extract IP address if present
        let remoteAddress = extractIPAddress(from: trimmed)
        
        return ConnectionInfo(
            direction: direction,
            application: application,
            process: process,
            remoteAddress: remoteAddress,
            remotePort: port,
            protocol: protocolType,
            service: service,
            rawMessage: message
        )
    }
    
    /// Parse an IP address from text (supports both IPv4 and IPv6)
    public func parseIPAddress(_ text: String) -> IPAddress? {
        return IPAddress(string: text)
    }
    
    /// Extract application name from the message
    private func extractApplication(from message: String) -> String? {
        // Pattern: "connection to [Application Name]"
        if let range = message.range(of: "connection to ", options: .caseInsensitive) {
            let afterConnection = message[range.upperBound...]
            
            // Look for "via" to get the main application
            if let viaRange = afterConnection.range(of: " via ", options: .caseInsensitive) {
                return String(afterConnection[..<viaRange.lowerBound])
                    .trimmingCharacters(in: .whitespaces)
            }
            
            // Otherwise, take until "on" or end
            if let onRange = afterConnection.range(of: " on ", options: .caseInsensitive) {
                return String(afterConnection[..<onRange.lowerBound])
                    .trimmingCharacters(in: .whitespaces)
            }
        }
        
        return nil
    }
    
    /// Extract process name (after "via")
    private func extractProcess(from message: String) -> String? {
        if let viaRange = message.range(of: " via ", options: .caseInsensitive) {
            let afterVia = message[viaRange.upperBound...]
            
            if let onRange = afterVia.range(of: " on ", options: .caseInsensitive) {
                return String(afterVia[..<onRange.lowerBound])
                    .trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }
    
    /// Extract protocol from message
    private func extractProtocol(from message: String) -> NetworkProtocol {
        let lowercased = message.lowercased()
        if lowercased.contains("udp") {
            return .udp
        } else if lowercased.contains("tcp") {
            return .tcp
        } else if lowercased.contains("icmp") {
            return .icmp
        }
        return .unknown
    }
    
    /// Extract port number and optional service name
    private func extractPort(from message: String) -> (Int?, String?) {
        // Pattern: "port XXXX (servicename)" or "port XXXX"
        let pattern = #"port\s+(\d+)(?:\s*\(([^)]+)\))?"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return (nil, nil)
        }
        
        let range = NSRange(message.startIndex..., in: message)
        guard let match = regex.firstMatch(in: message, options: [], range: range) else {
            return (nil, nil)
        }
        
        var port: Int?
        var serviceName: String?
        
        if let portRange = Range(match.range(at: 1), in: message) {
            port = Int(message[portRange])
        }
        
        if match.numberOfRanges > 2,
           let serviceRange = Range(match.range(at: 2), in: message) {
            serviceName = String(message[serviceRange])
        }
        
        return (port, serviceName)
    }
    
    /// Extract IP address from message
    private func extractIPAddress(from message: String) -> String? {
        // IPv4 pattern
        let ipv4Pattern = #"\b(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b"#
        // IPv6 pattern (simplified)
        let ipv6Pattern = #"\b([0-9a-fA-F:]+:[0-9a-fA-F:]+)\b"#
        
        // Try IPv6 first (longer pattern)
        if let regex = try? NSRegularExpression(pattern: ipv6Pattern, options: []) {
            let range = NSRange(message.startIndex..., in: message)
            if let match = regex.firstMatch(in: message, options: [], range: range),
               let matchRange = Range(match.range(at: 1), in: message) {
                let candidate = String(message[matchRange])
                if IPAddress(string: candidate) != nil {
                    return candidate
                }
            }
        }
        
        // Try IPv4
        if let regex = try? NSRegularExpression(pattern: ipv4Pattern, options: []) {
            let range = NSRange(message.startIndex..., in: message)
            if let match = regex.firstMatch(in: message, options: [], range: range),
               let matchRange = Range(match.range(at: 1), in: message) {
                return String(message[matchRange])
            }
        }
        
        return nil
    }
}
