//
//  String+HTML.swift
//  BalanceBy
//
//  Created by Alex on 1/22/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public extension String {

    public var stripHTML: String {
        var outStr = self
        let regex = try! NSRegularExpression(pattern: "<[^>]+>", options: [])
        var matches: [NSTextCheckingResult]

        repeat {
            matches = regex.matches(in: outStr, options: [], range: NSRange(location: 0, length: outStr.characters.count))
            matches.reversed().forEach { match in
                let range = match.range(at: 0)
                let str = (outStr as NSString).replacingCharacters(in: range, with: "")
                outStr = str
            }
        } while (matches.count > 0)

        return outStr
    }

}
