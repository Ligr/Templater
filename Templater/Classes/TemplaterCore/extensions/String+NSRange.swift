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
		let from16 = utf16.startIndex.advanced(by: nsRange.location)
        let to16 = from16.advanced(by: nsRange.length)
		if let from = String.Index(from16, within: self), let to = String.Index(to16, within: self) {
			return from ..< to
		}
		return nil
	}
	
}
