//
//  ActionProtocol.swift
//  BalanceBy
//
//  Created by Alex on 12/21/16.
//  Copyright © 2016 Home. All rights reserved.
//

import Foundation

public protocol ActionLogger {

    var logs: String { get }

    func log(_ str: String?)
    
}

extension ActionLogger {

    public func log(_ convertible: CustomStringConvertible?) {
        guard let convertible = convertible else { return }
        let str = "\(convertible)"
        self.log(str)
    }

}

public protocol ActionProtocol {

    var nextActions: [ActionProtocol] { get set }
    var elseAction: ActionProtocol? { get set }
    var logger: ActionLogger? { get set }
    var attributes: ActionAttributes { get set }
    var params: [ActionAttributes] { get set }

    func execute(data: VariableType?, context: ContextType, callback: @escaping (VariableType?, Error?) -> ())
    func copy() -> ActionProtocol

}
