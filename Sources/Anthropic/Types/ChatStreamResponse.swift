import Foundation
import SharedKit

public struct ChatStreamResponse: Codable {
    public var type: EventType
    public var index: Int?
    public var message: ChatResponse?
    public var delta: ChatResponse.Content?
    public var contentBlock: ChatResponse.Content?
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

extension ChatStreamResponse {
    
    public func apply(to response: ChatResponse?) -> ChatResponse? {
        var existing = response
        switch type {
        case .ping:
            break
        case .error:
            existing?.error = error
        case .message_start:
            if let message {
                existing = message
            }
        case .message_delta:
            existing?.stopReason = message?.stopReason
            existing?.stopSequence = message?.stopSequence
            if let outputTokens = message?.usage?.outputTokens {
                existing?.usage?.outputTokens = outputTokens
            }
        case .message_stop:
            break
        case .content_block_start:
            if existing?.content == nil {
                existing?.content = []
            }
            if let content = contentBlock {
                existing?.content?.append(content)
            }
        case .content_block_delta:
            if let index, let existingContent = existing?.content?[index] {
                let newContent = existingContent.apply(content: delta)
                existing?.content?[index] = newContent
            }
        case .content_block_stop:
            if let index, var existingContent = existing?.content?[index] {
                if existingContent.type == .tool_use, let data = existingContent.partialJSON?.data(using: .utf8) {
                    existingContent.input = try? JSONDecoder().decode([String: AnyValue].self, from: data)
                }
                existing?.content?[index] = existingContent
            }
        }
        return existing
    }
}
