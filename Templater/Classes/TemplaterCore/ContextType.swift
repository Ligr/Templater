//
//  ContextType.swift
//  BalanceBy
//
//  Created by Alex on 12/22/16.
//  Copyright © 2016 Home. All rights reserved.
//

import Foundation

public protocol ContextType {

    var variables: [String: VariableType] { get }
    var uiConnector: UIConnectorProtocol? { get set }

    func registerVariable(name: String, value: VariableType)
    func variable(name: String) -> VariableType?

}

public enum ContextVariables {
    
}
