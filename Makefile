SWIFT_FORMAT := $(shell xcrun --find swift-format)
PATHS := "SpaceX Info" Packages/Space/Sources Packages/Space/Tests

install:
	brew bundle

format:
	$(SWIFT_FORMAT) --configuration swift-format.json -r -i $(PATHS)

lint:
	swiftlint --quiet
	$(SWIFT_FORMAT) lint -r --configuration swift-format.json $(PATHS)

fix: format
	swiftlint --quiet --fix
	@$(MAKE) lint
