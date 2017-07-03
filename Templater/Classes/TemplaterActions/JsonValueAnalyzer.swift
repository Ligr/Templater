//
//  JsonValueAnalyzer.swift
//  BalanceBy
//
//  Created by Alex on 3/15/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public final class JsonValueAnalyzer {

    public init() {

    }

}

extension JsonValueAnalyzer: ValueAnalyzer {

    public func value(value: String, context: ContextType) -> VariableType? {
        if value.hasPrefix("json.") {
            let range = value.range(of: "json.")!
            let jsonKey = value.substring(from: value.index(range.upperBound, offsetBy: 0))
            if case .any(let rawJson)? = context.variable(name: "json") {
                if let json = rawJson as? [String: AnyObject], let jsonValue = json[jsonKey] {
                    return .string("\(jsonValue)")
                }
            }
        }
        return nil
    }
    
}
