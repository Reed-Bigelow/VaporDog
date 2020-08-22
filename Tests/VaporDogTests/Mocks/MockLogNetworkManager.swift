import Foundation
import XCTest
@testable import VaporDog

class MockLogNetworkManager: LogNetworkManager {
    
    var spyLogsToSend: [LogItem]?
    var sendExpectation: XCTestExpectation?
    
    override func send(logs: [LogItem]) {
        spyLogsToSend = logs
        sendExpectation?.fulfill()
    }
}
