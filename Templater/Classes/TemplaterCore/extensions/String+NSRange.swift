//
//  String+NSRange.swift
//  BalanceBy
//
//  Created by Alex on 3/29/16.
//  Copyright © 2016 Home. All rights reserved.
//

import Foundation

extension String {
	
	public func rangeFromNSRange(_ nsRange : NSRange) -> Range<String.Index>? {
		let from16 = index(startIndex, offsetBy: nsRange.location)
        let to16 = index(from16, offsetBy: nsRange.length)
		if let from = String.Index(from16, within: self), let to = String.Index(to16, within: self) {
			return from ..< to
		}
		return nil
	}
	
}
