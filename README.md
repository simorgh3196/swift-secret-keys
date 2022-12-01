# SecretKeys

A generator that allows access to environment variables and values defined in the properties file.

⚠️ This project is currently under development.

## Plan

- [ ] Features
  - [ ] Loading environment from process
  - [x] Change behavior by configuration file
  - [ ] Add tests for tool
  - [ ] Add installation methods
    - [ ] SwiftPM plugin
    - [ ] Mint
  - [ ] Generate tests for generated project
  - [ ] Setup CI
- [ ] Documentation
  - [ ] Add document comments
  - [ ] Suport DocC
  - [ ] Enhance README

## Configuration File

```yaml
# Select the package manager to use from `spm` or `cocoapods`. (Default: `spm`)
packageManager: spm

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
