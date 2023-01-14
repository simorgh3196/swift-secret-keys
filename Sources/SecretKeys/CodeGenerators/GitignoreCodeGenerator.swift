// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum GitignoreCodeGenerator {
    static func generateCode() -> String {
        """
        .DS_Store
        /.build
        /Packages
        /*.xcodeproj
        xcuserdata/
        DerivedData/
        .swiftpm/config/registries.json
        .swiftpm/xcode/package.xcworkspace/contents.xcworkspacedata
        .netrc
        SecretKeys+Keys.swift
        """
    }
}
