//
//  DrawingProvider.swift
//  MyLotto
//
//  Created by Andre Hess on 28.04.16.
//  Copyright © 2016 Andre Heß. All rights reserved.
//

import UIKit

typealias LoadDrawingsCompletion = ([Drawing]) -> (Void)

class DrawingProvider: NSObject {

	static func sharedProvider() -> DrawingProvider {
		let me = DrawingProvider()
		return me
	}
	
	var httpManager:HTTPManager
	var operationQueue:NSOperationQueue
	var loadDrawingsCompletion:LoadDrawingsCompletion?
	
	override init() {
		self.httpManager = HTTPManager.sharedManager()
		self.operationQueue = NSOperationQueue()
		self.operationQueue.maxConcurrentOperationCount = 1
		self.operationQueue.qualityOfService = NSQualityOfService.Default
		super.init()
	}
	
	func loadDrawingsForDates(dates:[NSDate], completion:LoadDrawingsCompletion?) {
		var requestCounter = dates.count
		var allDrawings:[Drawing] = []
		for drawingDate in dates {
			let dateString = drawingDate.stringFromDate()
			let loadingOP:NSBlockOperation = NSBlockOperation.init(block: {
				let requestUrlString = "6aus49_archiv?drawday=\(dateString)"
				self.httpManager.GET(requestUrlString, parameters:nil, progress: { (NSProgress) -> (Void) in}, completion: { (error:NSError?, requestObject:AnyObject?) -> (Void) in
					requestCounter -= 1
					if let requestError = error {
						print("\(requestError)")
					} else {
						let requestResponse = requestObject as! NSDictionary
						let drawingDict = requestResponse.objectForKey(dateString) as! NSDictionary
						let drawing:Drawing = Drawing.drawingWithJsonDictionary(jsonDict: drawingDict)
						allDrawings.append(drawing)
						if (requestCounter == 0) {
							if (completion != nil) {
								completion!(allDrawings)
							}
						}
					}
				})
			})
			self.operationQueue.addOperation(loadingOP)
		}
	}
}
