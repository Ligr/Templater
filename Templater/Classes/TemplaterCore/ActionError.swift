//
//  ActionError.swift
//  BalanceBy
//
//  Created by Alex on 3/6/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public enum ActionError: Error {

    case missingAttribute(name: String)
    case invalidInputData
    case invalidRegularExpression(expression: String)
    case indexOutOfBounds(index: Int, bounds: Int)
    case invalidParameter(details: String)
    case generic(message: String?)
    case emptyResult
    case userException(message: String?)
    
}
