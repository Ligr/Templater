//
//  Context.swift
//  BalanceBy
//
//  Created by Alex on 12/22/16.
//  Copyright © 2016 Home. All rights reserved.
//

import Foundation

internal class Context {

    fileprivate var _variables = [String: VariableType]()
    var uiConnector: UIConnectorProtocol?

}

extension Context: ContextType {

    var variables: [String: VariableType] {
        return _variables
    }

    func registerVariable(name: String, value: VariableType) {
        _variables[name] = value
    }

    func variable(name: String) -> VariableType? {
        return _variables[name]
    }

}

extension Context: CustomStringConvertible {

    public var description: String {
        var desc = "Context:"
        for variable in _variables {
            desc += "\n\(variable.key): \(variable.value)"
        }
        return desc
    }
    
}
