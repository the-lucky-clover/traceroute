import XCTest
@testable import Parser
@testable import Core

final class ConnectionMessageParserTests: XCTestCase {
    
    var parser: ConnectionMessageParser!
    
    override func setUp() {
        super.setUp()
        parser = ConnectionMessageParser()
    }
    
    // MARK: - Little Snitch Message Parsing
    
    func testParseIncomingConnectionMessage() {
        let message = "tried to establish an incoming connection to Brave Browser via Brave Browser Helper on UDP port 5353 (mdns)."
        
        let result = parser.parse(message)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.direction, .incoming)
        XCTAssertEqual(result?.application, "Brave Browser")
        XCTAssertEqual(result?.process, "Brave Browser Helper")
        XCTAssertEqual(result?.protocol, .udp)
        XCTAssertEqual(result?.remotePort, 5353)
        XCTAssertEqual(result?.service, .mdns)
    }
    
    func testParseOutgoingConnectionMessage() {
        let message = "tried to establish an outgoing connection to api.example.com on TCP port 443 (https)."
        
        let result = parser.parse(message)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.direction, .outgoing)
        XCTAssertEqual(result?.protocol, .tcp)
        XCTAssertEqual(result?.remotePort, 443)
        XCTAssertEqual(result?.service, .https)
    }
    
    func testParseTCPConnection() {
        let message = "connect to server on TCP port 22"
        
        let result = parser.parse(message)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.protocol, .tcp)
        XCTAssertEqual(result?.remotePort, 22)
        XCTAssertEqual(result?.service, .ssh)
    }
    
    func testParsePortWithoutService() {
        let message = "connection to app on UDP port 12345"
        
        let result = parser.parse(message)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.remotePort, 12345)
        XCTAssertNil(result?.service)
    }
    
    func testParseMessageWithIPv4Address() {
        let message = "connection to server at 192.168.1.100 on TCP port 80"
        
        let result = parser.parse(message)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.remoteAddress, "192.168.1.100")
        XCTAssertEqual(result?.remotePort, 80)
        XCTAssertEqual(result?.service, .http)
    }
    
    func testParseMessageWithIPv6Address() {
        let message = "connection to 2601:205:4300:93f0:aeb2:20bf:20eb:c125 on UDP port 53"
        
        let result = parser.parse(message)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.remoteAddress, "2601:205:4300:93f0:aeb2:20bf:20eb:c125")
        XCTAssertEqual(result?.remotePort, 53)
        XCTAssertEqual(result?.service, .dns)
    }
    
    // MARK: - Known Services Tests
    
    func testKnownServiceFromPort() {
        XCTAssertEqual(KnownService.from(port: 80), .http)
        XCTAssertEqual(KnownService.from(port: 443), .https)
        XCTAssertEqual(KnownService.from(port: 53), .dns)
        XCTAssertEqual(KnownService.from(port: 5353), .mdns)
        XCTAssertEqual(KnownService.from(port: 22), .ssh)
        XCTAssertNil(KnownService.from(port: 99999))
    }
    
    func testKnownServiceFromName() {
        XCTAssertEqual(KnownService.from(name: "http"), .http)
        XCTAssertEqual(KnownService.from(name: "HTTPS"), .https)
        XCTAssertEqual(KnownService.from(name: "mdns"), .mdns)
        XCTAssertEqual(KnownService.from(name: "DNS"), .dns)
        XCTAssertNil(KnownService.from(name: "unknown"))
    }
    
    func testKnownServiceDisplayName() {
        XCTAssertEqual(KnownService.mdns.displayName, "mDNS (Bonjour)")
        XCTAssertEqual(KnownService.https.displayName, "HTTPS")
        XCTAssertEqual(KnownService.dns.displayName, "DNS")
    }
    
    func testKnownServiceDescription() {
        XCTAssertFalse(KnownService.mdns.description.isEmpty)
        XCTAssertTrue(KnownService.mdns.description.contains("Bonjour"))
    }
    
    // MARK: - Connection Direction Tests
    
    func testConnectionDirectionDisplayName() {
        XCTAssertEqual(ConnectionDirection.incoming.displayName, "Incoming")
        XCTAssertEqual(ConnectionDirection.outgoing.displayName, "Outgoing")
    }
    
    func testConnectionDirectionIcon() {
        XCTAssertEqual(ConnectionDirection.incoming.icon, "arrow.down.circle.fill")
        XCTAssertEqual(ConnectionDirection.outgoing.icon, "arrow.up.circle.fill")
    }
    
    // MARK: - Edge Cases
    
    func testEmptyMessage() {
        let result = parser.parse("")
        
        // Should still create a result with defaults
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.application, "Unknown Application")
    }
    
    func testMalformedMessage() {
        let result = parser.parse("random text without structure")
        
        XCTAssertNotNil(result)
        // Should handle gracefully
    }
}
