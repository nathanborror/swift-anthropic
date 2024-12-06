import Foundation

public final class Client {

    public static let defaultHost = URL(string: "https://api.anthropic.com/v1")!
    public static let defaultApiVersion = "2023-06-01"
    public static let defaultBetaHeader: String? = "max-tokens-3-5-sonnet-2024-07-15"

    public let host: URL
    public let apiKey: String
    public let apiVersion: String
    public let betaHeader: String?
    public let userAgent: String?

    internal(set) public var session: URLSession

    public init(session: URLSession = URLSession(configuration: .default),
                host: URL = defaultHost,
                apiKey: String,
                apiVersion: String = defaultApiVersion,
                betaHeader: String? = defaultBetaHeader,
                userAgent: String? = nil) {
        var host = host
        if !host.path.hasSuffix("/") {
            host = host.appendingPathComponent("")
        }
        self.host = host
        self.apiKey = apiKey
        self.apiVersion = apiVersion
        self.betaHeader = betaHeader
        self.userAgent = userAgent
        self.session = session
    }

    public enum Error: Swift.Error, CustomStringConvertible {
        case requestError(String)
        case responseError(response: HTTPURLResponse, detail: String)
        case decodingError(response: HTTPURLResponse, detail: String)
        case unexpectedError(String)

        public var description: String {
            switch self {
            case .requestError(let detail):
                return "Request error: \(detail)"
            case .responseError(let response, let detail):
                return "Response error (Status \(response.statusCode)): \(detail)"
            case .decodingError(let response, let detail):
                return "Decoding error (Status \(response.statusCode)): \(detail)"
            case .unexpectedError(let detail):
                return "Unexpected error: \(detail)"
            }
        }
    }

    private enum Method: String {
        case post = "POST"
        case get = "GET"
    }

    private struct ErrorResponse: Decodable {
        let type: String
        let error: Error

        struct Error: Decodable {
            let type: String
            let message: String
        }
    }
}

// MARK: - Models

extension Client {

    public func models() async throws -> ModelsResponse {
        try checkAuthentication()
        return .init(models: [
            .init(
                id: "claude-3-5-sonnet-latest",
                name: "Claude 3.5 Sonnet",
                owner: "anthropic",
                contextWindow: 200_000,
                maxOutput: 8192
            ),
            .init(
                id: "claude-3-5-haiku-latest",
                name: "Claude 3.5 Haiku",
                owner: "anthropic",
                contextWindow: 200_000,
                maxOutput: 8192
            ),
            .init(
                id: "claude-3-opus-20240229",
                name: "Claude 3 Opus",
                owner: "anthropic",
                contextWindow: 200_000,
                maxOutput: 4096
            ),
            .init(
                id: "claude-3-sonnet-20240229",
                name: "Claude 3 Sonnet",
                owner: "anthropic",
                contextWindow: 200_000,
                maxOutput: 4096
            ),
            .init(
                id: "claude-3-haiku-20240307",
                name: "Claude 3 Haiku",
                owner: "anthropic",
                contextWindow: 200_000,
                maxOutput: 4096
            ),
        ])
    }
}

// MARK: - Chats

extension Client {

    public func chatCompletions(_ request: ChatRequest) async throws -> ChatResponse {
        guard request.stream == nil || request.stream == false else {
            throw Error.requestError("ChatRequest.stream cannot be set to 'true'")
        }
        return try await fetch(.post, "messages", body: request)
    }

    public func chatCompletionsStream(_ request: ChatRequest) throws -> AsyncThrowingStream<ChatResponseStream, Swift.Error> {
        guard request.stream == true else {
            throw Error.requestError("ChatRequest.stream must be set to 'true'")
        }
        return try fetchAsync(.post, "messages", body: request)
    }
}

// MARK: - Private

extension Client {

    private func fetch<Response: Decodable>(_ method: Method, _ path: String, body: Encodable? = nil) async throws -> Response {
        try checkAuthentication()
        let request = try makeRequest(path: path, method: method, body: body)
        let (data, resp) = try await session.data(for: request)
        try checkResponse(resp, data)
        return try decoder.decode(Response.self, from: data)
    }

    private func fetchAsync<Response: Codable>(_ method: Method, _ path: String, body: Encodable) throws -> AsyncThrowingStream<Response, Swift.Error> {
        try checkAuthentication()
        let request = try makeRequest(path: path, method: method, body: body)
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

    private func checkAuthentication() throws {
        if apiKey.isEmpty {
            throw Error.requestError("Missing API key")
        }
    }

    private func checkResponse(_ resp: URLResponse?, _ data: Data) throws {
        if let response = resp as? HTTPURLResponse, response.statusCode != 200 {
            if let err = try? decoder.decode(ErrorResponse.self, from: data) {
                throw Error.responseError(response: response, detail: err.error.message)
            } else {
                throw Error.responseError(response: response, detail: "Unknown response error")
            }
        }
    }

    private func makeRequest(path: String, method: Method, body: Encodable? = nil) throws -> URLRequest {
        var req = URLRequest(url: host.appending(path: path))
        req.httpMethod = method.rawValue
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.setValue(apiVersion, forHTTPHeaderField: "anthropic-version")
        req.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        if let betaHeader {
            req.setValue(betaHeader, forHTTPHeaderField: "anthropic-beta")
        }
        if let body {
            req.httpBody = try JSONEncoder().encode(body)
        }
        return req
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
