main:
	@swift build
	@cp .build/debug/CLI anthropic
	@chmod +x anthropic
	@echo "Run the program with ./anthropic"
