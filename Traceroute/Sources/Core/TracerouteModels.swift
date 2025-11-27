import Foundation

/// Represents a single hop in a traceroute
public struct TracerouteHop: Identifiable, Codable, Hashable {
    public let id: UUID
    public let hopNumber: Int
    public let address: String?
    public let hostname: String?
    public let roundTripTimes: [Double] // in milliseconds
    public let isTimeout: Bool
    
    public init(
        id: UUID = UUID(),
        hopNumber: Int,
        address: String? = nil,
        hostname: String? = nil,
        roundTripTimes: [Double] = [],
        isTimeout: Bool = false
    ) {
        self.id = id
        self.hopNumber = hopNumber
        self.address = address
        self.hostname = hostname
        self.roundTripTimes = roundTripTimes
        self.isTimeout = isTimeout
    }
    
    public var averageRTT: Double? {
        guard !roundTripTimes.isEmpty else { return nil }
        return roundTripTimes.reduce(0, +) / Double(roundTripTimes.count)
    }
    
    public var displayAddress: String {
        if let hostname = hostname, let address = address {
            return "\(hostname) (\(address))"
        }
        return hostname ?? address ?? "*"
    }
}

/// Result of a complete traceroute operation
public struct TracerouteResult: Identifiable, Codable {
    public let id: UUID
    public let target: String
    public let startTime: Date
    public let endTime: Date?
    public let hops: [TracerouteHop]
    public let isComplete: Bool
    public let errorMessage: String?
    
    public init(
        id: UUID = UUID(),
        target: String,
        startTime: Date = Date(),
        endTime: Date? = nil,
        hops: [TracerouteHop] = [],
        isComplete: Bool = false,
        errorMessage: String? = nil
    ) {
        self.id = id
        self.target = target
        self.startTime = startTime
        self.endTime = endTime
        self.hops = hops
        self.isComplete = isComplete
        self.errorMessage = errorMessage
    }
    
    public var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
}

/// Status of a traceroute operation
public enum TracerouteStatus: Equatable {
    case idle
    case running(progress: Double)
    case completed
    case failed(Error)
    
    public static func == (lhs: TracerouteStatus, rhs: TracerouteStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.completed, .completed): return true
        case (.running(let l), .running(let r)): return l == r
        case (.failed, .failed): return true
        default: return false
        }
    }
}
