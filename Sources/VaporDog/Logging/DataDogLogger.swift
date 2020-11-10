import Vapor

public struct DataDogLogger: LogHandler {
    
    private let logManager: LogManager
    private static let overrideLock = Lock()
    private static var overrideLogLevel: Logger.Level? = nil
    public var metadata: Logger.Metadata = [:]
    public var logLevel: Logger.Level = .debug
    
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
    
    public init(apiKey: String, source: String, service: String, hostname: String, tags: [String]? = nil) {
        self.logManager = LogManager(networkManager: LogNetworkManager(apiKey: apiKey, source: source, service: service, hostname: hostname, tags: tags))
    }
    
    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String, function: String, line: UInt) {
        guard level.intValue >= logLevel.intValue else {
            return
        }
        
        let tags = (metadata?["tags"]?.data as? [Logger.MetadataValue.StringLiteralType])?.compactMap { $0 }
        let item = Self.createLogItem(level: level, message: message, metadata: metadata, tags: tags)
        logManager.add(logItem: item)
    }
    
    internal static func createLogItem(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, tags: [String]?) -> LogItem {
        let mappedMetadata = metadata?
            .compactMap { $0 }
            .reduce(into: [String: Any](), { acc, item in
                acc[item.key] = Self.convert(data: item.value.data)
            })
        
        return LogItem(message: message.description, metadata: mappedMetadata ?? [:], status: level.rawValue, tags: tags)
    }
    
    internal static func convert(data: Any) -> Any? {
        if let string = data as? String {
            return Int(string) ?? Double(string) ?? string
        } else if let array = data as? [Any] {
            return array.map { convert(data: $0) }
        } else if let dictionary = data as? [String: Any] {
            return dictionary.reduce(into: [String: Any]()) { acc, item in
                acc[item.key] = convert(data: item.value)
            }
        }
            
        return data
    }

}
