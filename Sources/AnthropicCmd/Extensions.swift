import Foundation
import Anthropic
import SharedKit

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

extension ChatResponse.Content {
    
    public func apply(content: ChatResponse.Content?) -> ChatResponse.Content {
        guard let content else { return self }
        var out = self
        if let text = out.text, let delta = content.text {
            out.text = text + delta
        }
        if let json = out.partialJSON, let delta = content.partialJSON {
            out.partialJSON = json + delta
        }
        return out
    }
}
