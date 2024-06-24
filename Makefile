main:
	@swift build
	@cp .build/debug/AnthropicCmd anthropic
	@chmod +x anthropic
	@echo "Run the program with ./anthropic"
