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
            matches = regex.matches(in: outStr, options: [], range: NSRange(location: 0, length: outStr.count))
            matches.reversed().forEach { match in
                let range = match.range(at: 0)
                let str = (outStr as NSString).replacingCharacters(in: range, with: "")
                outStr = str
            }
        } while (matches.count > 0)

        return outStr
    }

    init?(htmlEncodedString: String) {

        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }

        self.init(attributedString.string)
    }

}
