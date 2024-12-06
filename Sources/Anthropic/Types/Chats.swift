import Foundation
import SharedKit

public struct ChatRequest: Codable {
    public var model: String
    public var messages: [Message]
    public var max_tokens: Int
    public var metadata: Metadata?
    public var stop_sequences: [String]?
    public var stream: Bool?
    public var system: [Message.Content]? // Restricted to text
    public var temperature: Float?
    public var tool_choice: ToolChoice?
    public var tools: [Tool]?
    public var top_k: UInt?
    public var top_p: Float?

    public struct Tool: Codable {
        public var name: String
        public var description: String
        public var input_schema: JSONSchema
        
        public init(name: String, description: String, input_schema: JSONSchema) {
            self.name = name
            self.description = description
            self.input_schema = input_schema
        }
    }
    
    public struct ToolChoice: Codable {
        public var type: ToolChoiceType
        public var name: String?
        public var disable_parallel_tool_use: Bool?

        public enum ToolChoiceType: String, Codable {
            case auto, any, tool
        }
        
        public init(type: ToolChoiceType, name: String? = nil, disable_parallel_tool_use: Bool? = nil) {
            self.type = type
            self.name = name
            self.disable_parallel_tool_use = disable_parallel_tool_use
        }
    }
    
    public struct Metadata: Codable {
        public var user_id: String

        public init(user_id: String) {
            self.user_id = user_id
        }
    }

    public init(model: String, messages: [Message], max_tokens: Int, metadata: Metadata? = nil,
                stop_sequences: [String]? = nil, stream: Bool? = nil, system: [Message.Content]? = nil,
                temperature: Float? = nil, tool_choice: ToolChoice? = nil, tools: [Tool]? = nil,
                top_k: UInt? = nil, top_p: Float? = nil) {
        self.model = model
        self.messages = messages
        self.max_tokens = max_tokens
        self.metadata = metadata
        self.stop_sequences = stop_sequences
        self.stream = stream
        self.system = system
        self.temperature = temperature
        self.tool_choice = tool_choice
        self.tools = tools
        self.top_k = top_k
        self.top_p = top_p
    }
}

public struct ChatResponse: Codable {
    public let id: String?
    public let type: String?
    public let role: Role?
    public let content: [Content]?
    public let model: String?
    public let stop_reason: StopReason?
    public let stop_sequence: String?
    public let usage: Usage?

    public enum Role: String, Codable {
        case assistant
        case user
    }

    public struct Content: Codable {
        public let type: ContentType?

        // Text
        public let text: String?

        // Tool Use
        public let id: String?
        public let name: String?
        public let input: [String: AnyValue]?

        // Streaming
        public let partial_json: String?

        public enum ContentType: String, Codable {
            case text
            case tool_use

            // Streaming
            case text_delta
            case input_json_delta
        }
    }

    public enum StopReason: String, Codable {
        case end_turn
        case max_tokens
        case stop_sequence
        case tool_use
    }

    public struct Usage: Codable {
        public let input_tokens: Int?
        public let cache_creation_input_tokens: Int?
        public let cache_read_input_tokens: Int?
        public let output_tokens: Int?
    }
}

public struct ChatResponseStream: Codable {
    public let type: EventType
    public let index: Int?

    public let message: ChatResponse?
    public let delta: ChatResponse.Content?
    public let content_block: ChatResponse.Content?

    public let usage: ChatResponse.Usage?
    public let error: ErrorResponse?

    public enum EventType: String, Codable {
        case ping
        case error

        case message_start
        case message_delta
        case message_stop

        case content_block_start
        case content_block_delta
        case content_block_stop

    }

    public struct ErrorResponse: Codable {
        public let type: String
        public let message: String
    }
}
