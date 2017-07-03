//
//  Templater.swift
//  BalanceBy
//
//  Created by Alex on 12/21/16.
//  Copyright © 2016 Home. All rights reserved.
//

import Foundation

public protocol TemplaterProtocol {

    var uiConnector: UIConnectorProtocol? { get set }

    func registerVariable(name: String, value: VariableType)
    func start(callback: @escaping ([String: VariableType], Error?) -> ())

}

public func CreateTemplater(actions: [ActionProtocol], data: VariableType?) -> TemplaterProtocol {
    return Templater(actions: actions, data: data, context: Context())
}

// ====================================================================================

private class Templater {

    fileprivate let actions: [ActionProtocol]
    fileprivate var context: ContextType
    fileprivate var processor: ActionsProcessorProtocol?
    fileprivate let initialData: VariableType?

    init(actions: [ActionProtocol], data: VariableType?, context: ContextType) {
        self.actions = actions
        self.context = context
        self.initialData = data
    }

}

extension Templater: TemplaterProtocol {

    var uiConnector: UIConnectorProtocol? {
        get {
            return context.uiConnector
        }
        set {
            context.uiConnector = newValue
        }
    }

    func registerVariable(name: String, value: VariableType) {
        context.registerVariable(name: name, value: value)
    }

    func start(callback: @escaping ([String: VariableType], Error?) -> ()) {
        processor = ActionsProcessor(actions: actions, data: initialData, context: context)
        processor?.process { (context, error) in
            callback(context.variables, error)
        }
    }

}

extension Templater: CustomStringConvertible {

    public var description: String {
        var result = "Templater info"
        if let processor = processor {
            result += "\n\(processor)"
        }
        return result
    }

}
