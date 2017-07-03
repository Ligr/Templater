//
//  DateValueAnalyzer.swift
//  BalanceBy
//
//  Created by Alex on 3/2/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public final class DateValueAnalyzer: ValueAnalyzer {

    public init() {

    }

    public func value(value: String, context: ContextType) -> VariableType? {
        if value == "date.day" {
            return .string("\(Calendar.current.component(.day, from: Date()))")
        } else if value == "date.month" {
            return .string("\(Calendar.current.component(.month, from: Date()))")
        } else if value == "date.year" {
            return .string("\(Calendar.current.component(.year, from: Date()))")
        } else {
            return nil
        }
    }

}
