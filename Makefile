ARTIFACT_BUNDLE=secret-keys.artifactbundle
ARTIFACT_BUNDLE_INFO_TEMPLATE=artifact_info.json

.PHONY: build
build:
	@$(MAKE) .build/debug/secret-keys

.PHONY: release-build
release-build:
	@$(MAKE) .build/release/secret-keys

.PHONY: artifact
artifact:
	@$(MAKE) secret-keys.artifactbundle

.PHONY: test
test:
	swift test

.PHONY: test-for-command-plugin
test-for-command-plugin: example
	swift test --package-path Example/CommandPluginExample -c debug
	swift test --package-path Example/CommandPluginExample -c release

.PHONY: lint
lint:
	mint run swiftlint Sources Tests

.PHONY: format
format:
	mint run swiftlint --fix Sources Tests

.PHONY: example
example:
	swift package plugin --allow-writing-to-package-directory secret-keys generate \
		-c Example/CommandPluginExample/.secretkeys.swiftpm.yml \
		-p Example/CommandPluginExample
	swift package plugin --allow-writing-to-package-directory secret-keys generate \
		-c Example/CommandPluginExample/.secretkeys.sources.yml \
		-p Example/CommandPluginExample

.build/debug/secret-keys: Package.swift Sources/**/*.swift
	swift build
	@touch $@

.build/release/secret-keys: Package.swift Sources/**/*.swift
	swift build -c release --arch arm64 --arch x86_64
	@touch $@

secret-keys.artifactbundle: .build/release/secret-keys LICENCE README.md
	rm -rf secret-keys.artifactbundle
	mkdir -p $(ARTIFACT_BUNDLE)/secret-keys/bin
	sed -e 's/__VERSION__/$(VERSION)/' $(ARTIFACT_BUNDLE_INFO_TEMPLATE) > $(ARTIFACT_BUNDLE)/info.json
	cp .build/release/secret-keys $(ARTIFACT_BUNDLE)/secret-keys/bin/
	cp LICENCE README.md $(ARTIFACT_BUNDLE)/secret-keys/
	@touch $@
