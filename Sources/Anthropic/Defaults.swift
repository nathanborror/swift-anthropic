import Foundation

public struct Defaults {
    
    public static let apiHost = URL(string: "https://api.anthropic.com/v1")!
    public static let apiVersion = "2023-06-01"
    public static let apiVersionBeta: String? = "max-tokens-3-5-sonnet-2024-07-15"
    
    public static let chatModel = "claude-3-5-sonnet-20240620"
    
    public static let models: [String] = [
        chatModel,
        "claude-3-opus-20240229",
        "claude-3-sonnet-20240229",
        "claude-3-haiku-20240307",
        "claude-2.1",
        "claude-2.0",
        "claude-instant-1.2",
    ]
}
