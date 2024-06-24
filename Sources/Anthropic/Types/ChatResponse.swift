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
