import Foundation
import SharedKit

extension ChatRequest {
    public struct Message: Codable {
        public var role: Role
        public var content: [Content]
        
        public struct Content: Codable {
            public var type: ContentType
            public var id: String?
            public var text: String?
            
            // Image
            public var source: Source?
            
            // Tool Use
            public var name: String?
            public var input: [String: AnyValue]?
            
            // Tool Result
            public var toolUseID: String?
            public var content: [Content]? // This is weird
            public var isError: Bool?
            
            public enum ContentType: String, Codable {
                case text, image, tool_result, tool_use
            }
            
            public struct Source: Codable {
                public var type: SourceType
                public var mediaType: MediaType
                public var data: Data
                
                public enum SourceType: String, Codable {
                    case base64
                }
                
                public enum MediaType: String, Codable {
                    case jpeg = "image/jpeg"
                    case png = "image/png"
                    case gif = "image/gif"
                    case webp = "image/webp"
                }
                
                enum CodingKeys: String, CodingKey {
                    case type
                    case mediaType = "media_type"
                    case data
                }
                
                public init(type: SourceType, mediaType: MediaType, data: Data) {
                    self.type = type
                    self.mediaType = mediaType
                    self.data = data
                }
            }
            
            enum CodingKeys: String, CodingKey {
                case type
                case text
                case content
                case toolUseID = "tool_use_id"
                case id
                case name
                case input
                case source
                case isError = "is_error"
            }
            
            public init(type: ContentType, text: String? = nil, content: [Content]? = nil, toolUseID: String? = nil, id: String? = nil, name: String? = nil, input: [String : AnyValue]? = nil, source: Source? = nil) {
                self.type = type
                self.text = text
                self.content = content
                self.toolUseID = toolUseID
                self.id = id
                self.name = name
                self.input = input
                self.source = source
            }
            
            public init(content: ChatResponse.Content) {
                self.text = content.text
                self.content = nil
                self.toolUseID = nil
                self.id = content.id
                self.name = content.name
                self.input = content.input
                self.source = nil
                
                switch content.type {
                case .text, .text_delta, .none:
                    self.type = .text
                case .tool_use, .input_json_delta:
                    self.type = .tool_use
                }
            }
        }
        
        public init(role: Role, content: [Content]) {
            self.role = role
            self.content = content
        }
    }
}
