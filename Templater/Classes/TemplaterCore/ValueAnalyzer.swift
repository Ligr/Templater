//
//  ValueAnalyzer.swift
//  BalanceBy
//
//  Created by Alex on 1/3/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public protocol ValueAnalyzer {

    func value(value: String, context: ContextType) -> VariableType?

}
