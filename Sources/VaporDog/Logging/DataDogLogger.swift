import Vapor

public struct DataDogLogger: LogHandler {
    
    private let logManager: LogManager
    private static let overrideLock = Lock()
    private static var overrideLogLevel: Logger.Level? = nil
    public var metadata: Logger.Metadata = [:]
    public var logLevel: Logger.Level = .warning
    
    public var logCountSendMin: Int {
        get {
            logManager.logCountMin
        }
        set {
            logManager.logCountMin = newValue
        }
    }
    
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set(newValue) {
            self.metadata[metadataKey] = newValue
        }
    }
    
    public init(apiKey: String, source: String, service: String, hostname: String) {
        self.logManager = LogManager(networkManager: LogNetworkManager(apiKey: apiKey, source: source, service: service, hostname: hostname))
    }
    
    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String, function: String, line: UInt) {
        guard level.intValue >= logLevel.intValue else {
            return
        }
        
        let item = createLogItem(message: message, metadata: metadata)
        logManager.add(logItem: item)
    }
    
    private func createLogItem(message: Logger.Message, metadata: Logger.Metadata?) -> LogItem {
        let mappedMetadata = metadata?
            .compactMap { $0 }
            .reduce(into: [String: Any](), { acc, item in
                if let intValue = Int(item.value.description) {
                    acc[item.key] = intValue
                } else if let doubleValue = Double(item.value.description) {
                    acc[item.key] = doubleValue
                } else {
                    acc[item.key] = item.value.description
                }
            })
        
        return LogItem(message: message.description, metadata: mappedMetadata ?? [:], staus: logLevel.rawValue)
    }
}
