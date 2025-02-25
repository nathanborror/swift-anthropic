import Foundation
import JSON

extension ChatRequest {

    public struct Message: Codable {
        public var role: Role
        public var content: [Content]

        public enum Role: String, Codable {
            case assistant
            case user
        }
        
        public struct Content: Codable {
            public var type: ContentType
            public var id: String?
            public var text: String?
            public var cache_control: CacheControl?

            // Thinking
            public var thinking: String?
            public var data: Data?
            public var signature: String?

            // Image or Document
            public var source: Source?
            
            // Tool Use
            public var name: String?
            public var input: [String: JSONValue]?

            // Tool Result
            public var tool_use_id: String?
            public var content: [Content]? // Restricted to text or image
            public var is_error: Bool?

            public struct CacheControl: Codable {
                public var type: CacheControlType

                public enum CacheControlType: String, Codable {
                    case ephemeral
                }

                public init(type: CacheControlType) {
                    self.type = type
                }
            }

            public enum ContentType: String, Codable {
                case text
                case image
                case tool_use
                case tool_result
                case document
                case thinking
                case redacted_thinking
            }
            
            public struct Source: Codable {
                public var type: SourceType
                public var media_type: MediaType
                public var data: Data
                
                public enum SourceType: String, Codable {
                    case base64
                }
                
                public enum MediaType: String, Codable {
                    case jpeg = "image/jpeg"
                    case png = "image/png"
                    case gif = "image/gif"
                    case webp = "image/webp"
                    case pdf = "application/pdf"
                }
                
                public init(type: SourceType, media_type: MediaType, data: Data) {
                    self.type = type
                    self.media_type = media_type
                    self.data = data
                }
            }

            public init(type: ContentType, id: String? = nil, text: String? = nil, cache_control: CacheControl? = nil,
                        thinking: String? = nil, data: Data? = nil, signature: String? = nil, source: Source? = nil,
                        name: String? = nil, input: [String : JSONValue]? = nil, tool_use_id: String? = nil,
                        content: [Content]? = nil, is_error: Bool? = nil) {
                self.type = type
                self.id = id
                self.text = text
                self.cache_control = cache_control
                self.thinking = thinking
                self.signature = signature
                self.source = source
                self.name = name
                self.input = input
                self.tool_use_id = tool_use_id
                self.content = content
                self.is_error = is_error
            }
        }
        
        public init(role: Role, content: [Content]) {
            self.role = role
            self.content = content
        }

        public init(role: Role, text: String?) {
            self.role = role
            self.content = [.init(type: .text, text: text)]
        }
    }
}
