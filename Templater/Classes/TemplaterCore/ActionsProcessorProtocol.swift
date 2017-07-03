//
//  ActionsProcessorProtocol.swift
//  BalanceBy
//
//  Created by Alex on 1/7/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

internal protocol ActionsProcessorProtocol {

    func process(callback: @escaping (ContextType, Error?) -> ())

}
