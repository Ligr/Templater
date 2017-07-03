//
//  ExceptionAction.swift
//  BalanceBy
//
//  Created by Alex on 3/11/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public final class ExceptionAction: BaseAction {

    public override func execute(data: VariableType?, context: ContextType, callback: @escaping (VariableType?, Error?) -> ()) {
        var error = ActionError.generic(message: "unhandled exception")
        if let value = attributes["value", context]?.stringValue() {
            error = ActionError.userException(message: value)
        }
        callback(data, error)
    }
    
}
