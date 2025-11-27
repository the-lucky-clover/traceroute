import Foundation
import Core

#if canImport(CFNetwork)
import CFNetwork
#endif

/// Service for DNS resolution and IP lookup
public actor DNSService {
    public init() {}
    
    /// Resolve hostname to IP addresses
    public func resolve(hostname: String) async throws -> [IPAddress] {
        #if os(macOS)
        return try await withCheckedThrowingContinuation { continuation in
            var results: [IPAddress] = []
            
            let host = CFHostCreateWithName(nil, hostname as CFString).takeRetainedValue()
            var resolved = DarwinBoolean(false)
            
            if CFHostStartInfoResolution(host, .addresses, nil) {
                if let addresses = CFHostGetAddressing(host, &resolved)?.takeUnretainedValue() as? [Data] {
                    for addressData in addresses {
                        addressData.withUnsafeBytes { pointer in
                            guard let sockaddr = pointer.baseAddress?.assumingMemoryBound(to: sockaddr.self) else { return }
                            
                            var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                            
                            if getnameinfo(sockaddr, socklen_t(addressData.count),
                                          &hostBuffer, socklen_t(hostBuffer.count),
                                          nil, 0, NI_NUMERICHOST) == 0 {
                                let ipString = String(cString: hostBuffer)
                                if let ip = IPAddress(string: ipString) {
                                    results.append(ip)
                                }
                            }
                        }
                    }
                }
            }
            
            if results.isEmpty {
                continuation.resume(throwing: DNSError.resolutionFailed(hostname))
            } else {
                continuation.resume(returning: results)
            }
        }
        #else
        // Fallback for non-macOS platforms using getaddrinfo
        return try await resolveUsingGetAddrInfo(hostname: hostname)
        #endif
    }
    
    #if !os(macOS)
    /// Cross-platform DNS resolution using getaddrinfo
    private func resolveUsingGetAddrInfo(hostname: String) async throws -> [IPAddress] {
        var results: [IPAddress] = []
        var hints = addrinfo()
        hints.ai_family = AF_UNSPEC
        hints.ai_socktype = Int32(SOCK_STREAM.rawValue)
        
        var res: UnsafeMutablePointer<addrinfo>?
        let status = getaddrinfo(hostname, nil, &hints, &res)
        
        guard status == 0, let addrInfo = res else {
            throw DNSError.resolutionFailed(hostname)
        }
        
        defer { freeaddrinfo(res) }
        
        var current: UnsafeMutablePointer<addrinfo>? = addrInfo
        while let info = current {
            var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            
            if getnameinfo(info.pointee.ai_addr, info.pointee.ai_addrlen,
                          &hostBuffer, socklen_t(hostBuffer.count),
                          nil, 0, NI_NUMERICHOST) == 0 {
                let ipString = String(cString: hostBuffer)
                if let ip = IPAddress(string: ipString) {
                    results.append(ip)
                }
            }
            current = info.pointee.ai_next
        }
        
        if results.isEmpty {
            throw DNSError.resolutionFailed(hostname)
        }
        
        return results
    }
    #endif
    
    /// Reverse DNS lookup - resolve IP to hostname
    public func reverseLookup(ip: IPAddress) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/host")
        process.arguments = [ip.description]
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        
        try process.run()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: outputData, encoding: .utf8) else {
            throw DNSError.reverseLookupFailed(ip.description)
        }
        
        // Parse "x.x.x.x domain name pointer hostname." format
        if let match = output.range(of: "domain name pointer ") {
            let hostnameStart = match.upperBound
            if let endRange = output[hostnameStart...].range(of: ".") {
                let hostname = String(output[hostnameStart..<endRange.upperBound])
                return hostname.trimmingCharacters(in: CharacterSet(charactersIn: "."))
            }
        }
        
        throw DNSError.reverseLookupFailed(ip.description)
    }
}

/// DNS-related errors
public enum DNSError: Error, LocalizedError {
    case resolutionFailed(String)
    case reverseLookupFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .resolutionFailed(let hostname):
            return "Failed to resolve hostname: \(hostname)"
        case .reverseLookupFailed(let ip):
            return "Reverse lookup failed for: \(ip)"
        }
    }
}
