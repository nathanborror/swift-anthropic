import Foundation
import SharedKit

public struct ChatResponseStream: Codable {
    public var type: EventType
    public var index: Int?
    
    public var message: ChatResponse?
    public var delta: ChatResponse.Content?
    public var content_block: ChatResponse.Content?

    public var usage: ChatResponse.Usage?
    public var error: ErrorResponse?

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
