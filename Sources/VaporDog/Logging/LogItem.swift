import Foundation

struct LogItem {
    let message: String
    let metadata: [String: Any]
    let status: String
    let tags: [String]?
}
