//
//  PhoneValueAnalyzer.swift
//  BalanceBy
//
//  Created by Alex on 2/9/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

extension ContextVariables {

    public static var countryCode: String {
        return "country.code.name"
    }

}

public final class PhoneValueAnalyzer {

    fileprivate var countryLength: Int = 1
    fileprivate var codeLength: Int = 3

    public init() {

    }

}

extension PhoneValueAnalyzer: ValueAnalyzer {

    public func value(value: String, context: ContextType) -> VariableType? {
        let searchCountry = value == "phone.country"
        let searchCode = value == "phone.code" || value == "phone.codeBY"
        let searchNumber = value == "phone.number" || value == "phone.numberBY"
        let country = context.variable(name: ContextVariables.countryCode)?.stringValue()?.lowercased() ?? "en"

        if country == "by" {
            countryLength = 3
            codeLength = 2
        }

        var result: VariableType? = nil
        if searchCountry || searchCode || searchNumber {
            if let rawFullPhone = context.variable(name: "account.login")?.stringValue(), rawFullPhone.count > 0 {
                let fullPhone = stringByRemovingNonNumericSymbolsFromString(string: rawFullPhone)
                if searchCountry {
                    result = .string(fullPhone.substring(to: fullPhone.index(fullPhone.startIndex, offsetBy: countryLength)))
                } else if searchCode {
                    let countryEnd = fullPhone.index(fullPhone.startIndex, offsetBy: countryLength)
                    let codeEnd = fullPhone.index(fullPhone.startIndex, offsetBy: countryLength + codeLength)
                    result = .string(fullPhone.substring(with: countryEnd ..< codeEnd))
                } else {
                    result = .string(fullPhone.substring(from: fullPhone.index(fullPhone.startIndex, offsetBy: countryLength + codeLength)))
                }
            }
        }
        return result
    }

}

private extension PhoneValueAnalyzer {

    func stringByRemovingNonNumericSymbolsFromString(string: String) -> String {
        let scanner = Scanner(string: string)
        let numbers = CharacterSet(charactersIn: "0123456789")
        var result: String = ""
        while scanner.isAtEnd == false {
            var buffer: NSString?
            if scanner.scanCharacters(from: numbers, into: &buffer), let buffer = buffer {
                result += buffer as String
            } else {
                scanner.scanLocation = scanner.scanLocation + 1
            }
        }
        return result
    }

}
