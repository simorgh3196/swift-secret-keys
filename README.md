# SecretKeys

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
  - [ ] Setup CI
  - [ ] Add example projects
- [ ] Documentation
  - [ ] Add document comments
  - [ ] Support DocC
  - [ ] Enhance README

## Configuration File

`.secretkeys.yml`

```yaml
# Determine the name of the struct. (Default: `Keys`)
namespace: Keys

# Also generate unit tests for accessing keys. (Default: `false`)
withUnitTest: false

# The path of output directory. (Default: `./Dependencies`)
outputDirectory: ./Dependencies

# In addition to environment variables, a properties file can be read.
source: .env

# Mapping variable names to environment variable names.
keys:
  clientID: CLIENT_ID
  clientSecret: CLIENT_SECRET

# Set the target according to the environment and other requirements that
# you want to use different build modes, etc.
targets:
  - name: SharedSecretKeys
    namespace: SharedKeys # can override namespace
  - name: SecretKeysDebug
  - name: SecretKeysProduction
    source: .env.production # can replace a properties file
    keys: # can override key mappings
      clientSecret: PRODUCTION_CLIENT_SECRET
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
