//
//  ToastAction.swift
//  BalanceBy
//
//  Created by Alex on 3/11/17.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit

public final class ToastAction: BaseAction {

    public override func execute(data: VariableType?, context: ContextType, callback: @escaping (VariableType?, Error?) -> ()) {
        if let value = attributes["value", context]?.stringValue() {
            context.uiConnector?.showMessage(value)
        } else {
            logger?.log("missing 'value' attribute")
        }
        callback(data, nil)
    }
    
}
