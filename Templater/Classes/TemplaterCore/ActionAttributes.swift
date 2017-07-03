//
//  ActionAttributes.swift
//  BalanceBy
//
//  Created by Alex on 1/22/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public class ActionAttributes {

    fileprivate let attributes: [String: String]
    fileprivate let analyzer: ValueAnalyzer

    public init() {
        attributes = [:]
        analyzer = EmptyAnalyzer()
    }

    public init(attributes: [String: String], analyzer: ValueAnalyzer) {
        self.attributes = attributes
        self.analyzer = analyzer
    }

    public subscript (key: String, context: ContextType) -> VariableType? {
        guard let value = attributes[key] else { return nil }
        return analyzer.value(value: value, context: context)
    }

    public subscript (key: String) -> String? {
        return attributes[key]
    }

}

extension ActionAttributes: CustomStringConvertible {

    public var description: String {
        var desc = "Action Attributes:"
        for attribute in attributes {
            desc += "\n\(attribute.key): \(attribute.value)"
        }
        return desc
    }

}

private final class EmptyAnalyzer: ValueAnalyzer {

    func value(value: String, context: ContextType) -> VariableType? {
        return nil
    }
    
}
