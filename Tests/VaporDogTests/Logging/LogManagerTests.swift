import Foundation
import XCTest
@testable import VaporDog

final class LogManagerTests: XCTestCase {
    
    func testSendLogsAtMinimum() {
        let mockLogNetworkManager = MockLogNetworkManager(apiKey: "", source: "", service: "", hostname: "", tags: nil)
        let manager = LogManager(networkManager: mockLogNetworkManager)
        (0..<10).forEach { index in
            let item = LogItem(message: "test message \(index)", metadata: [:], status: "error", tags: nil)
            manager.add(logItem: item)
        }
        
        XCTAssertEqual(mockLogNetworkManager.spyLogsToSend?.count, 10)
    }
    
    func testSendLogsBelowMinimumTimeout() {
        let mockLogNetworkManager = MockLogNetworkManager(apiKey: "", source: "", service: "", hostname: "", tags: nil)
        let manager = LogManager(networkManager: mockLogNetworkManager, timeout: 1)
        (0..<5).forEach { index in
            let item = LogItem(message: "test message \(index)", metadata: [:], status: "error", tags: nil)
            manager.add(logItem: item)
        }
        
        let expect = expectation(description: "Send items after 1 second timeout")
        mockLogNetworkManager.sendExpectation = expect
        
        wait(for: [expect], timeout: 2)
        XCTAssertEqual(mockLogNetworkManager.spyLogsToSend?.count, 5)
    }
    
    func testLogsGetClearedAfterSend() {
        let mockLogNetworkManager = MockLogNetworkManager(apiKey: "", source: "", service: "", hostname: "", tags: nil)
        let manager = LogManager(networkManager: mockLogNetworkManager)
        (0..<10).forEach { index in
            let item = LogItem(message: "test message \(index)", metadata: [:], status: "error", tags: nil)
            manager.add(logItem: item)
        }
        
        XCTAssertEqual(mockLogNetworkManager.spyLogsToSend?.count, 10)
        XCTAssertEqual(manager.storedLogs.count, 0)
    }
    
    func testLogsGetClearedAfterSendBelowMinimumTimeout() {
        let mockLogNetworkManager = MockLogNetworkManager(apiKey: "", source: "", service: "", hostname: "", tags: nil)
        let manager = LogManager(networkManager: mockLogNetworkManager, timeout: 1)
        (0..<5).forEach { index in
            let item = LogItem(message: "test message \(index)", metadata: [:], status: "error", tags: nil)
            manager.add(logItem: item)
        }
        
        let expect = expectation(description: "Send items after 1 second timeout")
        mockLogNetworkManager.sendExpectation = expect
        
        wait(for: [expect], timeout: 2)
        XCTAssertEqual(mockLogNetworkManager.spyLogsToSend?.count, 5)
        XCTAssertEqual(manager.storedLogs.count, 0)
    }
    
    static var allTests = [
        ("testSendLogsAtMinimum", testSendLogsAtMinimum),
        ("testSendLogsBelowMinimumTimeout", testSendLogsBelowMinimumTimeout),
        ("testLogsGetClearedAfterSend", testLogsGetClearedAfterSend),
        ("testLogsGetClearedAfterSendBelowMinimumTimeout", testLogsGetClearedAfterSendBelowMinimumTimeout),
    ]
}
