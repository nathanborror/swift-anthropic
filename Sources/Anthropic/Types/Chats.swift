import Foundation

public struct ChatRequest: Codable {
    public var model: String
    public var messages: [Message]
    public var system: String?
    public var maxTokens: Int
    public var temperature: Float?
    public var topP: Float?
    public var topK: UInt?
    public var stopSequences: [String]?
    public var stream: Bool?
    public var metadata: Metadata?
    
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
        case topP = "top_p"
        case topK = "top_k"
        case stopSequences = "stop_sequences"
        case stream
        case metadata
    }
    
    public init(model: String, messages: [Message], system: String? = nil, maxTokens: Int = 1024, 
                temperature: Float? = nil, topP: Float? = nil, topK: UInt? = nil, stopSequences: [String]? = nil,
                stream: Bool? = nil, metadata: Metadata? = nil) {
        self.model = model
        self.messages = messages
        self.system = system
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.topP = topP
        self.topK = topK
        self.stopSequences = stopSequences
        self.stream = stream
        self.metadata = metadata
    }
}

public struct ChatResponse: Codable {
    public let id: String
    public let model: String
    public let type: String?
    public let role: Message.Role
    public let content: [Content]
    public let stopReason: String?
    public let stopSequence: String?
    
    public struct Content: Codable {
        public let type: String
        public let text: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case model
        case type
        case role
        case content
        case stopReason = "stop_reason"
        case stopSequence = "stop_sequence"
    }
}

public struct Message: Codable {
    public var role: Role
    public var content: String
    
    public enum Role: String, Codable {
        case assistant, user
    }
    
    public init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}
