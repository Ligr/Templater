//
//  ResultValidationAction.swift
//  BalanceBy
//
//  Created by Alex on 4/6/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public final class ResultValidationAction {

    public var nextActions: [ActionProtocol] {
        get { return innerAction.nextActions }
        set { innerAction.nextActions = newValue }
    }
    public var elseAction: ActionProtocol? {
        get { return innerAction.elseAction }
        set { innerAction.elseAction = newValue }
    }
    public var logger: ActionLogger? {
        get { return innerAction.logger }
        set { innerAction.logger = newValue }
    }
    public var attributes: ActionAttributes {
        get { return innerAction.attributes }
        set { innerAction.attributes = newValue }
    }
    public var params: [ActionAttributes] {
        get { return innerAction.params }
        set { innerAction.params = newValue }
    }

    fileprivate(set) public var innerAction: ActionProtocol

    public init(action: ActionProtocol) {
        self.innerAction = action
    }

}

extension ResultValidationAction: ProxyActionProtocol {

}

extension ResultValidationAction: ActionProtocol {

    public func execute(data: VariableType?, context: ContextType, callback: @escaping (VariableType?, Error?) -> ()) {
        innerAction.execute(data: data, context: context) { [weak self] (outData, error) in
            guard let strongSelf = self else {
                callback(outData, error)
                return
            }
            if error == nil && outData == nil, let required = strongSelf.innerAction.attributes["required", context]?.stringValue(), required.lowercased() == "true" {
                var error = ActionError.emptyResult
                if let onError = strongSelf.innerAction.attributes["onError", context]?.stringValue() {
                    error = ActionError.userException(message: onError)
                }
                callback(outData, error)
            } else {
                // error appeared however action is not required and there is no 'else' action => no need to process inner actions and we can ignore this error
                if let _ = error, strongSelf.innerAction.elseAction == nil {
                    strongSelf.innerAction.nextActions = []
                    callback(outData, nil)
                } else {
                    callback(outData, error)
                }
            }
        }
    }

    public func copy() -> ActionProtocol {
        return ResultValidationAction(action: innerAction.copy())
    }

}
