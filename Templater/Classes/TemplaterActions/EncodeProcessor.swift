//
//  EncodeProcessor.swift
//  BalanceBy
//
//  Created by Alex on 4/5/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public struct EncodeProcessor {

    public enum EncodeType {
        case lowerCase
        case unknown
    }

    public init() {}

    public func value(variable: VariableType, encodeDetails: String) -> (result: VariableType?, error: Error?) {
        var result: VariableType? = nil
        var resultError: Error? = nil
        let encodeType = self.encodeType(name: encodeDetails)
        switch encodeType {
        case .lowerCase:
            if let str = variable.stringValue()?.lowercased() {
                result = .string(str)
            }
        case .unknown:
            resultError = ActionError.generic(message: "unsupported encode '\(String(describing: encodeDetails))'")
        }
        return (result: result, error: resultError)
    }

    private func encodeType(name: String?) -> EncodeType {
        switch name?.lowercased() {
        case "tolowercase"?:
            return .lowerCase
        default:
            return .unknown
        }
    }

}
