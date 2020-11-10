#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation

class LogNetworkManager {
    
    private let apiKey: String
    private let source: String
    private let service: String
    private let hostname: String
    private let tags: [String]?
    private let operationQueue = OperationQueue()
    private lazy var session = URLSession(configuration: .default, delegate: nil, delegateQueue: operationQueue)
    
    init(apiKey: String, source: String, service: String, hostname: String, tags: [String]?) {
        self.apiKey = apiKey
        self.source = source
        self.service = service
        self.hostname = hostname
        self.tags = tags
    }
    
    func send(logs: [LogItem]) {
        guard var request = createRequest() else {
            return
        }
        
        let parameters: [[String: Any]] = logs.map { log in
            var tempParameters = [String: Any]()
            tempParameters["message"] = log.message
            tempParameters["metadata"] = log.metadata
            tempParameters["status"] = log.status
            tempParameters["ddtags"] = [tags, log.tags].compactMap ({ $0 }).reduce([], +).joined(separator: ",")
            return tempParameters
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let task = session.dataTask(with: request) { _, response, error in
            guard let urlResponse = response as? HTTPURLResponse else {
                return
            }
            
            #if DEBUG
            print(urlResponse.statusCode == 200 ? "Logs Sent" : "Failed to send logs")
            #endif
        }
        
        task.resume()
    }
    
    private func createQueryItems() -> [URLQueryItem] {
        return [
            "ddsource": source,
            "service": service,
            "hostname": hostname
        ].map { item -> URLQueryItem in
            return URLQueryItem(name: item.key, value: item.value)
        }
    }
    
    private func createUrl() -> URL? {
        guard let url = URL(string: "https://http-intake.logs.datadoghq.com/v1/input/") else {
            return nil
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = createQueryItems()
        return urlComponents?.url
    }
    
    private func createRequest() -> URLRequest? {
        guard let url = createUrl() else {
            return nil
        }
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "DD-API-KEY")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
