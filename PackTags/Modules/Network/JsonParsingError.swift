//
//  File.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 14.05.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

enum JsonParsingError: Error {
    // TODO: Not in use yet
    case invalidData
    case invalidFormat
    case missingValue(key: String)
    case typeMismatch(expected: String, actual: String)
}
