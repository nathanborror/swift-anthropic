import Foundation
import SharedKit

public struct ChatRequest: Codable {
    public var model: String
    public var messages: [Message]
    public var system: String?
    public var maxTokens: Int
    public var temperature: Float?
    public var tools: [Tool]?
    public var toolChoice: ToolChoice?
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
    
    public struct ToolChoice: Codable {
        public var type: ToolChoiceType
        public var name: String?
        
        public enum ToolChoiceType: String, Codable {
            case auto, any, tool
        }
        
        public init(type: ToolChoiceType, name: String? = nil) {
            self.type = type
            self.name = name
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
        case toolChoice = "tool_choice"
        case topP = "top_p"
        case topK = "top_k"
        case stopSequences = "stop_sequences"
        case stream
        case metadata
    }
    
    public init(model: String, messages: [Message], system: String? = nil, maxTokens: Int = 8192,
                temperature: Float? = nil, tools: [Tool]? = nil, toolChoice: ToolChoice? = nil, topP: Float? = nil,
                topK: UInt? = nil, stopSequences: [String]? = nil, stream: Bool? = nil, metadata: Metadata? = nil) {
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
