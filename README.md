# swift-secret-keys

[![SecretKeys](https://github.com/simorgh3196/swift-secret-keys/actions/workflows/ci.yml/badge.svg)](https://github.com/simorgh3196/swift-secret-keys/actions/workflows/ci.yml)
[![SwiftLint](https://github.com/simorgh3196/swift-secret-keys/actions/workflows/swiftlint.yml/badge.svg)](https://github.com/simorgh3196/swift-secret-keys/actions/workflows/swiftlint.yml)

A generator that allows access to environment variables and values defined in the properties file.

## Installation

### Using Swift Package Manager (Command Plugin)

**Installation:**

Add a dependency to `Package.swift`.

```swift
.package(url: "https://github.com/simorgh3196/swift-secret-keys", from: "0.1.0"),
```

**Execution:**

```shell
swift package plugin --allow-writing-to-package-directory secret-keys generate
```

### Using [Mint](https://github.com/yonaskolb/Mint)

**Installation:**

Add the following to your `Mintfile`.

```shell
simorgh3196/SecretKeys@0.1.0
```

**Execution:**

```shell
mint run secret-keys generate
```

## Command Options

```shell
secret-keys generate --help
```

```shell
USAGE: secret-keys generate [--config <config>] [--project <project>] [--verbose]

OPTIONS:
  -c, --config <config>   The path to the configuration file (default: .secretkeys.yml)
  -p, --project <project> The path to the project root (default: .)
  -v, --verbose           Enables verbose log messages
  --version               Show the version.
  -h, --help              Show help information.
```

## Usage

For a detailed example, see [Example/CommandPluginExample](https://github.com/simorgh3196/swift-secret-keys/tree/main/Example/CommandPluginExample).

### Generate as Swift Package project

1. Create a configuration file. ([docs](#configuration-file))
1. Set `exportType` in the Configuration File to `swiftpm`.
1. Run the `generate` command.

    ```shell
    <config:output>
    └── SecretKeys
       ├── .gitignore
       ├── Package.swift
       └── Sources
           ├── Keys
           │  ├── SecretKeys+Keys.swift # Specified in .gitignore by default
           │  └── SecretKeys.swift
           └── SecretValueDecoder
             └── SecretValueDecoder.swift
    ```

1. Add a dependency to your project.

    ```swift
    .package(name: "SecretKeys", path: "Dependencies/SwiftPM/SecretKeys")
    ```

### Generate as CocoaPods project

1. Create a configuration file. ([docs](#configuration-file))
1. Set `exportType` in the Configuration File to `cocoapods`.
1. Run the `generate` command.

    ```shell
    <config:output>
    └── SecretKeys
       ├── .gitignore
       ├── Keys.podspec
       ├── SecretValueDecoder.podspec
       └── Sources
           ├── Keys
           │  ├── SecretKeys+Keys.swift # Specified in .gitignore by default
           │  └── SecretKeys.swift
           └── SecretValueDecoder
             └── SecretValueDecoder.swift
    ```

1. Add a dependency to your project.

    ```ruby
    pod 'Keys', :path => '<config:output>/SecretKeys'
    pod 'SecretValueDecoder', :path => '<config:output>/SecretKeys'
    ```

### Generate as swift codes

1. Create a configuration file. ([docs](#configuration-file))
1. Set `exportType` in the Configuration File to `sourcesOnly`.
1. Run the `generate` command.

    ```shell
    <config:output>
    └── SecretKeys
       ├── .gitignore
       ├── Keys
       │  └── Keys.generated.swift # Specified in .gitignore by default
       └── SecretValueDecoder.generated.swift # Specified in .gitignore by default
    ```

1. Add swift codes to your project targets.

## Configuration File

`.secretkeys.yml`

```yaml
# Select the export type from `swiftpm`, `cocoapods` or `sourcesOnly`. (Default: `swiftpm`)
exportType: swiftpm

# The path of output directory. (Default: `Dependencies`)
output: Dependencies

# In addition to environment variables, a properties file can be read.
envFile: .env

# Set the target according to the environment and other requirements that
# you want to use different build modes, etc.
targets:
  SecretKeysDebug:
    namespace: MySecretKeys # can override namespace (Default: `Keys`)
    keys:
      clientID:
        name: CLIENT_ID_DEBUG
      clientSecret:
        name: CLIENT_SECRET_DEBUG
      apiPath:
        name: BASE_API_PATH
      home:
        name: HOME # can load environment variables

  SecretKeysProduction:
    keys:
      clientID:
        name: CLIENT_ID_PRODUCTION
        config:
          DEBUG: CLIENT_ID_ADHOC # can override `name` only when `#if DEBUG`
      clientSecret:
        name: CLIENT_SECRET_PRODUCTION
        config:
          DEBUG: CLIENT_SECRET_ADHOC
      apiPath:
        name: BASE_API_PATH
```
