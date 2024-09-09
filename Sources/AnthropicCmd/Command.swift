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
            ChatCompletionStream.self,
            ChatCompletionWithTool.self,
        ],
        defaultSubcommand: ChatCompletion.self
    )
}

struct GlobalOptions: ParsableCommand {
    @Option(name: .shortAndLong, help: "Your API key.")
    var key: String
    
    @Option(name: .shortAndLong, help: "Model to use.")
    var model = Defaults.chatModel
    
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
        let client = AnthropicClient(configuration: .init(token: global.key))
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

    @Flag(help: "Use the stream endpoint.")
    var stream = false
    
    func run() async throws {
        let client = AnthropicClient(configuration: .init(token: global.key))
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
            messages.append(.init(role: .user, content: [.init(type: .text, text: input)]))
            
            let req = ChatRequest(
                model: global.model,
                messages: messages,
                system: global.system
            )

            if stream {
                var message: ChatResponse? = nil
                for try await resp in client.chatStream(req) {
                    write(resp.delta?.text)
                    message = resp.apply(to: message)
                }
                newline()
                let content = message?.content?.map { ChatRequest.Message.Content(content: $0) }
                messages.append(.init(role: .assistant, content: content ?? []))
            } else {
                let resp = try await client.chat(req)
                let content = resp.content?.map { ChatRequest.Message.Content(content: $0) }
                messages.append(.init(role: .assistant, content: content ?? []))
                
                for content in resp.content ?? [] {
                    write(content.text); newline()
                }
            }
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

struct ChatCompletionStream: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "stream",
        abstract: "Completes a streaming chat request."
    )
    
    @OptionGroup
    var global: GlobalOptions
    
    @Argument(help: "Your messages.")
    var content: String
    
    func run() async throws {
        let client = AnthropicClient(configuration: .init(token: global.key))
        let messages: [ChatRequest.Message] = [.init(role: .user, content: [.init(type: .text, text: content)])]
        let req = ChatRequest(
            model: global.model,
            messages: messages,
            system: global.system
        )
        for try await resp in client.chatStream(req) {
            if let text = resp.delta?.text, let data = text.data(using: .utf8) {
                try FileHandle.standardOutput.write(contentsOf: data)
            }
        }
    }
}

struct ChatCompletionWithTool: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "tool",
        abstract: "Completes a chat request using a tool."
    )
    
    @OptionGroup
    var global: GlobalOptions
    
    @Argument(help: "Your messages.")
    var content: String
    
    func run() async throws {
        let client = AnthropicClient(configuration: .init(token: global.key))
        let messages: [ChatRequest.Message] = [.init(role: .user, content: [.init(type: .text, text: content)])]
        let tools: [ChatRequest.Tool] = [
            .init(
                name: "get_weather",
                description: "Get the current weather in a given location",
                inputSchema: .init(
                    type: .object,
                    properties: [
                        "location": .init(type: .string, description: "The city and state, e.g. San Francisco, CA")
                    ],
                    required: ["location"]
                )
            )
        ]
        let req = ChatRequest(
            model: global.model,
            messages: messages,
            system: global.system,
            tools: tools
        )
        let resp = try await client.chat(req)
        
        for content in resp.content ?? [] {
            switch content.type {
            case .text, .text_delta:
                print(content.text ?? "missing content")
            case .tool_use:
                if let data = try? JSONEncoder().encode(content.input), let str = String(data: data, encoding: .utf8) {
                    print("\(content.name ?? "missing name")(\(str))")
                } else {
                    print("Error: missing name or input")
                }
            case .input_json_delta:
                print(content.partialJSON ?? "missing JSON")
            case .none:
                break
            }
        }
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
