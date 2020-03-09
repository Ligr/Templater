//
//  FunctionProcessor.swift
//  BalanceBy
//
//  Created by Alex on 1/4/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation
import CryptoSwift

public struct FunctionProcessor {

    fileprivate enum FunctionType {
        case unknown
        case add
        case sub
        case mul
        case div
        case min
        case max
        case index
        case hmacSHA1
        case encrypt
        case pkcs5
    }

    fileprivate enum FunctionEncoding {
        case base64
        case hex
    }

    fileprivate enum FunctionEncryption {
        case unknown
        case md5
        case sha1
        case sha256
        case sha512
    }

    public init() {
        
    }

    public func value(variable: VariableType, functionDetails: String) -> (result: VariableType?, error: Error?) {
        var result: VariableType? = nil
        var resultError: Error? = nil
        let params = functionDetails.components(separatedBy: ",")
        if params.count > 1 {
            let function = functionType(name: params.first)
            let functionParams = Array(params[1 ..< params.count])
            switch function {
            case .add, .sub, .mul, .div:
                (result, resultError) = applyArythmeticFunction(function: function, variable: variable, otherValues: functionParams)
            case .min, .max:
                (result, resultError) = applyMinMaxFunction(function: function, variable: variable, otherValues: functionParams)
            case .index:
                (result, resultError) = applyIndexFunction(index: functionParams[0], variable: variable)
            case .hmacSHA1:
                (result, resultError) = applyHmacSHA1Function(variable: variable, functionParams: functionParams)
            case .encrypt:
                (result, resultError) = applyEncryptionFunction(variable: variable, functionParams: functionParams)
            case .pkcs5:
                (result, resultError) = applyPKCS5Function(variable: variable, functionParams: functionParams)
            case .unknown:
                resultError = ActionError.generic(message: "unsupported function '\(String(describing: params.first))'")
            }

        } else {
            resultError = ActionError.generic(message: "function has to have at least two params")
        }

        return (result: result, error: resultError)
    }

}

// MARK: - Private

