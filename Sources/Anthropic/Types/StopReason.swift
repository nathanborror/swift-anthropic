import Foundation

public enum StopReason: String, Codable {
    case end_turn
    case max_tokens
    case stop_sequence
    case tool_use
}
