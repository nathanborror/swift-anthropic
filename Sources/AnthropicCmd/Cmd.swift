import Foundation
import ArgumentParser
import Anthropic

@main
struct Cmd: AsyncParsableCommand {
    
    static var configuration = CommandConfiguration(
        abstract: "A utility for interacting with the Anthropic API.",
        version: "0.0.1",
        subcommands: [
            ChatCompletion.self,
            ChatStreamCompletion.self,
        ]
    )
}

struct Options: ParsableArguments {
    @Option(help: "Your API token.")
    var token = ""
    
    @Option(help: "Model to use.")
    var model = ""
    
    @Argument(help: "Your messages.")
    var prompt = ""
}

struct ChatCompletion: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Completes a chat request.")
    
    @OptionGroup var options: Options
    
    func run() async throws {
        let client = AnthropicClient(token: options.token)
        let payload = ChatRequest(model: options.model, messages: [.init(role: .user, content: options.prompt)])
        let message = try await client.chat(payload)
        print(message.content.first?.text ?? "")
    }
}

struct ChatStreamCompletion: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Completes a chat request, streaming the response.")
    
    @OptionGroup var options: Options
    
    func run() async throws {
        let client = AnthropicClient(token: options.token)
        let payload = ChatRequest(model: options.model, messages: [.init(role: .user, content: options.prompt)])
        let stream: AsyncThrowingStream<ChatStreamResponse, Error> = client.chatStream(payload)
        for try await result in stream {
            if let content = result.delta?.text, let data = content.data(using: .utf8) {
                try FileHandle.standardOutput.write(contentsOf: data)
            }
        }
    }
}
