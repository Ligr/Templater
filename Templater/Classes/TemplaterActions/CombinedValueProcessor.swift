//
//  CombinedValueProcessor.swift
//  BalanceBy
//
//  Created by Alex on 1/3/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public final class CombinedValueProcessor {

    fileprivate let analyzers: [ValueAnalyzer]
    fileprivate let valueRegex = try! NSRegularExpression(pattern: "\\$\\{[\\d\\w\\.]*\\}", options: [.caseInsensitive])

    public init(analyzers: [ValueAnalyzer]) {
        self.analyzers = analyzers
    }

}

// MARK: - ValueProcessor

extension CombinedValueProcessor: ValueProcessor {

    public func value(value: String, context: ContextType) -> String {
        var result = value
        let keys = extrackKeys(value: value)
        for key in keys {
            var replaced = false
            let formatedKey = formatKey(key)
            for analyzer in analyzers {
                if let convertedValue = analyzer.value(value: formatedKey, context: context)?.stringValue() {
                    result = result.replacingOccurrences(of: formatedKey, with: convertedValue)
                    replaced = true
                    break
                }
            }
            if replaced == false {
                print("[CombinedValueProcessor][WARNING]: no value for expression '\(formatedKey)'")
            }
        }
        return result
    }

}

// MARK: - Private

private extension CombinedValueProcessor {

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