fileprivate extension FunctionProcessor {

    func applyPKCS5Function(variable: VariableType, functionParams: [String]) -> (result: VariableType?, error: Error?) {
        var result: VariableType?
        var resultError: Error?
        if functionParams.count == 3, let key = Data(base64Encoded: functionParams[1]), let value = variable.stringValue(), let valueData = value.data(using: String.Encoding.utf8) {
//            let initializationVector = functionParams[0]
            let encoding = encodingType(name: functionParams[2])
            do {
                let pkcs5 = try PKCS5.PBKDF2(password: valueData.bytes, salt: key.bytes)
                let outData = try pkcs5.calculate()
                result = VariableType.string(dataToString(data: Data(outData), encoding: encoding))
            } catch {
                resultError = ActionError.generic(message: "")
            }
        } else {
            resultError = ActionError.invalidInputData
        }
        return (result: result, error: resultError)
    }

    func applyEncryptionFunction(variable: VariableType, functionParams: [String]) -> (result: VariableType?, error: Error?) {
        var result: VariableType?
        var resultError: Error?
        if functionParams.count == 2, let value = variable.stringValue(), let valueData = value.data(using: String.Encoding.utf8) {
            let encryption = encryptionType(name: functionParams[0])
            let encoding = encodingType(name: functionParams[1])
            var outData: Data? = nil
            switch encryption {
            case .md5:
                outData = valueData.md5()
            case .sha1:
                outData = valueData.sha1()
            case .sha256:
                outData = valueData.sha256()
            case .sha512:
                outData = valueData.sha512()
            case .unknown:
                resultError = ActionError.generic(message: "unsupported encryption '\(functionParams[0])'")
            }
            if let outData = outData {
                result = VariableType.string(dataToString(data: outData, encoding: encoding))
            } else if resultError == nil {
                resultError = ActionError.generic(message: "failed to encrypt data")
            }
        } else {
            resultError = ActionError.invalidInputData
        }
        return (result: result, error: resultError)
    }

    func applyHmacSHA1Function(variable: VariableType, functionParams: [String]) -> (result: VariableType?, error: Error?) {
        var result: VariableType?
        var resultError: Error?
        if functionParams.count == 2, let str = variable.stringValue(), let data = str.data(using: String.Encoding.utf8) {
            let key = functionParams[0]
            let encoding = encodingType(name: functionParams[1])
            do {
                let hmac = try HMAC(key: key, variant: .sha1)
                let outData = try hmac.authenticate(data.bytes)
                result = VariableType.string(dataToString(data: Data(outData), encoding: encoding))
            } catch {
                resultError = ActionError.generic(message: "HmacSHA1 function failed")
            }
        } else {
            resultError = ActionError.invalidInputData
        }
        return (result: result, error: resultError)
    }

    func applyIndexFunction(index: String, variable: VariableType) -> (result: VariableType?, error: Error?) {
        var result: VariableType?
        var resultError: Error?
        if let index = Int(index), case VariableType.array(let array) = variable {
            if index < array.count {
                result = array[index]
            } else {
                resultError = ActionError.indexOutOfBounds(index: index, bounds: array.count)
            }
        } else {
            resultError = ActionError.invalidInputData
        }
        return (result: result, error: resultError)
    }

    func applyMinMaxFunction(function: FunctionType, variable: VariableType, otherValues: [String]) -> (result: VariableType?, error: Error?) {
        var doubleValues = otherValues.map {
            Double($0) ?? 0
        }
        if let variableValue = variable.doubleValue() {
            doubleValues.append(variableValue)
        }
        var outValue: Double?
        switch function {
        case .min:
            outValue = doubleValues.min()
        case .max:
            outValue = doubleValues.max()
        default:
            break
        }
        if let outValue = outValue {
            return (result: VariableType.number(outValue), error: nil)
        } else {
            return (result: nil, error: ActionError.invalidInputData)
        }
    }

    func minFromValues(otherValues: [String]) -> (result: VariableType?, error: Error?) {
        let doubleValues = otherValues.map {
            Double($0) ?? 0
        }
        if let min = doubleValues.min() {
            return (result: VariableType.number(min), error: nil)
        } else {
            return (result: nil, error: ActionError.invalidInputData)
        }
    }

    func maxFromValues(otherValues: [String]) -> (result: VariableType?, error: Error?) {
        let doubleValues = otherValues.map {
            Double($0) ?? 0
        }
        if let max = doubleValues.max() {
            return (result: VariableType.number(max), error: nil)
        } else {
            return (result: nil, error: ActionError.invalidInputData)
        }
    }

    func applyArythmeticFunction(function: FunctionType, variable: VariableType, otherValues: [String]) -> (result: VariableType?, error: Error?) {
        var result: VariableType?
        var resultError: Error?
        if var value = variable.doubleValue() {
            for otherStrValue in otherValues {
                if let otherValue = Double(otherStrValue) {
                    switch function {
                    case .add:
                        value += otherValue
                    case .sub:
                        value -= otherValue
                    case .mul:
                        value *= otherValue
                    case .div:
                        value /= otherValue
                    default:
                        break
                    }
                } else {
                    resultError = ActionError.invalidInputData
                }
            }
            result = VariableType.number(value)
        }
        return (result: result, error: resultError)
    }

    func dataToString(data: Data, encoding: FunctionEncoding) -> String {
        switch encoding {
        case .base64:
            return data.base64EncodedString()
        case .hex:
            return data.toHexString()
        }
    }

    func encryptionType(name: String?) -> FunctionEncryption {
        switch name?.lowercased() {
        case "md5"?:
            return .md5
        case "sha-1"?:
            return .sha1
        case "sha-256"?:
            return .sha256
        case "sha-512"?:
            return .sha512
        default:
            return .unknown
        }
    }

    func encodingType(name: String) -> FunctionEncoding {
        switch name.lowercased() {
        case "hex":
            return .hex
        default:
            return .base64
        }
    }

    func functionType(name: String?) -> FunctionType {
        switch name?.lowercased() {
        case "add"?:
            return .add
        case "sub"?:
            return .sub
        case "mul"?:
            return .mul
        case "div"?:
            return .div
        case "min"?:
            return .min
        case "max"?:
            return .max
        case "index"?:
            return .index
        case "hmacsha1"?:
            return .hmacSHA1
        case "encrypt"?:
            return .encrypt
        case "pkcs5"?:
            return .pkcs5
        default:
            return .unknown
        }
    }

}
