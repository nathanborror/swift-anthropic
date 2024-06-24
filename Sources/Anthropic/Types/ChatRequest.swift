import Foundation
import SharedKit

public struct ChatRequest: Codable {
    public var model: String
    public var messages: [ChatRequestMessage]
    public var system: String?
    public var maxTokens: Int
    public var temperature: Float?
    public var tools: [Tool]?
    public var topP: Float?
    public var topK: UInt?
    public var stopSequences: [String]?
    public var stream: Bool?
    public var metadata: Metadata?

    public struct Tool: Codable {
        public var name: String
        public var description: String
        public var inputSchema: JSONSchema
        
        enum CodingKeys: String, CodingKey {
            case name
            case description
            case inputSchema = "input_schema"
        }
        
        public init(name: String, description: String, inputSchema: JSONSchema) {
            self.name = name
            self.description = description
            self.inputSchema = inputSchema
        }
    }
    
    public struct Metadata: Codable {
        public var userID: String
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case system
        case maxTokens = "max_tokens"
        case temperature
        case tools
        case topP = "top_p"
        case topK = "top_k"
        case stopSequences = "stop_sequences"
        case stream
        case metadata
    }
    
    public init(model: String, messages: [ChatRequestMessage], system: String? = nil, maxTokens: Int = 1024,
                temperature: Float? = nil, tools: [Tool]? = nil, topP: Float? = nil, topK: UInt? = nil,
                stopSequences: [String]? = nil, stream: Bool? = nil, metadata: Metadata? = nil) {
        self.model = model
        self.messages = messages
        self.system = system
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.tools = tools
        self.topP = topP
        self.topK = topK
        self.stopSequences = stopSequences
        self.stream = stream
        self.metadata = metadata
    }
}
