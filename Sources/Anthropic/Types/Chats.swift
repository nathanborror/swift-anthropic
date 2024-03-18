import Foundation

public struct ChatRequest: Codable {
    public var model: String
    public var messages: [Message]
    public var system: String?
    public var maxTokens: Int
    public var temperature: Float?
    public var topP: Float?
    public var topK: UInt?
    public var stopSequences: [String]?
    public var stream: Bool?
    public var metadata: Metadata?

    public struct Message: Codable {
        public var role: Role
        public var content: [Content]
        
        public enum Role: String, Codable {
            case assistant, user
        }
        
        public struct Content: Codable {
            public var type: ContentType
            public var text: String?
            public var source: Source?
            
            public enum ContentType: String, Codable {
                case text, image
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
            
            public init(type: ContentType, text: String? = nil, source: Source? = nil) {
                self.type = type
                self.text = text
                self.source = source
            }
        }
        
        public init(role: Role, content: [Content]) {
            self.role = role
            self.content = content
        }
    }
    
    public struct Metadata: Codable {
        public var userID: String
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case system
        case maxTokens = "max_tokens"
        case temperature
        case topP = "top_p"
        case topK = "top_k"
        case stopSequences = "stop_sequences"
        case stream
        case metadata
    }
    
    public init(model: String, messages: [Message], system: String? = nil, maxTokens: Int = 1024, 
                temperature: Float? = nil, topP: Float? = nil, topK: UInt? = nil, stopSequences: [String]? = nil,
                stream: Bool? = nil, metadata: Metadata? = nil) {
        self.model = model
        self.messages = messages
        self.system = system
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.topP = topP
        self.topK = topK
        self.stopSequences = stopSequences
        self.stream = stream
        self.metadata = metadata
    }
}

public struct ChatResponse: Codable {
    public let id: String
    public let model: String
    public let type: String?
    public let role: Role
    public let content: [Content]
    public let stopReason: String?
    public let stopSequence: String?
    public let usage: Usage
    
    public enum Role: String, Codable {
        case assistant, user
    }
    
    public struct Content: Codable {
        public let type: String
        public let text: String?
    }
    
    public struct Usage: Codable {
        public let inputTokens: Int
        public let outputTokens: Int
        
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
    }
}

public struct ChatStreamResponse: Codable {
    public let type: String
    public let index: Int?
    public let message: ChatResponse?
    public let delta: Delta?
    public let contentBlock: Delta?
    
    public struct Delta: Codable {
        public let type: String?
        public let text: String?
        public let stopReason: String?
        public let stopSequence: String?
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case index
        case message
        case delta
        case contentBlock = "content_block"
    }
}
