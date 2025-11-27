# Traceroute

A **cyberpunk neon dark glassmorphic** macOS native standalone app for network path analysis with Little Snitch integration.

![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

### 🌐 Network Tracing
- **IPv4 Support**: Standard IP addresses (e.g., `192.168.1.1`)
- **IPv6 Support**: Full IPv6 addresses (e.g., `2601:205:4300:93f0:aeb2:20bf:20eb:c125`)
- **Hostname Resolution**: Trace routes to domain names

### 🔥 Little Snitch Integration
- Parse connection messages from Little Snitch
- Interpret messages like: *"tried to establish an incoming connection to Brave Browser via Brave Browser Helper on UDP port 5353 (mdns)."*
- Automatic service detection (mDNS, DNS, HTTPS, SSH, etc.)
- Extract application, process, protocol, and port information

### 🎨 Cyberpunk Neon Dark UI
- **3D Skeuomorphic** design elements
- **Glassmorphic** transparent cards with blur effects
- **Bento Box** layout with rounded corners
- **Neon glow** effects on interactive elements
- Animated gradient borders
- Dark theme optimized for extended use

### 🔧 Modular Architecture
- Separate modules for Core, Network, Parser, and UI
- Easy to extend and maintain
- Future-proof design with update capability

## Installation

### Requirements
- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later (for building)

### Build from Source

```bash
# Clone the repository
git clone https://github.com/the-lucky-clover/traceroute.git
cd traceroute

# Build the app
cd Traceroute
swift build

# Run the app
swift run
```

### Create Application Bundle

```bash
# Build for release
swift build -c release

# The executable will be at .build/release/Traceroute
```

## Usage

### Running a Traceroute

1. Enter an IP address or hostname in the "Target Address" field
2. Supported formats:
   - IPv4: `192.168.1.1`
   - IPv6: `2601:205:4300:93f0:aeb2:20bf:20eb:c125`
   - Hostname: `google.com`
3. Click "Start Trace" to begin
4. Watch the route hops appear in real-time

### Parsing Little Snitch Messages

1. Open the "Little Snitch Message Parser" section
2. Paste a connection message from Little Snitch
3. Click "Parse Message"
4. View the parsed information:
   - Connection direction (incoming/outgoing)
   - Application name
   - Process name
   - Protocol (TCP/UDP/ICMP)
   - Port number
   - Service name (if recognized)

## Architecture

```
Traceroute/
├── Sources/
│   ├── App/            # Application entry point
│   ├── Core/           # Core models and utilities
│   │   ├── IPAddress.swift
│   │   ├── TracerouteModels.swift
│   │   └── Configuration.swift
│   ├── Network/        # Network services
│   │   ├── TracerouteService.swift
│   │   └── DNSService.swift
│   ├── Parser/         # Message parsing
│   │   ├── ConnectionInfo.swift
│   │   └── ConnectionMessageParser.swift
│   └── UI/             # SwiftUI views and theming
│       ├── Theme.swift
│       ├── MainView.swift
│       └── TracerouteViewModel.swift
└── Tests/              # Unit tests
```

## Modules

| Module | Description |
|--------|-------------|
| **Core** | Common models, IP address handling, configuration |
| **Network** | Traceroute execution, DNS resolution |
| **Parser** | Little Snitch message parsing, service detection |
| **UI** | SwiftUI views, cyberpunk theme, view models |

## Known Services

The app recognizes the following network services:

| Port | Service | Description |
|------|---------|-------------|
| 22 | SSH | Secure Shell remote access |
| 53 | DNS | Domain Name System queries |
| 80 | HTTP | Web traffic (unencrypted) |
| 443 | HTTPS | Secure web traffic |
| 5353 | mDNS | Multicast DNS (Bonjour) |
| 3306 | MySQL | MySQL database |
| 5432 | PostgreSQL | PostgreSQL database |
| ... | ... | And more! |

## Updates

The app is designed to be future-proof and updatable:

- Modular architecture allows independent module updates
- Version tracking for app and modules
- Update check functionality (Help → Check for Updates)

## Testing

Run the test suite:

```bash
cd Traceroute
swift test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the cyberpunk aesthetic and modern macOS design
- Built with SwiftUI for native performance
- Designed for seamless Little Snitch integration