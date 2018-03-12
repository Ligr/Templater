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
                srcString = String(srcString[startRange.lowerBound ..< endRange.upperBound])
            } else {
                srcString = String(srcString[startRange.lowerBound...])
            }
        } else if let offsetStr = offsetStr, let offset = Int(offsetStr) {
            srcString = String(srcString[srcString.index(srcString.startIndex, offsetBy: offset)...])
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
                let matches = regex.matches(in: srcString, options: [], range: NSRange(location: 0, length: srcString.count))
                // reverse itteration due to possible replaces
                let results = matches.reversed().map { match -> VariableType in
                    // store all group values
                    groupValues = [VariableType]()
                    for i in 1 ..< match.numberOfRanges {
                        let range = match.range(at: i)
                        let matchStr = (srcString as NSString).substring(with: range)
                        groupValues.append(VariableType.string(matchStr))
                    }

                    // actual results
                    if groupIndex < match.numberOfRanges, let range = Range(match.range(at: groupIndex), in: srcString) {
                        let matchStr = String(srcString[range])
                        if let replace = replace {
                            srcString = srcString.replacingOccurrences(of: matchStr, with: replace, range: range)
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
            if let encode = attributes["encode", context]?.stringValue() {
                let processor = EncodeProcessor()
                let (newVar, _) = processor.value(variable: variable, encodeDetails: encode)
                if let newVar = newVar {
                    context.registerVariable(name: "var.\(variableName)", value: newVar)
                } else {
                    context.registerVariable(name: "var.\(variableName)", value: variable)
                }
            } else {
                context.registerVariable(name: "var.\(variableName)", value: variable)
            }
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
