//
//  ValueProcessor.swift
//  BalanceBy
//
//  Created by Alex on 1/3/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public protocol ValueProcessor {

    func value(value: String, context: ContextType) -> String

}
