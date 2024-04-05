import Foundation

public struct APIError: Error, Codable {
    public let type: String
    public let message: String
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        message
    }
}
