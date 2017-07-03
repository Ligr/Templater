//
//  DataType.swift
//  BalanceBy
//
//  Created by Alex on 12/21/16.
//  Copyright © 2016 Home. All rights reserved.
//

import Foundation

public indirect enum VariableType {

    case string(String)
    case number(Double)
    case any(Any)
    case array([VariableType])

    public func stringValue() -> String? {
        switch self {
        case .string(let value):
            return value
        case .number(let value):
            return String(value)
        case .any(let value):
            return String(describing: value)
        case .array:
            return nil
        }
    }

    public func doubleValue() -> Double? {
        switch self {
        case .string(let value):
            return Double(value)
        case .number(let value):
            return value
        case .array, .any:
            return nil
        }
    }

}

extension VariableType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .string(let value):
            return value
        case .number(let value):
            return String(value)
        case .any(let value):
            return "\(value)"
        case .array(let value):
            return value.map { "\($0)" }.joined(separator: "\n")
        }
    }

}
