//
//  DebugAction.swift
//  BalanceBy
//
//  Created by Alex on 2/8/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public final class DebugAction: ActionProtocol, ProxyActionProtocol {

    public private(set) var innerAction: ActionProtocol
    public var logger: ActionLogger? = InMemoryLogger()

    public init(action: ActionProtocol) {
        innerAction = action
        innerAction.logger = InMemoryLogger()
    }

    public var nextActions: [ActionProtocol] {
        get {
            return innerAction.nextActions
        }
        set {
            innerAction.nextActions = newValue
        }
    }

    public var elseAction: ActionProtocol? {
        get {
            return innerAction.elseAction
        }
        set {
            innerAction.elseAction = newValue
        }
    }

    public var attributes: ActionAttributes {
        get {
            return innerAction.attributes
        }
        set {
            innerAction.attributes = newValue
        }
    }

    open func execute(data: VariableType?, context: ContextType, callback: @escaping (VariableType?, Error?) -> ()) {
        let startTime = CFAbsoluteTimeGetCurrent()
        logger?.log("start action: \(type(of: innerAction))")
        if let data = data {
            logger?.log("input:\n\(data)")
        }

        innerAction.execute(data: data, context: context) { [weak self] res in
            if let strongSelf = self {
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                if let output = res.0 {
                    strongSelf.logger?.log("output:\n\(output)")
                }
                if let error = res.1 {
                    strongSelf.logger?.log("error:\n\(error)")
                }
                if let actionLogs = strongSelf.innerAction.logger?.logs {
                    strongSelf.logger?.log("\naction logs: =================================\n\(actionLogs)\n")
                }
                let timeElapsedStr = String(format: "%.3f", timeElapsed)
                strongSelf.logger?.log("end action: \(type(of: strongSelf.innerAction)), time elapsed: \(timeElapsedStr)")
            }

            callback(res.0, res.1)
        }
    }

    public func copy() -> ActionProtocol {
        return DebugAction(action: innerAction.copy())
    }

}

fileprivate extension DebugAction {

}

extension DebugAction: CustomStringConvertible {

    public var description: String {
        return logger?.logs ?? ""
    }

}

private class InMemoryLogger: ActionLogger {

    public private(set) var logs: String = ""

    func log(_ str: String?) {
        guard let str = str else { return }
        if logs.characters.count > 0 {
            logs += "\n\(str)"
        } else {
            logs += "\(str)"
        }
    }

}
