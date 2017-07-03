//
//  JsonAction.swift
//  BalanceBy
//
//  Created by Alex on 3/15/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public final class JsonAction: BaseAction {

    public override func execute(data: VariableType?, context: ContextType, callback: @escaping (VariableType?, Error?) -> ()) {
        var value = attributes["value", context]?.stringValue()
        if value == nil {
            value = data?.stringValue()
        }
        if let value = value, let data = value.data(using: String.Encoding.utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                    let result = VariableType.any(json)
                    context.registerVariable(name: "json", value: .any(json))
                    callback(result, nil)
                } else {
                    logger?.log("json parsed, but it is incorrect")
                    callback(nil, nil)
                }
            } catch {
                logger?.log("failed to parse json")
                callback(nil, nil)
            }
        } else {
            callback(nil, nil)
        }
    }

}
