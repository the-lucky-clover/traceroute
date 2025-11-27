import XCTest
@testable import Core

final class IPAddressTests: XCTestCase {
    
    // MARK: - IPv4 Tests
    
    func testValidIPv4() {
        XCTAssertNotNil(IPAddress(string: "192.168.1.1"))
        XCTAssertNotNil(IPAddress(string: "10.0.0.1"))
        XCTAssertNotNil(IPAddress(string: "255.255.255.255"))
        XCTAssertNotNil(IPAddress(string: "0.0.0.0"))
    }
    
    func testInvalidIPv4() {
        XCTAssertNil(IPAddress(string: "256.1.1.1"))
        XCTAssertNil(IPAddress(string: "192.168.1"))
        XCTAssertNil(IPAddress(string: "192.168.1.1.1"))
        XCTAssertNil(IPAddress(string: "192.168.1.-1"))
    }
    
    func testIPv4Properties() {
        let ip = IPAddress(string: "192.168.1.1")!
        XCTAssertTrue(ip.isIPv4)
        XCTAssertFalse(ip.isIPv6)
        XCTAssertEqual(ip.description, "192.168.1.1")
    }
    
    // MARK: - IPv6 Tests
    
    func testValidIPv6() {
        XCTAssertNotNil(IPAddress(string: "2601:205:4300:93f0:aeb2:20bf:20eb:c125"))
        XCTAssertNotNil(IPAddress(string: "fe80:0:0:0:0:0:0:1"))
        XCTAssertNotNil(IPAddress(string: "::1"))
        XCTAssertNotNil(IPAddress(string: "2001:db8::"))
        XCTAssertNotNil(IPAddress(string: "2001:db8:85a3:0:0:8a2e:370:7334"))
    }
    
    func testIPv6Properties() {
        let ip = IPAddress(string: "2601:205:4300:93f0:aeb2:20bf:20eb:c125")!
        XCTAssertTrue(ip.isIPv6)
        XCTAssertFalse(ip.isIPv4)
        XCTAssertEqual(ip.description, "2601:205:4300:93f0:aeb2:20bf:20eb:c125")
    }
    
    func testCompressedIPv6() {
        // ::1 (loopback)
        XCTAssertNotNil(IPAddress(string: "::1"))
        
        // :: (all zeros)
        XCTAssertNotNil(IPAddress(string: "::"))
        
        // Partial compression
        XCTAssertNotNil(IPAddress(string: "2001:db8::1"))
    }
    
    // MARK: - Edge Cases
    
    func testWhitespaceHandling() {
        XCTAssertNotNil(IPAddress(string: "  192.168.1.1  "))
        XCTAssertNotNil(IPAddress(string: " 2601:205:4300:93f0:aeb2:20bf:20eb:c125 "))
    }
    
    func testEmptyString() {
        XCTAssertNil(IPAddress(string: ""))
    }
    
    func testRandomString() {
        XCTAssertNil(IPAddress(string: "not-an-ip"))
        XCTAssertNil(IPAddress(string: "google.com"))
    }
}
