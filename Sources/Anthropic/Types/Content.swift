import Foundation
import SharedKit

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

extension Content {
    
    public func apply(content: Content?) -> Content {
        var out = self
        guard let content else { return out }
        if let text = out.text, let delta = content.text {
            out.text = text + delta
        }
        if let json = out.partialJSON, let delta = content.partialJSON {
            out.partialJSON = json + delta
        }
        return out
    }
}
