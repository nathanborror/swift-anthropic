import Foundation
import ArgumentParser
import Anthropic
import SharedKit

@main
struct Command: AsyncParsableCommand {
    
    static var configuration = CommandConfiguration(
        abstract: "A utility for interacting with the Anthropic API.",
        version: "0.0.1",
        subcommands: [
            Models.self,
            ChatCompletion.self,
        ],
        defaultSubcommand: Models.self
    )
}

struct GlobalOptions: ParsableCommand {
    @Option(name: .shortAndLong, help: "Your API key.")
    var key: String
    
    @Option(name: .shortAndLong, help: "Model to use.")
    var model = "claude-3-5-sonnet-latest"

    @Option(name: .shortAndLong, help: "System prompt.")
    var systemPrompt: String?

    var system: String?

    mutating func validate() throws {
        system = try ValueReader(input: systemPrompt)?.value()
    }
}

struct Models: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "models",
        abstract: "Returns available models."
    )
    
    @OptionGroup
    var global: GlobalOptions
    
    func run() async throws {
        let client = Client(apiKey: global.key)
        let resp = try await client.models()
        print(resp.models.map { $0.id }.joined(separator: "\n"))
    }
}

struct ChatCompletion: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "complete",
        abstract: "Completes a chat request."
    )

    @OptionGroup
    var global: GlobalOptions

    func run() async throws {
        let client = Client(apiKey: global.key)
        var messages: [ChatRequest.Message] = []

        write("\nUsing \(global.model)\n\n")

        if let system = global.system {
            write("\n<system>\n\(system)\n</system>\n\n")
        }

        while true {
            write("> ")
            guard let input = readLine(), !input.isEmpty else {
                continue
            }
            if input.lowercased() == "exit" {
                write("Exiting...")
                break
            }

            let message = ChatRequest.Message(role: .user, content: [.init(type: .text, text: input)])
            messages.append(message)

            let req = ChatRequest(model: global.model, messages: [message], max_tokens: 8192)

            let resp = try await client.chatCompletions(req)
            let content = resp.content?.first?.text
            write(content); newline()
        }
    }

    func write(_ text: String?) {
        if let text, let data = text.data(using: .utf8) {
            FileHandle.standardOutput.write(data)
        }
    }

    func newline() {
        write("\n")
    }
}

// Helpers

enum ValueReader {
    case direct(String)
    case file(URL)

    init?(input: String?) throws {
        guard let input else { return nil }
        if FileManager.default.fileExists(atPath: input) {
            let url = URL(fileURLWithPath: input)
            self = .file(url)
        } else {
            self = .direct(input)
        }
    }

    func value() throws -> String {
        switch self {
        case .direct(let value):
            return value
        case .file(let url):
            return try String(contentsOf: url, encoding: .utf8)
        }
    }
}
