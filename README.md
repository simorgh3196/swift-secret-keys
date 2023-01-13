# swift-secret-keys

A generator that allows access to environment variables and values defined in the properties file.

⚠️ This project is currently under development.

## Plan

- [ ] Features
  - [x] Loading environment from process
  - [x] Change behavior by configuration file
  - [ ] Add tests for tool
  - [ ] Add installation methods
    - [ ] SwiftPM plugin
    - [x] Mint
  - [ ] Generate tests for generated project
  - [x] Setup CI
  - [ ] Add example projects
- [ ] Documentation
  - [ ] Add document comments
  - [ ] Support DocC
  - [ ] Enhance README

## Configuration File

`.secretkeys.yml`

```yaml
# Select the export type from `swiftpm`, `cocoapods` or `sourcesOnly`. (Default: `swiftpm`)
exportType: swiftpm

# Also generate unit tests for accessing keys. (Default: `false`)
withUnitTest: false

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
        name: CLIENT_ID_DEBUG # can override `name` only when `#if DEBUG`
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

## Installation

### [Mint](https://github.com/yonaskolb/Mint)

```sh
mint install simorgh3196/SecretKeys
```

## Getting Started

Add the config file to your project and call the generate command.

```sh
secret-keys generate
```

```
USAGE: secret-keys generate [--config <config>] [--verbose]

OPTIONS:
  -c, --config <config>   The path to the configuration file (default: .secretkeys.yml)
  --verbose               Enables verbose log messages
  --version               Show the version.
  -h, --help              Show help information.
```
