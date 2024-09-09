import Foundation

public struct ModelListResponse: Codable {
    public let models: [Model]
}

public struct Model: Codable {
    public let id: String
    public let name: String
    public let owner: String
    public let contextWindow: Int
    public let maxOutput: Int
}
