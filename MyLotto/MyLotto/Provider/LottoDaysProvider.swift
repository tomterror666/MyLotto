//
//  LottoDaysProvider.swift
//  MyLotto
//
//  Created by Andre Heß on 18/04/16.
//  Copyright © 2016 Andre Heß. All rights reserved.
//

import UIKit

typealias LottoDaysCompletion = (NSArray) -> (Void)

class LottoDaysProvider: NSObject {
	
	var allLottoDays:NSMutableDictionary!
	var httpManager:HTTPManager
	var operationQueue:NSOperationQueue
	var loadLottoDaysCompletion:LottoDaysCompletion?
	var loadLottoDaysStartDate:NSDate!
	var numberOfRequests:Int = 0
	
	static func sharedProvider() -> LottoDaysProvider {
		let me = LottoDaysProvider()
		return me
	}
	
	override init() {
		self.allLottoDays = NSMutableDictionary()
		self.httpManager = HTTPManager.sharedManager()
		self.operationQueue = NSOperationQueue()
		self.operationQueue.maxConcurrentOperationCount = 1
		self.operationQueue.qualityOfService = NSQualityOfService.Background
		super.init()
		self.loadLottoDaysFromFile()
	}
	
	func loadLottoDaysSinceDate(date:NSDate, completion:LottoDaysCompletion?) {
		let startingYear = date.getYear()
		let endingYear = NSDate().getYear()
		self.loadLottoDaysCompletion = completion
		self.loadLottoDaysStartDate = date
		for countingYear in startingYear...endingYear - 1 {
			if self.allLottoDays.objectForKey("\(countingYear)") == nil {
				self.numberOfRequests += 1
				self.addReadRequestForLottoDaysForYearToOperationQueue(countingYear, date:date, completion:completion)
			}
		}
		self.numberOfRequests += 1
		self.addReadRequestForLottoDaysForYearToOperationQueue(endingYear, date:date, completion:completion)
	}
	
	func addReadRequestForLottoDaysForYearToOperationQueue(year:Int, date:NSDate, completion:LottoDaysCompletion?) {
		let loadingOP:NSBlockOperation = NSBlockOperation.init(block: {
			let requestUrlString = "6aus49_archiv?year=\(year)"
			self.httpManager.GET(requestUrlString, parameters: nil, progress: { (NSProgress) -> (Void) in}, completion: { (error:NSError?, requestObject:AnyObject?) -> (Void) in
				if let requestError = error {
					print("\(requestError)")
				} else { 
					let requestResponse = requestObject as! NSDictionary
					if let lottodaysInResonse = requestResponse.objectForKey("\(year)") {
						self.allLottoDays.setObject(lottodaysInResonse, forKey: "\(year)")
					}
					print("Request to \(requestUrlString) finished with folloning \(self.numberOfRequests) requests")
					self.numberOfRequests -= 1
					if (self.numberOfRequests == 0) {
						self.storeLottoDaysToFile();
						if (completion != nil) {
							completion!(self.collectAllLottoDaysSinceDate(date))
						}
					}
				}
			})
		})
		self.operationQueue.addOperation(loadingOP)
	}
	
	func collectAllLottoDaysSinceDate(date:NSDate) -> NSArray {
		let result = NSMutableArray()
		for year in self.allLottoDays.allKeys {
			let dateArray:[NSDictionary] = self.allLottoDays.objectForKey(year) as! [NSDictionary]
			for dateDict:NSDictionary in dateArray {
				let lottoDate = NSDate.dateFromString(dateDict.objectForKey("date") as! String)
				result.addObject(lottoDate)
			}
		}
		return result
	}
	
//	func dateFromString(dateString:String) -> NSDate {
//		let formatter:NSDateFormatter = NSDateFormatter()
//		formatter.dateFormat = "yyyy-MM-dd"
//		if let result = formatter.dateFromString(dateString) {
//			return result
//		} else {
//			formatter.dateFormat = "dd.MM.yyyy"
//			return formatter.dateFromString(dateString)!
//		}
//	}
//	
//	func getYearFromDate(date:NSDate) -> Int {
//		let calendar:NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
//		let dateComponetns:NSDateComponents = calendar.components(NSCalendarUnit.Year, fromDate: date)
//		return dateComponetns.year
//	}

	func storeLottoDaysToFile()  {
		var dataFileUrl = NSURL.fileURLWithPath(NSHomeDirectory())
		dataFileUrl = dataFileUrl.URLByAppendingPathComponent("LottoDays.dat")
		self.allLottoDays.writeToURL(dataFileUrl, atomically:true)
	}
	
	func loadLottoDaysFromFile() {
		var dataFileUrl = NSURL.fileURLWithPath(NSHomeDirectory())
		dataFileUrl = dataFileUrl.URLByAppendingPathComponent("LottoDays.dat")
		if let lottoDaysFromFile = NSMutableDictionary(contentsOfURL:dataFileUrl) {
			self.allLottoDays = lottoDaysFromFile
		}
	}
}
