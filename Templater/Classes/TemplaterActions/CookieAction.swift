//
//  CookieAction.swift
//  BalanceBy
//
//  Created by Alex on 2/21/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public final class CookieAction: BaseAction {

    public override func execute(data: VariableType?, context: ContextType, callback: @escaping (VariableType?, Error?) -> ()) {
        logger?.log(attributes)
        logger?.log("\n\(context)")
        guard var name = attributes["name"], let value = attributes["value"] else {
            callback(nil, ActionError.missingAttribute(name: "name / value"))
            return
        }
        var domain: String? = nil
        if let separatorRange = name.range(of: ":"), separatorRange.upperBound < name.endIndex {
            domain = name.substring(to: separatorRange.lowerBound)
            name = name.substring(from: separatorRange.upperBound)
        }
        var cookieProps = [HTTPCookiePropertyKey: Any]()
        cookieProps[HTTPCookiePropertyKey.name] = name
        cookieProps[HTTPCookiePropertyKey.value] = value
        cookieProps[HTTPCookiePropertyKey.path] = "/"
        if let domain = domain {
            cookieProps[HTTPCookiePropertyKey.domain] = domain
        } else if let providerUrl = context.variable(name: ContextVariables.domain) {
            cookieProps[HTTPCookiePropertyKey.domain] = providerUrl.stringValue()
        }
        if let cookie = HTTPCookie(properties: cookieProps) {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
        callback(nil, nil)
    }

}

extension ContextVariables {

    public static var domain: String {
        return "cookie.domain.name"
    }

}
