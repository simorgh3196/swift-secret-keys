// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum GitignoreCodeGenerator {
    static func generateCode() -> String {
        """
        SecretKeys.swift
        *.generated.swift
        """
    }
}
