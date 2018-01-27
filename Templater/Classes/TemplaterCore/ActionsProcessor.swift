//
//  ActionsProcessor.swift
//  BalanceBy
//
//  Created by Alex on 1/7/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

internal final class ActionsProcessor {

    fileprivate let actionsQueue: ActionsQueue
    fileprivate let context: ContextType
    fileprivate var finishedActions = [ActionProtocol]()

    internal init(actions: [ActionProtocol], data: VariableType?, context: ContextType) {
        self.actionsQueue = ActionsQueue(actions: actions, data: data)
        self.context = context
    }

}

extension ActionsProcessor: ActionsProcessorProtocol {

    func process(callback: @escaping (ContextType, Error?) -> ()) {
        let captureContext = context
        processQueue(actionsQueue: actionsQueue) { (error) in
            callback(captureContext, error)
        }
    }

}

fileprivate extension ActionsProcessor {

    func processQueue(actionsQueue: ActionsQueue, finishHandler: @escaping (Error?) -> ()) {
        if let (action, inData) = actionsQueue.popFirst() {
            DispatchQueue.global(qos: .utility).async {
                action.execute(data: inData, context: self.context, callback: { [weak self] (outData, error) in
                    self?.finishedActions.append(action)
                    if let error = error {
                        // if there is else action - execute it
                        if let elseAction = action.elseAction {
                            actionsQueue.queue(elseAction, data: inData, at: .first)
                            self?.processQueue(actionsQueue: actionsQueue, finishHandler: finishHandler)
                        } else {
                            // othewise return error
                            finishHandler(error)
                        }
                    } else {
                        // everything fine - execute next actions
                        actionsQueue.queue(contentsOf: action.nextActions, data: outData, at: .first)
                        self?.processQueue(actionsQueue: actionsQueue, finishHandler: finishHandler)
                    }
                })
            }
        } else {
            finishHandler(nil)
        }
    }

}

extension ActionsProcessor: CustomStringConvertible {

    public var description: String {
        var result = "Processed actions\n"
        for (i, action) in finishedActions.enumerated() {
            result += (i > 0 ? "\n" : "") + "\(i). ===========================================\n\(action)"
        }
        return result
    }

}

// =================================================================

private final class ActionsQueue {

    enum Position {
        case first
    }

    fileprivate var actions: [(action: ActionProtocol, data: VariableType?)]

    init(actions: [(action: ActionProtocol, data: VariableType?)]) {
        self.actions = actions
    }

    init(actions: [ActionProtocol], data: VariableType?) {
        self.actions = actions.map { (action: $0, data: data) }
    }

}

extension ActionsQueue {

    func popFirst() -> (action: ActionProtocol, data: VariableType?)? {
        guard actions.count > 0 else { return nil }
        return actions.removeFirst()
    }

    func queue(contentsOf actions: [ActionProtocol], data: VariableType?, at: Position) {
        queue(contentsOf: actions.map { (action: $0, data: data) } , at: at)
    }

    func queue(contentsOf actions: [(action: ActionProtocol, data: VariableType?)], at: Position) {
        switch at {
        case .first:
            if self.actions.count > 0 {
                self.actions.insert(contentsOf: actions, at: 0)
            } else {
                self.actions.append(contentsOf: actions)
            }
        }
    }

    func queue(_ action: ActionProtocol, data: VariableType?, at position: Position) {
        queue(contentsOf: [(action: action, data: data)], at: position)
    }

}
