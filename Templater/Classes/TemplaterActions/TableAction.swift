//
//  TableAction.swift
//  BalanceBy
//
//  Created by Alex on 3/2/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public class TableAction: BaseAction {

    public override func execute(data: VariableType?, context: ContextType, callback: @escaping (VariableType?, Error?) -> ()) {
        DispatchQueue.global(qos: .utility).async {
            var resultData = [VariableType]()
            var inputStr = self.attributes["value", context]?.stringValue()
            if inputStr == nil {
                inputStr = data?.stringValue()
            }
            if let inputStr = inputStr {
                let tdRegexPattern = "<td[\\s\\S]*?>([\\s\\S]*?)</td>"
                let trRegexPattern = "<tr[\\s\\S]*?>([\\s\\S]*?)</tr>"
                let tdRegex = try! NSRegularExpression(pattern: tdRegexPattern, options: .caseInsensitive)
                let trRegex = try! NSRegularExpression(pattern: trRegexPattern, options: .caseInsensitive)
                trRegex.enumerateMatches(in: inputStr, options: [], range: NSRange(location: 0, length: inputStr.count), using: { (result, flags, exit) in
                    if let result = result, let trRange = inputStr.rangeFromNSRange(result.range) {
                        let trStr = inputStr.substring(with: trRange)
                        var tdData = [VariableType]()
                        tdRegex.enumerateMatches(in: trStr, options: [], range: NSRange(location: 0, length: trStr.count), using: { (result, flags, exit) in
                            if let result = result, result.numberOfRanges > 1 {
                                if let tdRange = trStr.rangeFromNSRange(result.range(at: 1)) {
                                    let tdStr = trStr.substring(with: tdRange)
                                    tdData.append(.string(tdStr))
                                }
                            }
                        })
                        resultData.append(.array(tdData))
                    }
                })
            }
            
            DispatchQueue.main.async(execute: {
                callback(.array(resultData), nil)
            })
        }
    }

}
