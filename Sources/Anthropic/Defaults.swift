import Foundation

public struct Defaults {

    public static let apiHost = URL(string: "https://api.anthropic.com/v1")!
    public static let apiVersion = "2023-06-01"
    public static let apiVersionBeta: String? = "max-tokens-3-5-sonnet-2024-07-15"

    public static let chatModel = "claude-3-5-sonnet-latest"

    public static let models: [Model] = [
        .init(
            id: "claude-3-5-sonnet-latest",
            name: "Claude 3.5 Sonnet",
            owner: "anthropic",
            contextWindow: 200_000,
            maxOutput: 8192
        ),
        .init(
            id: "claude-3-5-haiku-latest",
            name: "Claude 3.5 Haiku",
            owner: "anthropic",
            contextWindow: 200_000,
            maxOutput: 8192
        ),
        .init(
            id: "claude-3-opus-20240229",
            name: "Claude 3 Opus",
            owner: "anthropic",
            contextWindow: 200_000,
            maxOutput: 4096
        ),
        .init(
            id: "claude-3-sonnet-20240229",
            name: "Claude 3 Sonnet",
            owner: "anthropic",
            contextWindow: 200_000,
            maxOutput: 4096
        ),
        .init(
            id: "claude-3-haiku-20240307",
            name: "Claude 3 Haiku",
            owner: "anthropic",
            contextWindow: 200_000,
            maxOutput: 4096
        ),
    ]
}
