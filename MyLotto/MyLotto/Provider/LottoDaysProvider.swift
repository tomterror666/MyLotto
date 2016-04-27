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
	
	var allLottoDays:NSMutableDictionary
	var httpManager:HTTPManager
	var operationQueue:NSOperationQueue
	var loadLottoDaysCompletion:LottoDaysCompletion?
	var loadLottoDaysStartDate:NSDate!
	
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
	}
	
	func loadLottoDaysSinceDate(date:NSDate, completion:LottoDaysCompletion?) {
		let startingYear = self.getYearFromDate(date)
		let endingYear = self.getYearFromDate(NSDate())
		self.loadLottoDaysCompletion = completion
		self.loadLottoDaysStartDate = date
		var numberOfYears = endingYear - startingYear
		for countingYear in startingYear...endingYear {
			if self.allLottoDays.objectForKey("\(countingYear)") == nil {
				
				let loadingOP:NSBlockOperation = NSBlockOperation.init(block: {
					//todo: gehe liste der jahre durch und wenn noch nicht geladen, dann pack laderequest auf nsoperationqueue
					// sind alle laderequests fertig (operationaueue ist leer) oder wurden alle jahre gefunden, dann gehe diese liste nochmals durch und bilde result
					let requestUrlString = "6aus49_archiv?year=\(countingYear)"
					self.httpManager.GET(requestUrlString, parameters: nil, progress: { (NSProgress) -> (Void) in}, completion: { (error:NSError?, requestObject:AnyObject?) -> (Void) in
						if let requestError = error {
							print("\(requestError)")
						} else {
						//	dispatch_async(dispatch_get_main_queue(), { 
								let requestResponse = requestObject as! NSDictionary
								if let lottodaysInResonse = requestResponse.objectForKey("\(countingYear)") {
									self.allLottoDays.setObject(lottodaysInResonse, forKey: "\(countingYear)")
								}
								print("Request to \(requestUrlString) finished with folloning \(numberOfYears) requests")
								if (numberOfYears-- == 0) {
									if (completion != nil) {
										completion!(self.collectAllLottoDaysSinceDate(date))
									}
								}
						//	})
						}
					})
				})
				self.operationQueue.addOperation(loadingOP)
			}
		}
		if (self.operationQueue.operationCount == 0) {
			if (completion != nil) {
				completion!(self.collectAllLottoDaysSinceDate(date))
			}
		} else {
//			self.operationQueue.addObserver(self, 
//			                                forKeyPath: "operationCount", 
//			                                options: NSKeyValueObservingOptions.New, 
//			                                context: nil)
		}
	}
	
	func collectAllLottoDaysSinceDate(date:NSDate) -> NSArray {
		let result = NSMutableArray()
		for year in self.allLottoDays.allKeys {
			let dateArray:[NSDictionary] = self.allLottoDays.objectForKey(year) as! [NSDictionary]
			for dateDict:NSDictionary in dateArray {
				let lottoDate = self.dateFromString(dateDict.objectForKey("date") as! String)
				result.addObject(lottoDate)
			}
		}
		return result
	}
	
	func dateFromString(dateString:String) -> NSDate {
		let formatter:NSDateFormatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		if let result = formatter.dateFromString(dateString) {
			return result
		} else {
			formatter.dateFormat = "dd.MM.yyyy"
			return formatter.dateFromString(dateString)!
		}
	}
	
	func getYearFromDate(date:NSDate) -> Int {
		let calendar:NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
		let dateComponetns:NSDateComponents = calendar.components(NSCalendarUnit.Year, fromDate: date)
		return dateComponetns.year
	}

	
	
	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		//print("Request finished with folloning \(self.operationQueue.operationCount) requests")
		if (self.operationQueue.operationCount == 1) {
			if (self.loadLottoDaysCompletion != nil) {
				self.loadLottoDaysCompletion!(self.collectAllLottoDaysSinceDate(self.loadLottoDaysStartDate))
			}
		}
	}
}
