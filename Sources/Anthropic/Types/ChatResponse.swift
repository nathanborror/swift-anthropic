import Foundation
import SharedKit

public struct ChatResponse: Codable {
    public var id: String?
    public var type: String?
    public var role: Role?
    public var content: [Content]?
    public var model: String?
    public var stop_reason: StopReason?
    public var stop_sequence: String?
    public var usage: Usage?

    public enum Role: String, Codable {
        case assistant
        case user
    }
    
    public struct Content: Codable {
        public var type: ContentType?

        // Text
        public var text: String?

        // Tool Use
        public var id: String?
        public var name: String?
        public var input: [String: AnyValue]?

        // Streaming
        public var partial_json: String?

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
        public var input_tokens: Int?
        public var cache_creation_input_tokens: Int?
        public var cache_read_input_tokens: Int?
        public var output_tokens: Int?
    }
}
