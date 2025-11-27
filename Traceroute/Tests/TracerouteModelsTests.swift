import XCTest
@testable import Core

final class TracerouteModelsTests: XCTestCase {
    
    // MARK: - TracerouteHop Tests
    
    func testTracerouteHopCreation() {
        let hop = TracerouteHop(
            hopNumber: 1,
            address: "192.168.1.1",
            hostname: "router.local",
            roundTripTimes: [1.5, 2.0, 1.8]
        )
        
        XCTAssertEqual(hop.hopNumber, 1)
        XCTAssertEqual(hop.address, "192.168.1.1")
        XCTAssertEqual(hop.hostname, "router.local")
        XCTAssertEqual(hop.roundTripTimes.count, 3)
        XCTAssertFalse(hop.isTimeout)
    }
    
    func testTracerouteHopAverageRTT() {
        let hop = TracerouteHop(
            hopNumber: 1,
            roundTripTimes: [10.0, 20.0, 30.0]
        )
        
        XCTAssertNotNil(hop.averageRTT)
        XCTAssertEqual(hop.averageRTT!, 20.0, accuracy: 0.001)
    }
    
    func testTracerouteHopEmptyRTT() {
        let hop = TracerouteHop(hopNumber: 1)
        
        XCTAssertNil(hop.averageRTT)
    }
    
    func testTracerouteHopTimeout() {
        let hop = TracerouteHop(hopNumber: 2, isTimeout: true)
        
        XCTAssertTrue(hop.isTimeout)
        XCTAssertEqual(hop.displayAddress, "*")
    }
    
    func testTracerouteHopDisplayAddress() {
        // With hostname and address
        let hop1 = TracerouteHop(
            hopNumber: 1,
            address: "192.168.1.1",
            hostname: "router.local"
        )
        XCTAssertEqual(hop1.displayAddress, "router.local (192.168.1.1)")
        
        // With only address
        let hop2 = TracerouteHop(hopNumber: 2, address: "10.0.0.1")
        XCTAssertEqual(hop2.displayAddress, "10.0.0.1")
        
        // With only hostname
        let hop3 = TracerouteHop(hopNumber: 3, hostname: "server.local")
        XCTAssertEqual(hop3.displayAddress, "server.local")
        
        // Timeout
        let hop4 = TracerouteHop(hopNumber: 4, isTimeout: true)
        XCTAssertEqual(hop4.displayAddress, "*")
    }
    
    // MARK: - TracerouteResult Tests
    
    func testTracerouteResultCreation() {
        let hops = [
            TracerouteHop(hopNumber: 1, address: "192.168.1.1"),
            TracerouteHop(hopNumber: 2, address: "10.0.0.1"),
            TracerouteHop(hopNumber: 3, address: "8.8.8.8")
        ]
        
        let result = TracerouteResult(
            target: "8.8.8.8",
            hops: hops,
            isComplete: true
        )
        
        XCTAssertEqual(result.target, "8.8.8.8")
        XCTAssertEqual(result.hops.count, 3)
        XCTAssertTrue(result.isComplete)
        XCTAssertNil(result.errorMessage)
    }
    
    func testTracerouteResultDuration() {
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(5.0)
        
        let result = TracerouteResult(
            target: "google.com",
            startTime: startTime,
            endTime: endTime
        )
        
        XCTAssertNotNil(result.duration)
        XCTAssertEqual(result.duration!, 5.0, accuracy: 0.001)
    }
    
    func testTracerouteResultNoDuration() {
        let result = TracerouteResult(
            target: "google.com",
            endTime: nil
        )
        
        XCTAssertNil(result.duration)
    }
    
    // MARK: - TracerouteStatus Tests
    
    func testTracerouteStatusEquality() {
        XCTAssertEqual(TracerouteStatus.idle, TracerouteStatus.idle)
        XCTAssertEqual(TracerouteStatus.completed, TracerouteStatus.completed)
        XCTAssertEqual(TracerouteStatus.running(progress: 0.5), TracerouteStatus.running(progress: 0.5))
        XCTAssertNotEqual(TracerouteStatus.running(progress: 0.5), TracerouteStatus.running(progress: 0.8))
        XCTAssertNotEqual(TracerouteStatus.idle, TracerouteStatus.completed)
    }
}
