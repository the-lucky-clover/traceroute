import SwiftUI
import Core

/// Main content view with cyberpunk neon glassmorphic design
public struct MainView: View {
    @StateObject private var viewModel = TracerouteViewModel()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background
            CyberpunkTheme.backgroundGradient
                .ignoresSafeArea()
            
            // Animated background elements
            GeometryReader { geometry in
                ZStack {
                    // Floating orbs
                    Circle()
                        .fill(CyberpunkTheme.neonPink.opacity(0.1))
                        .frame(width: 300, height: 300)
                        .blur(radius: 80)
                        .offset(x: -100, y: -200)
                    
                    Circle()
                        .fill(CyberpunkTheme.neonBlue.opacity(0.1))
                        .frame(width: 400, height: 400)
                        .blur(radius: 100)
                        .offset(x: geometry.size.width - 200, y: geometry.size.height - 300)
                    
                    Circle()
                        .fill(CyberpunkTheme.neonPurple.opacity(0.08))
                        .frame(width: 250, height: 250)
                        .blur(radius: 60)
                        .offset(x: geometry.size.width / 2, y: 100)
                }
            }
            
            // Main content
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HeaderView()
                    
                    // Bento box layout
                    HStack(alignment: .top, spacing: 20) {
                        // Left column
                        VStack(spacing: 20) {
                            // IP Input Card
                            IPInputCard(viewModel: viewModel)
                            
                            // Connection Parser Card
                            ConnectionParserCard(viewModel: viewModel)
                        }
                        .frame(maxWidth: 400)
                        
                        // Right column - Results
                        TracerouteResultsCard(viewModel: viewModel)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .preferredColorScheme(.dark)
    }
}

/// Header with app title
struct HeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "network")
                    .font(.system(size: 32))
                    .neonGlow(color: CyberpunkTheme.neonBlue)
                
                Text("TRACEROUTE")
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .neonGlow(color: CyberpunkTheme.neonPink)
            }
            
            Text("Network Path Analyzer • Little Snitch Integration")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(CyberpunkTheme.secondaryText)
        }
        .padding(.vertical, 20)
    }
}

/// IP Address input card
struct IPInputCard: View {
    @ObservedObject var viewModel: TracerouteViewModel
    @State private var isValidIP: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Target Address", systemImage: "location.circle.fill")
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(CyberpunkTheme.neonBlue)
            
            HStack {
                TextField("Enter IP or hostname", text: $viewModel.targetAddress)
                    .font(.system(size: 16, design: .monospaced))
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.3))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                isValidIP ? CyberpunkTheme.neonBlue.opacity(0.5) : CyberpunkTheme.neonPink.opacity(0.8),
                                lineWidth: 1
                            )
                    )
                    .onChange(of: viewModel.targetAddress) { _, newValue in
                        if !newValue.isEmpty {
                            // Valid if it's an IP address OR looks like a hostname (contains dot, no spaces)
                            let isIPAddress = viewModel.validateIPAddress(newValue)
                            let looksLikeHostname = newValue.contains(".") && !newValue.contains(" ")
                            isValidIP = isIPAddress || looksLikeHostname
                        } else {
                            isValidIP = true
                        }
                    }
            }
            
            // Example formats
            VStack(alignment: .leading, spacing: 4) {
                Text("Supported formats:")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(CyberpunkTheme.tertiaryText)
                Text("• IPv4: 192.168.1.1")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(CyberpunkTheme.tertiaryText)
                Text("• IPv6: 2601:205:4300:93f0:aeb2:20bf:20eb:c125")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(CyberpunkTheme.tertiaryText)
                Text("• Hostname: google.com")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(CyberpunkTheme.tertiaryText)
            }
            
            // Action button
            HStack {
                Button(action: {
                    Task {
                        await viewModel.startTraceroute()
                    }
                }) {
                    HStack {
                        if case .running = viewModel.status {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.triangle.branch")
                        }
                        Text(viewModel.status == .idle ? "Start Trace" : "Tracing...")
                    }
                }
                .buttonStyle(NeonButtonStyle(color: CyberpunkTheme.neonGreen))
                .disabled(viewModel.status != .idle || viewModel.targetAddress.isEmpty)
                
                if case .running = viewModel.status {
                    Button("Cancel") {
                        viewModel.cancelTraceroute()
                    }
                    .buttonStyle(NeonButtonStyle(isDestructive: true))
                }
            }
            
            // Error message
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(CyberpunkTheme.neonPink)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(CyberpunkTheme.neonPink.opacity(0.1))
                    )
            }
        }
        .padding(20)
        .glassmorphic(glowColor: CyberpunkTheme.neonBlue)
    }
}

/// Connection message parser card
struct ConnectionParserCard: View {
    @ObservedObject var viewModel: TracerouteViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Little Snitch Message Parser", systemImage: "doc.text.magnifyingglass")
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(CyberpunkTheme.neonPurple)
            
