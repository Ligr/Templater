//
//  Operators.swift
//  BalanceBy
//
//  Created by Alex on 1/22/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

public func += <K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

public func + <K, V> (left: [K:V], right: [K:V]) -> [K:V] {
    var outLeft = left
    for (k, v) in right {
        outLeft.updateValue(v, forKey: k)
    }
    return outLeft
}
