//
//  VarAction.swift
//  BalanceBy
//
//  Created by Alex on 3/2/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public final class VarAction: BaseAction {

    public override func execute(data: VariableType?, context: ContextType, callback: @escaping (VariableType?, Error?) -> ()) {
        guard let name = attributes["name", context] else {
            callback(nil, ActionError.missingAttribute(name: "name"))
            return
        }
        var newVar: VariableType?
        if let value = attributes["value", context] {
            newVar = value
        } else {
            newVar = data
        }
        if let function = attributes["function", context]?.stringValue(), let rawVar = newVar {
            let processor = FunctionProcessor()
            (newVar, _) = processor.value(variable: rawVar, functionDetails: function)
        }
        if let encode = attributes["encode", context]?.stringValue(), let rawVar = newVar {
            let processor = EncodeProcessor()
            (newVar, _) = processor.value(variable: rawVar, encodeDetails: encode)
        }
        if let newVar = newVar {
            if attributes["skipSuffix"] == "true" {
                context.registerVariable(name: "\(name)", value: newVar)
            } else {
                context.registerVariable(name: "var.\(name)", value: newVar)
            }
        }
        callback(newVar, nil)
    }
    
}
