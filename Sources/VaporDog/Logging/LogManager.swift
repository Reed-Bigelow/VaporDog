import Foundation

final class LogManager {
    
    private let networkManager: LogNetworkManager
    private(set) var storedLogs = [LogItem]()
    private let timer: RepeatingTimer
    var logCountMin = 10
    
    init(networkManager: LogNetworkManager, logCountMin: Int = 10, timeout: Double = 5) {
        self.networkManager = networkManager
        self.logCountMin = logCountMin
        self.timer = RepeatingTimer(timeInterval: timeout)
        
        configureTimeoutTimer()
    }
    
    func add(logItem: LogItem) {
        storedLogs.append(logItem)
        
        if storedLogs.count >= logCountMin {
            sendLogs()
            timer.reset()
        }
    }
    
    private func configureTimeoutTimer() {
        timer.eventHandler = { [weak self] in
            guard let self = self,
                  !self.storedLogs.isEmpty else {
                return
            }
            
            self.sendLogs()
        }
        
        timer.resume()
    }
    
    private func sendLogs() {
        networkManager.send(logs: storedLogs)
        storedLogs.removeAll()
    }
}
