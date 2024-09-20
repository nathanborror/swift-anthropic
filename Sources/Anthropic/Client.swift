import Foundation

public final class AnthropicClient {
    
    public struct Configuration {
        public let host: URL
        public let token: String
        
        public init(host: URL? = nil, token: String) {
            self.host = host ?? Defaults.apiHost
            self.token = token
        }
    }
    
    public let configuration: Configuration
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    // Chats
    
    public func chat(_ payload: ChatRequest) async throws -> ChatResponse {
        try checkAuthentication()
        var body = payload
        body.stream = nil
        
        var req = makeRequest(path: "messages", method: "POST")
        req.httpBody = try JSONEncoder().encode(body)
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        if let httpResponse = resp as? HTTPURLResponse, httpResponse.statusCode != 200 {
            if let result = try? decoder.decode(ChatResponse.self, from: data), let error = result.error {
                throw error
            } else {
                throw URLError(.badServerResponse)
            }
        }
        return try decoder.decode(ChatResponse.self, from: data)
    }
    
    public func chatStream(_ payload: ChatRequest) throws -> AsyncThrowingStream<ChatStreamResponse, Error> {
        try checkAuthentication()
        var body = payload
        body.stream = true
        return makeAsyncRequest(path: "messages", method: "POST", body: body)
    }
    
    // Models
    
    public func models() async throws -> ModelListResponse {
        try checkAuthentication()
        return .init(models: Defaults.models)
    }
    
    // Private
    
    private func checkAuthentication() throws {
        if configuration.token.isEmpty {
            throw URLError(.userAuthenticationRequired)
        }
    }
    
    private func makeRequest(path: String, method: String) -> URLRequest {
        var req = URLRequest(url: configuration.host.appending(path: path))
        req.httpMethod = method
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.setValue(Defaults.apiVersion, forHTTPHeaderField: "anthropic-version")
        req.setValue(configuration.token, forHTTPHeaderField: "x-api-key")
        
        if let apiVersionBeta = Defaults.apiVersionBeta {
            req.setValue(apiVersionBeta, forHTTPHeaderField: "anthropic-beta")
        }
        return req
    }
    
    private func makeAsyncRequest<Body: Codable, Response: Codable>(path: String, method: String, body: Body) -> AsyncThrowingStream<Response, Error> {
        var request = makeRequest(path: path, method: method)
        request.httpBody = try? JSONEncoder().encode(body)
        
        return AsyncThrowingStream { continuation in
            let session = StreamingSession<Response>(urlRequest: request)
            session.onReceiveContent = {_, object in
                continuation.yield(object)
            }
            session.onProcessingError = {_, error in
                continuation.finish(throwing: error)
            }
            session.onComplete = { object, error in
                continuation.finish(throwing: error)
            }
            session.perform()
        }
    }
    
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateInt = try container.decode(Int.self)
            return Date(timeIntervalSince1970: TimeInterval(dateInt))
        }
        return decoder
    }
}
