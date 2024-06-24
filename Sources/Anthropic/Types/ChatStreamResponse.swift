import Foundation
import SharedKit

public struct ChatStreamResponse: Codable {
    public var type: EventType
    public var index: Int?
    public var message: ChatResponse?
    public var delta: Content?
    public var contentBlock: Content?
    public var error: APIError?
    
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
    
    enum CodingKeys: String, CodingKey {
        case type
        case index
        case message
        case delta
        case contentBlock = "content_block"
        case error
    }
}
