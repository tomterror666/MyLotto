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
	var allDrawings:[Drawing]
	var allDrawingsDict:NSMutableDictionary
	
	override init() {
		self.httpManager = HTTPManager.sharedManager()
		self.operationQueue = NSOperationQueue()
		self.operationQueue.maxConcurrentOperationCount = 9
		self.operationQueue.qualityOfService = NSQualityOfService.Utility
		self.allDrawings = []
		self.allDrawingsDict = NSMutableDictionary()
		super.init()
		self.allDrawingsDict = self.readAllDrawingsFromDisc()
	}
	
	func readAllDrawingsFromDisc() -> NSMutableDictionary {
		var dataFileUrl = NSURL.fileURLWithPath(NSHomeDirectory())
		dataFileUrl = dataFileUrl.URLByAppendingPathComponent("AllDrawings.dat")
		if let allDrawingsResult = NSMutableDictionary(contentsOfURL:dataFileUrl) {
			return allDrawingsResult
		}
		return NSMutableDictionary()
	}
	
	func storeAllDrawingsToDisc() {
		var dataFileUrl = NSURL.fileURLWithPath(NSHomeDirectory())
		dataFileUrl = dataFileUrl.URLByAppendingPathComponent("AllDrawings.dat")
		self.allDrawingsDict.writeToURL(dataFileUrl, atomically: true)
	}
	
	func loadDrawingsForDates(dates:[NSDate], completion:LoadDrawingsCompletion?) {
//		var requestCounter = dates.count
//		var allDrawings:[Drawing] = []
//		for drawingDate in dates {
//			let dateString = drawingDate.stringFromDate()
//			let loadingOP:NSBlockOperation = NSBlockOperation.init(block: {
//				let requestUrlString = "6aus49_archiv?drawday=\(dateString)"
//				self.httpManager.GET(requestUrlString, parameters:nil, progress: { (NSProgress) -> (Void) in}, completion: { (error:NSError?, requestObject:AnyObject?) -> (Void) in
//					requestCounter -= 1
//					if (requestCounter % 100 == 0) { print("still \(requestCounter) request outstanding...") }
//					if let requestError = error {
//						print("\(requestError)")
//					} else {
//						let requestResponse = requestObject as! NSDictionary
//						let drawingDict = requestResponse.objectForKey(dateString) as! NSDictionary
//						let drawing:Drawing = Drawing.drawingWithJsonDictionary(jsonDict: drawingDict)
//						allDrawings.append(drawing)
//						objc_sync_enter(self)
//						if (requestCounter == 0) {
//							if (completion != nil) {
//								completion!(allDrawings)
//							}
//						}
//						objc_sync_exit(self)
//					}
//				})
//			})
//			self.operationQueue.addOperation(loadingOP)
//		}
		let datesToLoad = (dates as NSArray).mutableCopy()
		let drawingDate = datesToLoad.firstObject as! NSDate
		let dateString = drawingDate.stringFromDate()
		if let readDrawing = self.allDrawingsDict.objectForKey(dateString) as? Drawing {
			self.allDrawings.append(readDrawing)
			datesToLoad.removeObject(drawingDate)
			if (datesToLoad.count > 0) {
				self.loadDrawingsForDates(datesToLoad as! [NSDate], completion:completion)
			} else {
				self.storeAllDrawingsToDisc()
				if (completion != nil) {
					completion!(self.allDrawings)
				}
			}
		} else {
			let requestUrlString = "6aus49_archiv?drawday=\(dateString)"
			self.httpManager.GET(requestUrlString, parameters:nil, progress: { (NSProgress) -> (Void) in}, completion: { (error:NSError?, requestObject:AnyObject?) -> (Void) in
				if ((datesToLoad.count) % 100 == 0) { print("still \(datesToLoad.count) request outstanding...") }
				if let requestError = error {
					print("\(requestError)")
				} else {
					let requestResponse = requestObject as! NSDictionary
					let drawingDict = requestResponse.objectForKey(dateString) as! NSDictionary
					let drawing:Drawing = Drawing.drawingWithJsonDictionary(jsonDict: drawingDict)
					self.allDrawings.append(drawing)
					self.allDrawingsDict.setObject(drawing, forKey: dateString)
					datesToLoad.removeObject(drawingDate)
					if (datesToLoad.count > 0) {
						self.loadDrawingsForDates(datesToLoad as! [NSDate], completion:completion)
					} else {
						self.storeAllDrawingsToDisc()
						if (completion != nil) {
							completion!(self.allDrawings)
						}
					}
				}
			})
		}
	}
		
}
