//
//  ForEachAction.swift
//  BalanceBy
//
//  Created by Alex on 2/20/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public final class ForEachAction: BaseAction {

    public override func execute(data: VariableType?, context: ContextType, callback: @escaping (VariableType?, Error?) -> ()) {
        var newNextActions = [ActionProtocol]()
        logger?.log("\n\(context)")
        if let data = data {
            let arrayData: [VariableType]
            if case .array(let arr) = data {
                arrayData = arr
            } else {
                arrayData = [data]
            }
            logger?.log("for each count: \(arrayData.count)")
            for oneData in arrayData {
                for oneAction in nextActions {
                    let newAction = ActionWrapper(input: oneData, action: oneAction.copy(), attributes: attributes)
                    newNextActions.append(newAction)
                }
            }
        }
        self.nextActions = newNextActions
        callback(nil, nil)
    }

}

private final class ActionWrapper: BaseAction {

    fileprivate let input: VariableType
    fileprivate var action: ActionProtocol

    override var nextActions: [ActionProtocol] {
        get {
            return action.nextActions
        }
        set {
            action.nextActions = newValue
        }
    }

    override var elseAction: ActionProtocol? {
        get {
            return action.elseAction
        }
        set {
            action.elseAction = newValue
        }
    }
    override var logger: ActionLogger? {
        get {
            return action.logger
        }
        set {
            action.logger = newValue
        }
    }
    override var attributes: ActionAttributes {
        get {
            return action.attributes
        }
        set {
            action.attributes = newValue
        }
    }

    init(input: VariableType, action: ActionProtocol, attributes: ActionAttributes) {
        self.input = input
        self.action = action
        super.init(attributes: attributes)
    }
    
    required init(attributes: ActionAttributes) {
        fatalError("init(attributes:) has not been implemented")
    }

    public override func execute(data: VariableType?, context: ContextType, callback: @escaping (VariableType?, Error?) -> ()) {
        context.registerVariable(name: "result", value: input)
        action.execute(data: input, context: context, callback: callback)
    }

    public override func copy() -> ActionProtocol {
        return ActionWrapper(input: input, action: action, attributes: attributes)
    }

}

extension ActionWrapper: CustomStringConvertible {

    public var description: String {
        return logger?.logs ?? ""
    }

}
