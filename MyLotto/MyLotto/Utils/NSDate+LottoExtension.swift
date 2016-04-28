//
//  NSDate+LottoExtension.swift
//  MyLotto
//
//  Created by Andre Hess on 28.04.16.
//  Copyright © 2016 Andre Heß. All rights reserved.
//

import Foundation

extension NSDate {
	
	static func dateFromString(dateString:String) -> NSDate {
		let formatter:NSDateFormatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		if let result = formatter.dateFromString(dateString) {
			return result
		} else {
			formatter.dateFormat = "dd.MM.yyyy"
			return formatter.dateFromString(dateString)!
		}
	}
	
	func stringFromDate() -> String {
		let formatter:NSDateFormatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter.stringFromDate(self)
	}
	
	func getYear() -> Int {
		let calendar:NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
		let dateComponetns:NSDateComponents = calendar.components(NSCalendarUnit.Year, fromDate: self)
		return dateComponetns.year
	}
}
