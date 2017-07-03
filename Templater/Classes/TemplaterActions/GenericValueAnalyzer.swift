//
//  GenericValueAnalyzer.swift
//  BalanceBy
//
//  Created by Alex on 1/3/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public final class GenericValueAnalyzer {

    public init() {
        
    }

}

extension GenericValueAnalyzer: ValueAnalyzer {

    public func value(value: String, context: ContextType) -> VariableType? {

        if let arrayIndex = extractIndex(value: value), let dotRange = value.range(of: ".", options: [.backwards]) {
            let key = value.substring(to: dotRange.lowerBound)
            if let variable = context.variable(name: key), case VariableType.array(let array) = variable, array.count > arrayIndex {
                let arrayValue = array[arrayIndex]
                return arrayValue
            }
        } else if let variable = context.variable(name: value) {
            return variable
        }

        return nil
    }

}

// MARK: - Private

fileprivate extension GenericValueAnalyzer {

    func extractIndex(value: String) -> Int? {
        if let dotRange = value.range(of: ".", options: [.backwards]) {
            let lastKey = value.substring(from: dotRange.upperBound)
            if let res = Int(lastKey), res > 0 {
                return res - 1
            }
        }
        return nil
    }

}
