//
//  DelayAction.swift
//  BalanceBy
//
//  Created by Alex on 2/21/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public final class DelayAction: BaseAction {

    public override func execute(data: VariableType?, context: ContextType, callback: @escaping (VariableType?, Error?) -> ()) {
        let delay: DispatchTime
        if let value = attributes["value", context]?.doubleValue() {
            delay = DispatchTime.now() + value
        } else {
            delay = DispatchTime.now() + 1
        }
        DispatchQueue.main.asyncAfter(deadline: delay, execute: {
            callback(data, nil)
        })
    }

}
