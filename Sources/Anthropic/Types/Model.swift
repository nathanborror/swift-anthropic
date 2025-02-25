import Foundation

public struct ModelsResponse: Codable {
    public let data: [Model]
    public let has_more: Bool
    public let first_id: String
    public let last_id: String
}

public struct Model: Codable {
    public let type: String
    public let id: String
    public let display_name: String
    public let created_at: String
}
