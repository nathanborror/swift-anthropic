import Foundation
import SharedKit

public struct ChatResponse: Codable {
    public var type: String
    public var id: String?
    public var model: String?
    public var role: Role?
    public var content: [Content]?
    public var stopReason: StopReason?
    public var stopSequence: String?
    public var usage: Usage?
    public var error: APIError?
    
    public struct Content: Codable {
        public var type: ContentType?
        public var id: String?
        public var name: String?
        public var text: String?
        public var input: [String: AnyValue]?
        public var partialJSON: String?
        
        public enum ContentType: String, Codable {
            case text
            case text_delta
            case tool_use
            case input_json_delta
        }
        
        enum CodingKeys: String, CodingKey {
            case type
            case id
            case name
            case text
            case input
            case partialJSON = "partial_json"
        }
    }
    
    public struct Usage: Codable {
        public var inputTokens: Int
        public var outputTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case inputTokens = "input_tokens"
            case outputTokens = "output_tokens"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case model
        case type
        case role
        case content
        case stopReason = "stop_reason"
        case stopSequence = "stop_sequence"
        case usage
        case error
    }
}
