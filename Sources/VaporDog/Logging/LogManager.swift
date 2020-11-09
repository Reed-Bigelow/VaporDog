import Foundation
import Vapor
import NIO

final class LogManager {
    
    private let networkManager: LogNetworkManager
    private(set) var storedLogs = [LogItem]()
    private var task: RepeatedTask?
    private let eventLoopGroup: EventLoopGroup
    private let timeout: Int64
    var logCountMin = 10
    
    init(networkManager: LogNetworkManager, logCountMin: Int = 10, timeout: Int64 = 5, eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)) {
        self.networkManager = networkManager
        self.logCountMin = logCountMin
        self.timeout = timeout
        self.eventLoopGroup = eventLoopGroup
        
        configureTimeoutTimer()
    }
    
    func add(logItem: LogItem) {
        storedLogs.append(logItem)
        
        if storedLogs.count >= logCountMin {
            sendLogs()
        }
    }
    
    private func configureTimeoutTimer() {
        task?.cancel()
        task = nil
        task = eventLoopGroup.next().scheduleRepeatedTask(initialDelay: .seconds(timeout), delay: .seconds(timeout), { [weak self] _ in
            guard let self = self,
                  !self.storedLogs.isEmpty else {
                return
            }
            
            self.sendLogs()
        })
    }
    
    private func sendLogs() {
        networkManager.send(logs: storedLogs)
        storedLogs.removeAll()
    }
}
