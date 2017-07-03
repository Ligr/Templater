//
//  UIConnectorProtocol.swift
//  BalanceBy
//
//  Created by Alex on 3/13/17.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit

public protocol UIConnectorProtocol {

    func presentController(_ controller: UIViewController, completed: (() -> ())?)
    func showMessage(_ message: String)

}
