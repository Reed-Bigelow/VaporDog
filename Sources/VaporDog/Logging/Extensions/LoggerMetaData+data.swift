import Vapor

extension Logger.MetadataValue {
    
    public var data: Any {
        switch self {
        case .dictionary(let dict):
            return dict.mapValues { $0.data }
        case .array(let list):
            return list.map { $0.data }
        case .string(let str):
            return str
        case .stringConvertible(let repr):
            return repr.description
        }
    }
}
