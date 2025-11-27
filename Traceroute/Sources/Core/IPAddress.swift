import Foundation

/// Represents an IP address with support for both IPv4 and IPv6
public enum IPAddress: Hashable, Codable, CustomStringConvertible {
    case ipv4(String)
    case ipv6(String)
    
    /// Initialize from a string, automatically detecting the format
    public init?(string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        
        // Check for IPv6 format (contains colons)
        if trimmed.contains(":") {
            if Self.isValidIPv6(trimmed) {
                self = .ipv6(trimmed)
                return
            }
        }
        
        // Check for IPv4 format
        if Self.isValidIPv4(trimmed) {
            self = .ipv4(trimmed)
            return
        }
        
        return nil
    }
    
    public var description: String {
        switch self {
        case .ipv4(let address):
            return address
        case .ipv6(let address):
            return address
        }
    }
    
    public var isIPv6: Bool {
        if case .ipv6 = self { return true }
        return false
    }
    
    public var isIPv4: Bool {
        if case .ipv4 = self { return true }
        return false
    }
    
    /// Validates an IPv4 address string
    private static func isValidIPv4(_ string: String) -> Bool {
        let parts = string.split(separator: ".")
        guard parts.count == 4 else { return false }
        
        for part in parts {
            guard let num = Int(part), num >= 0 && num <= 255 else {
                return false
            }
        }
        return true
    }
    
    /// Validates an IPv6 address string
    private static func isValidIPv6(_ string: String) -> Bool {
        // Handle compressed notation with ::
        let expandedAddress: String
        if string.contains("::") {
            let parts = string.split(separator: "::", omittingEmptySubsequences: false)
            guard parts.count <= 2 else { return false }
            
            // Handle cases like "::1" where leftParts would be empty
            let leftParts = parts[0].isEmpty ? [] : parts[0].split(separator: ":")
            let rightParts = parts.count > 1 && !parts[1].isEmpty ? parts[1].split(separator: ":") : []
            let missingCount = 8 - (leftParts.count + rightParts.count)
            
            guard missingCount >= 0 else { return false }
            
            let zeros = Array(repeating: "0", count: missingCount)
            let allParts = leftParts.map(String.init) + zeros + rightParts.map(String.init)
            expandedAddress = allParts.joined(separator: ":")
        } else {
            expandedAddress = string
        }
        
        let parts = expandedAddress.split(separator: ":")
        guard parts.count == 8 else { return false }
        
        for part in parts {
            guard part.count <= 4,
                  part.count > 0,
                  Int(part, radix: 16) != nil else {
                return false
            }
        }
        return true
    }
}
