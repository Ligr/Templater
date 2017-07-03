//
//  FunctionValueAnalyzer.swift
//  BalanceBy
//
//  Created by Alex on 3/15/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public final class FunctionValueAnalyzer: ValueAnalyzer {

    public init() {

    }

    public func value(value: String, context: ContextType) -> VariableType? {
        if value.hasPrefix("function.") {
            if value.hasSuffix(".time") {
                return .string("\(Date().timeIntervalSince1970)")
            }
        }
        return nil
    }
    
}
