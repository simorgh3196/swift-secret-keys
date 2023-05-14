PACKAGE_NAME=secret-keys

ARTIFACT_BUNDLE=$(PACKAGE_NAME).artifactbundle
ARTIFACT_BUNDLE_INFO_TEMPLATE=artifact_info.json

TEST_DESTINATION=platform=iOS Simulator,name=iPhone 14 Pro,OS=16.2

.PHONY: build
build:
	@$(MAKE) .build/debug/$(PACKAGE_NAME)

.PHONY: release-build
release-build:
	@$(MAKE) .build/apple/Products/Release/$(PACKAGE_NAME)

.PHONY: artifact
artifact:
	@$(MAKE) $(PACKAGE_NAME).artifactbundle.zip
	swift package compute-checksum $(PACKAGE_NAME).artifactbundle.zip

.PHONY: test
test:
	swift test

.PHONY: test-for-command-plugin
test-for-command-plugin: example
	swift test --package-path Example/CommandPluginExample -c debug
	swift test --package-path Example/CommandPluginExample -c release
	xcodebuild \
		-workspace Example/CommandPluginExample/CocoaPodsExample/CocoaPodsExample.xcworkspace \
		-scheme CocoaPodsExample \
		-sdk iphonesimulator \
		-destination "$(TEST_DESTINATION)" \
		test

.PHONY: lint
lint:
	mint run swiftlint Sources Tests

.PHONY: format
format:
	mint run swiftlint --fix Sources Tests

.PHONY: example
example:
	swift package plugin --allow-writing-to-package-directory $(PACKAGE_NAME) generate \
		-c Example/CommandPluginExample/.secretkeys.swiftpm.yml \
		-p Example/CommandPluginExample
	swift package plugin --allow-writing-to-package-directory $(PACKAGE_NAME) generate \
		-c Example/CommandPluginExample/.secretkeys.sources.yml \
		-p Example/CommandPluginExample
	swift package plugin --allow-writing-to-package-directory $(PACKAGE_NAME) generate \
		-c Example/CommandPluginExample/.secretkeys.cocoapods.yml \
		-p Example/CommandPluginExample
	pod install --project-directory=Example/CommandPluginExample/CocoaPodsExample

.build/debug/$(PACKAGE_NAME): Package.swift Sources/**/*.swift
	swift build
	@touch $@

.build/apple/Products/Release/$(PACKAGE_NAME): Package.swift Sources/**/*.swift
	swift build -c release --arch arm64 --arch x86_64
	@touch $@

$(PACKAGE_NAME).artifactbundle.zip: .build/apple/Products/Release/$(PROJECT_NAME) LICENCE README.md
	@mkdir -p $(ARTIFACT_BUNDLE)/$(PACKAGE_NAME)/bin
	@sed -e "s/__VERSION__/$(VERSION)/" $(ARTIFACT_BUNDLE_INFO_TEMPLATE) > $(ARTIFACT_BUNDLE)/info.json
	@cp .build/apple/Products/Release/$(PACKAGE_NAME) $(ARTIFACT_BUNDLE)/$(PROJECT_NAME)/bin/
	@cp LICENCE README.md $(ARTIFACT_BUNDLE)/$(PACKAGE_NAME)/
	@zip -yr $(PACKAGE_NAME).artifactbundle.zip $(PROJECT_NAME).artifactbundle
	@rm -rf $(PROJECT_NAME).artifactbundle
