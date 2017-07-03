//
//  SearchAction.swift
//  BalanceBy
//
//  Created by Alex on 1/4/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public final class SearchAction: BaseAction {

    private let functionProcessor = FunctionProcessor()

    public override func execute(data: VariableType?, context: ContextType, callback: @escaping (VariableType?, Error?) -> ()) {
        logger?.log(attributes)
        logger?.log("\n\(context)")
        var result: VariableType? = nil
        var resultError: Error? = nil
        var groupValues = [VariableType]()

        defer {
            callback(result, resultError)
        }

        var inputData: String?
        if let valueAttribute = attributes["value", context]?.stringValue() {
            inputData = valueAttribute
        } else if case VariableType.string(let string)? = data {
            inputData = string
        }
        guard var srcString = inputData else {
            resultError = ActionError.invalidInputData
            return
        }

        // reduce initial string
        let start = attributes["start", context]?.stringValue()
        let end = attributes["end", context]?.stringValue()
        let offsetStr = attributes["offset", context]?.stringValue()
        if let start = start, let startRange = srcString.range(of: start, options: [.caseInsensitive]) {
            if let end = end, let endRange = srcString.range(of: end, options: [.caseInsensitive], range: startRange.upperBound ..< srcString.endIndex) {
                srcString = srcString.substring(with: startRange.lowerBound ..< endRange.upperBound)
            } else {
                srcString = srcString.substring(from: startRange.lowerBound)
            }
        } else if let offsetStr = offsetStr, let offset = Int(offsetStr) {
            srcString = srcString.substring(from: srcString.index(srcString.startIndex, offsetBy: offset))
        }

        // calculate final value
        if let split = attributes["split", context]?.stringValue() {
            let items = srcString.components(separatedBy: split).map {
                VariableType.string($0)
            }
            result = VariableType.array(items)
        } else if let regexStr = attributes["regex", context]?.stringValue() {
            do {
                let replace = attributes["replace", context]?.stringValue()
                let groupIndex = Int(attributes["group", context]?.stringValue() ?? "0") ?? 0
                let regex = try NSRegularExpression(pattern: regexStr, options: [.caseInsensitive])
                let matches = regex.matches(in: srcString, options: [], range: NSRange(location: 0, length: srcString.characters.count))
                let results = matches.map { match -> VariableType in
                    // store all group values
                    groupValues = [VariableType]()
                    for i in 1 ..< match.numberOfRanges {
                        let range = match.rangeAt(i)
                        let matchStr = (srcString as NSString).substring(with: range)
                        groupValues.append(VariableType.string(matchStr))
                    }

                    // actual results
                    if groupIndex < match.numberOfRanges {
                        let range = match.rangeAt(groupIndex)
                        let matchStr = (srcString as NSString).substring(with: range)
                        if let replace = replace {
                            srcString = srcString.replacingOccurrences(of: matchStr, with: replace)
                        }
                        return VariableType.string(matchStr)
                    } else {
                        resultError = ActionError.indexOutOfBounds(index: groupIndex, bounds: match.numberOfRanges)
                        return VariableType.string("")
                    }
                }
                if let _ = replace {
                    result = VariableType.string(srcString)
                } else if results.count > 1 {
                    result = VariableType.array(results)
                } else if results.count == 1, case VariableType.string(let str) = results[0] {
                    result = VariableType.string(str)
                }
            } catch {
                resultError = ActionError.invalidRegularExpression(expression: regexStr)
            }
        } else {
            result = VariableType.string(srcString)
        }

        if let function = attributes["function", context]?.stringValue(), let variable = result, resultError == nil {
            (result, resultError) = functionProcessor.value(variable: variable, functionDetails: function)
        }

        if let variableName = attributes["var", context]?.stringValue(), let variable = result, resultError == nil {
            context.registerVariable(name: "var.\(variableName)", value: variable)
        }

        if result == nil && elseAction != nil {
            resultError = ActionError.emptyResult
        } else if result == nil {
            nextActions = []
        }

        // search was successful => register group variable
        if result != nil {
            context.registerVariable(name: "group", value: .array(groupValues))
        }
    }

}