            TextEditor(text: $viewModel.parsedMessage)
                .font(.system(size: 13, design: .monospaced))
                .frame(minHeight: 80)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(CyberpunkTheme.neonPurple.opacity(0.5), lineWidth: 1)
                )
            
            Text("Paste messages like: \"tried to establish an incoming connection to Brave Browser via Brave Browser Helper on UDP port 5353 (mdns).\"")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(CyberpunkTheme.tertiaryText)
            
            Button(action: {
                viewModel.parseConnectionMessage()
            }) {
                HStack {
                    Image(systemName: "text.viewfinder")
                    Text("Parse Message")
                }
            }
            .buttonStyle(NeonButtonStyle(color: CyberpunkTheme.neonPurple))
            
            // Parsed result
            if let info = viewModel.connectionInfo {
                ConnectionInfoView(info: info)
            }
        }
        .padding(20)
        .glassmorphic(glowColor: CyberpunkTheme.neonPurple)
    }
}

/// Display parsed connection information
struct ConnectionInfoView: View {
    let info: ConnectionInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Parsed Connection")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(CyberpunkTheme.neonGreen)
            
            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                GridRow {
                    Text("Direction:")
                        .foregroundColor(CyberpunkTheme.tertiaryText)
                    HStack {
                        Image(systemName: info.direction.icon)
                        Text(info.direction.displayName)
                    }
                    .foregroundColor(info.direction == .incoming ? CyberpunkTheme.neonOrange : CyberpunkTheme.neonBlue)
                }
                
                GridRow {
                    Text("Application:")
                        .foregroundColor(CyberpunkTheme.tertiaryText)
                    Text(info.application)
                        .foregroundColor(CyberpunkTheme.primaryText)
                }
                
                if let process = info.process {
                    GridRow {
                        Text("Process:")
                            .foregroundColor(CyberpunkTheme.tertiaryText)
                        Text(process)
                            .foregroundColor(CyberpunkTheme.primaryText)
                    }
                }
                
                GridRow {
                    Text("Protocol:")
                        .foregroundColor(CyberpunkTheme.tertiaryText)
                    Text(info.protocol.rawValue.uppercased())
                        .foregroundColor(CyberpunkTheme.neonYellow)
                }
                
                if let port = info.remotePort ?? info.localPort {
                    GridRow {
                        Text("Port:")
                            .foregroundColor(CyberpunkTheme.tertiaryText)
                        HStack {
                            Text("\(port)")
                            if let service = info.service {
                                Text("(\(service.displayName))")
                                    .foregroundColor(CyberpunkTheme.neonGreen)
                            }
                        }
                        .foregroundColor(CyberpunkTheme.primaryText)
                    }
                }
                
                if let service = info.service {
                    GridRow {
                        Text("Service:")
                            .foregroundColor(CyberpunkTheme.tertiaryText)
                        Text(service.description)
                            .foregroundColor(CyberpunkTheme.secondaryText)
                    }
                }
            }
            .font(.system(size: 12, design: .monospaced))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CyberpunkTheme.neonGreen.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(CyberpunkTheme.neonGreen.opacity(0.3), lineWidth: 1)
        )
    }
}

/// Traceroute results card
struct TracerouteResultsCard: View {
    @ObservedObject var viewModel: TracerouteViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Route Path", systemImage: "point.topleft.down.curvedto.point.bottomright.up.fill")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(CyberpunkTheme.neonGreen)
                
                Spacer()
                
                if let result = viewModel.currentResult {
                    Text("\(result.hops.count) hops")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(CyberpunkTheme.secondaryText)
                }
            }
            
            if viewModel.hopResults.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "network.slash")
                        .font(.system(size: 48))
                        .foregroundColor(CyberpunkTheme.tertiaryText)
                    
                    Text("No traceroute data")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(CyberpunkTheme.tertiaryText)
                    
                    Text("Enter an IP address and click \"Start Trace\" to begin")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(CyberpunkTheme.tertiaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
                .padding()
            } else {
                // Results list
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.hopResults) { hop in
                            HopRow(hop: hop, color: viewModel.colorForHop(hop))
                        }
                    }
                }
                .frame(minHeight: 300)
            }
            
            // Progress indicator
            if case .running(let progress) = viewModel.status {
                VStack(spacing: 8) {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: CyberpunkTheme.neonGreen))
                    
                    Text("Tracing route...")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(CyberpunkTheme.tertiaryText)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .glassmorphic(glowColor: CyberpunkTheme.neonGreen)
    }
}

/// Single hop row
struct HopRow: View {
    let hop: TracerouteHop
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Hop number with 3D effect
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Circle()
                    .strokeBorder(color.opacity(0.6), lineWidth: 1.5)
                    .frame(width: 36, height: 36)
                
                Text("\(hop.hopNumber)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
            }
            
            // Address info
            VStack(alignment: .leading, spacing: 4) {
                if hop.isTimeout {
                    Text("* * * (Request timed out)")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(CyberpunkTheme.neonOrange)
                } else {
                    Text(hop.displayAddress)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(CyberpunkTheme.primaryText)
                }
            }
            
            Spacer()
            
            // RTT values
            if !hop.isTimeout {
                if let avg = hop.averageRTT {
                    Text(String(format: "%.1f ms", avg))
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(color.opacity(0.15))
                        )
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.2))
        )
    }
}

#Preview {
    MainView()
        .frame(width: 900, height: 700)
}
