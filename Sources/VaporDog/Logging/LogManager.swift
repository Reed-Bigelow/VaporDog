import Foundation

final class LogManager {
    
    var logCountMin = 10
    private var storedLogs = [LogItem]()
    private let networkManager: LogNetworkManager
    private let timer = RepeatingTimer(timeInterval: 5)
    
    init(networkManager: LogNetworkManager) {
        self.networkManager = networkManager
        
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
