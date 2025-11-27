import Foundation
import Core

/// Represents a parsed connection attempt from Little Snitch
public struct ConnectionInfo: Identifiable, Codable, Hashable {
    public let id: UUID
    public let direction: ConnectionDirection
    public let application: String
    public let process: String?
    public let remoteAddress: String?
    public let remotePort: Int?
    public let localPort: Int?
    public let `protocol`: NetworkProtocol
    public let service: KnownService?
    public let rawMessage: String
    public let timestamp: Date
    
    public init(
        id: UUID = UUID(),
        direction: ConnectionDirection,
        application: String,
        process: String? = nil,
        remoteAddress: String? = nil,
        remotePort: Int? = nil,
        localPort: Int? = nil,
        protocol: NetworkProtocol,
        service: KnownService? = nil,
        rawMessage: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.direction = direction
        self.application = application
        self.process = process
        self.remoteAddress = remoteAddress
        self.remotePort = remotePort
        self.localPort = localPort
        self.protocol = `protocol`
        self.service = service
        self.rawMessage = rawMessage
        self.timestamp = timestamp
    }
    
    public var displayDescription: String {
        let portInfo: String
        if let port = remotePort ?? localPort {
            portInfo = " on port \(port)"
            if let service = service {
                return "\(application) using \(service.displayName)\(portInfo)"
            }
        } else {
            portInfo = ""
        }
        return "\(application) (\(`protocol`.rawValue.uppercased()))\(portInfo)"
    }
}

/// Direction of network connection
public enum ConnectionDirection: String, Codable, CaseIterable {
    case incoming
    case outgoing
    
    public var displayName: String {
        switch self {
        case .incoming: return "Incoming"
        case .outgoing: return "Outgoing"
        }
    }
    
    public var icon: String {
        switch self {
        case .incoming: return "arrow.down.circle.fill"
        case .outgoing: return "arrow.up.circle.fill"
        }
    }
}

/// Network protocol types
public enum NetworkProtocol: String, Codable, CaseIterable {
    case tcp
    case udp
    case icmp
    case unknown
}

/// Known network services and their ports
public enum KnownService: Int, Codable, CaseIterable {
    case http = 80
    case https = 443
    case dns = 53
    case mdns = 5353
    case ssh = 22
    case ftp = 21
    case smtp = 25
    case pop3 = 110
    case imap = 143
    case ntp = 123
    case ldap = 389
    case rdp = 3389
    case mysql = 3306
    case postgresql = 5432
    case redis = 6379
    case mongodb = 27017
    
    public var displayName: String {
        switch self {
        case .http: return "HTTP"
        case .https: return "HTTPS"
        case .dns: return "DNS"
        case .mdns: return "mDNS (Bonjour)"
        case .ssh: return "SSH"
        case .ftp: return "FTP"
        case .smtp: return "SMTP"
        case .pop3: return "POP3"
        case .imap: return "IMAP"
        case .ntp: return "NTP"
        case .ldap: return "LDAP"
        case .rdp: return "RDP"
        case .mysql: return "MySQL"
        case .postgresql: return "PostgreSQL"
        case .redis: return "Redis"
        case .mongodb: return "MongoDB"
        }
    }
    
    public var description: String {
        switch self {
        case .http: return "Web traffic (unencrypted)"
        case .https: return "Secure web traffic"
        case .dns: return "Domain Name System queries"
        case .mdns: return "Multicast DNS for local network discovery (Bonjour)"
        case .ssh: return "Secure Shell remote access"
        case .ftp: return "File Transfer Protocol"
        case .smtp: return "Email sending"
        case .pop3: return "Email retrieval"
        case .imap: return "Email access"
        case .ntp: return "Network Time Protocol"
        case .ldap: return "Directory services"
        case .rdp: return "Remote Desktop Protocol"
        case .mysql: return "MySQL database"
        case .postgresql: return "PostgreSQL database"
        case .redis: return "Redis cache/database"
        case .mongodb: return "MongoDB database"
        }
    }
    
    public static func from(port: Int) -> KnownService? {
        return KnownService(rawValue: port)
    }
    
    public static func from(name: String) -> KnownService? {
        let lowercased = name.lowercased()
        switch lowercased {
        case "http": return .http
        case "https": return .https
        case "dns", "domain": return .dns
        case "mdns": return .mdns
        case "ssh": return .ssh
        case "ftp": return .ftp
        case "smtp", "mail": return .smtp
        case "pop3": return .pop3
        case "imap": return .imap
        case "ntp": return .ntp
        case "ldap": return .ldap
        case "rdp": return .rdp
        case "mysql": return .mysql
        case "postgresql", "postgres": return .postgresql
        case "redis": return .redis
        case "mongodb", "mongo": return .mongodb
        default: return nil
        }
    }
}
