import SwiftUI
import Core
import Network
import Parser

/// Main view model for the traceroute application
@MainActor
public class TracerouteViewModel: ObservableObject {
    @Published public var targetAddress: String = ""
    @Published public var parsedMessage: String = ""
    @Published public var currentResult: TracerouteResult?
    @Published public var status: TracerouteStatus = .idle
    @Published public var connectionInfo: ConnectionInfo?
    @Published public var hopResults: [TracerouteHop] = []
    @Published public var errorMessage: String?
    @Published public var showingConnectionParser: Bool = false
    
    private let tracerouteService = TracerouteService()
    private let connectionParser = ConnectionMessageParser()
    
    public init() {}
    
    /// Start a traceroute to the target
    public func startTraceroute() async {
        guard !targetAddress.isEmpty else {
            errorMessage = "Please enter an IP address or hostname"
            return
        }
        
        status = .running(progress: 0)
        hopResults = []
        errorMessage = nil
        
        do {
            let result = try await tracerouteService.trace(to: targetAddress) { [weak self] hop in
                Task { @MainActor in
                    self?.hopResults.append(hop)
                    let progress = Double(hop.hopNumber) / 30.0
                    self?.status = .running(progress: min(progress, 0.99))
                }
            }
            
            currentResult = result
            hopResults = result.hops
            status = .completed
        } catch {
            errorMessage = error.localizedDescription
            status = .failed(error)
        }
    }
    
    /// Cancel the current traceroute
    public func cancelTraceroute() {
        status = .idle
    }
    
    /// Parse a Little Snitch connection message
    public func parseConnectionMessage() {
        guard !parsedMessage.isEmpty else {
            connectionInfo = nil
            return
        }
        
        connectionInfo = connectionParser.parse(parsedMessage)
        
        // If we got an IP address, set it as the target
        if let address = connectionInfo?.remoteAddress {
            targetAddress = address
        }
    }
    
    /// Validate and format the IP address input
    public func validateIPAddress(_ input: String) -> Bool {
        return IPAddress(string: input) != nil
    }
    
    /// Get color for hop based on RTT
    public func colorForHop(_ hop: TracerouteHop) -> Color {
        guard let rtt = hop.averageRTT else {
            return hop.isTimeout ? CyberpunkTheme.neonOrange : CyberpunkTheme.tertiaryText
        }
        
        if rtt < 20 {
            return CyberpunkTheme.neonGreen
        } else if rtt < 50 {
            return CyberpunkTheme.neonBlue
        } else if rtt < 100 {
            return CyberpunkTheme.neonYellow
        } else {
            return CyberpunkTheme.neonPink
        }
    }
}
