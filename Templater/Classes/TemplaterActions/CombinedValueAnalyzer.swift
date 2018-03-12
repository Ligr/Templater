//
//  CombinedValueAnalyzer.swift
//  BalanceBy
//
//  Created by Alex on 3/7/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public final class CombinedValueAnalyzer: ValueAnalyzer {

    private let analyzers: [ValueAnalyzer]
    private let valueRegex = try! NSRegularExpression(pattern: "\\$\\{[\\d\\w\\.]*\\}", options: [.caseInsensitive])

    public init(analyzers: [ValueAnalyzer]) {
        self.analyzers = analyzers
    }

    public func value(value: String, context: ContextType) -> VariableType? {
        var result: VariableType? = .string(value)
        let keys = extrackKeys(value: value)
        for key in keys {
            var replaced = false
            for analyzer in analyzers {
                if let convertedValue = analyzer.value(value: key, context: context) {
                    if formatKey(key) == value {
                        result = convertedValue
                    } else if let convertedValueStr = convertedValue.stringValue(), let resultStr = result?.stringValue() {
                        result = .string(resultStr.replacingOccurrences(of: formatKey(key), with: convertedValueStr))
                    } else {
                        result = .string(value)
                    }
                    replaced = true
                    break
                }
            }
            if replaced == false {
                print("[CombinedValueAnalyzer][WARNING]: no value for expression '\(formatKey(key))'")
            }
        }
        return result
    }

    // MARK: - Private
    func formatKey(_ key: String) -> String {
        return "${\(key)}"
    }

    func extrackKeys(value: String) -> [String] {
        let text = value as NSString
        let matches = valueRegex.matches(in: value, options: [], range: NSRange(location: 0, length: text.length))
        let keys = matches.map { match -> String in
            let expression = text.substring(with: match.range)
            let start = expression.index(expression.startIndex, offsetBy: 2)
            let end = expression.index(before: expression.endIndex)
            return String(expression[start..<end])
        }
        return keys
    }

}
