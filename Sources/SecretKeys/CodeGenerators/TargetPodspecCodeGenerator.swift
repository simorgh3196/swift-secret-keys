// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum TargetPodspecCodeGenerator {
    static func generateCode(target: Configuration.Target) -> String {
        """
        # DO NOT MODIFY
        # Automatically generated by SecretKeys (https://github.com/simorgh3196/SecretKeys)

        Pod::Spec.new do |spec|
          spec.name                  = '\(target.name)'
          spec.summary               = 'A generator that allows access to environment variables and values defined in the properties file.'
          spec.homepage              = 'https://github.com/simorgh3196/SecretKeys'
          spec.version               = '1.0.0'
          spec.authors               = { 'SecretKeys' => 'https://github.com/simorgh3196/SecretKeys' }
          spec.source                = { path: "./" }
          spec.source_files          = 'Sources/\(target.name)/*.swift'
          spec.ios.deployment_target = '11.0'
          spec.swift_version         = '5.0'

          spec.dependency 'SecretValueDecoder', '~> 1.0.0'
        end
        """
    }
}