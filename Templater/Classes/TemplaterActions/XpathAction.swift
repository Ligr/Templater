//
//  XpathAction.swift
//  BalanceBy
//
//  Created by Alex on 1/25/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation
import LPXML

public class XpathAction: BaseAction {

    public override func execute(data: VariableType?, context: ContextType, callback: @escaping (VariableType?, Error?) -> ()) {
        logger?.log(attributes)
        logger?.log("\n\(context)")
        var result: VariableType? = nil
        var resultError: Error? = nil

        defer {
            callback(result, resultError)
        }

        var inputData: String?
        if let valueAttribute = attributes["value", context]?.stringValue() {
            inputData = valueAttribute
        } else if case VariableType.string(let string)? = data {
            inputData = string
        }
        if let inputData = inputData, let xpath = attributes["xpath", context]?.stringValue() {
            let xml = LPXML(htmlString: inputData, encoding: String.Encoding.utf8.rawValue)
            if let str = xml?.content(forXpath: xpath) {
                result = VariableType.string(str)
            }
        } else {
            if inputData == nil {
                resultError = ActionError.invalidInputData
            } else {
                resultError = ActionError.missingAttribute(name: "xpath")
            }
        }
    }

}
