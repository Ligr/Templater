//
//  String+Trim.swift
//  BalanceBy
//
//  Created by Alex on 1/24/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public extension String {

    var trim: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}
