//
//  BaseAction.swift
//  BalanceBy
//
//  Created by Alex on 12/27/16.
//  Copyright © 2016 Home. All rights reserved.
//

import Foundation

open class BaseAction: ActionProtocol {

    open var nextActions: [ActionProtocol] = [ActionProtocol]()
    open var elseAction: ActionProtocol? = nil
    open var logger: ActionLogger? = nil
    open var attributes: ActionAttributes

    required public init(attributes: ActionAttributes) {
        self.attributes = attributes
    }

    open func execute(data: VariableType?, context: ContextType, callback: @escaping (VariableType?, Error?) -> ()) {
        callback(data, nil)
    }

    open func copy() -> ActionProtocol {
        let actionType = type(of: self)
        let resultAction = actionType.init(attributes: attributes)
        resultAction.elseAction = self.elseAction?.copy()
        var resultNextActions = [ActionProtocol]()
        for action in nextActions {
            resultNextActions.append(action.copy())
        }
        resultAction.nextActions = resultNextActions
        return resultAction
    }

}
